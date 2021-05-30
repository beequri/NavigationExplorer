//  PlainNavigationController.swift
//  Created by beequri on 02 Apr 2021

/*
 
 MIT License
 
 Copyright (c) 2021 NavigationExplorer (https://github.com/beequri/NavigationExplorer)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import UIKit

@objc public protocol NavigationControllerDelegate: UINavigationControllerDelegate {
    func didRequestTitleView() -> UIView?
    func didRequestLeftBarButton() -> UIBarButtonItem?
    func navigationDidAppear(controller: PlainNavigationController)
    func navigationDidUpdate(controller: PlainNavigationController)
}

@objc public protocol InfoBarDelegate: AnyObject {
    func didRequestInfoBarStatus() -> InfoBarStatus
    func didRequestToHideInfoBar()
    func didChangeInfoBar(status: InfoBarStatus)
}

@objc public class PlainNavigationController: NSObject {
    weak var navigationView: NavigationView?
    weak var infoBarDelegate: InfoBarDelegate?
    weak var navigationController: NavigationViewController?
    weak var navigationControllerDelegate: NavigationControllerDelegate?
    
    var adjustNavigationTimer: Timer?
    var showHideCategoriesTimer: Timer?
    var infoBarHidden: Bool = false
    var infoBarStatus: InfoBarStatus = .hidden
    var currentInfoBarStatus: InfoBarStatus {
        infoBarDelegate?.didRequestInfoBarStatus() ?? .hidden
    }
    
    var stateConfiguration: NavigationStateConfiguration {
        return NavigationStateConfiguration()
    }
    
    var navigationHidden: Bool {
        navigationView?.hidden ?? false
    }
    
    @objc public var expectedTopOffset: CGFloat {
        if currentInfoBarStatus == .shown {
            return loginBarHeight
        }
        return 0
    }
    
    @objc public var expectedNavigationHeight: CGFloat {
        return navigationView!.systemNavigationTotalHeight
    }
    
    @objc public var infoBar: NavigationInfoBar? {
        navigationView?.navigationInfoBar
    }
    
    @objc public var categoryScrollView: CollectionView? {
        navigationView?.collectionView
    }
    
    @objc public var rightBarButtonButton: UIBarButtonItem? {
        navigationController?.navigationItem.rightBarButtonItem
    }
    
    @objc public var leftBarButtonItem: UIBarButtonItem? {
        navigationController?.navigationItem.leftBarButtonItem
    }
    
    public var titleView: UIView? {
        navigationControllerDelegate?.didRequestTitleView()
    }
    
    // MARK: - Lifecycle
    
    init(navigationController: NavigationViewController) {
        self.navigationController = navigationController
        self.navigationView = navigationController.navigationView
    }
    
    public func viewWillAppear() {
        hideCategories(animated: false)
    }
    
    public func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        guard UIApplication.shared.applicationState != .background else {
            return
        }
        
        self.navigationView?.willTransition(to: newCollection, with: coordinator, navigationType: .plain, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.evaluateInfoBarStatus(animated: true)
            }
        })
    }
    
    // MARK: - Public
    
    public func requestToUpdateTitleView(animated: Bool) {
        navigationView?.updateTitleView(animated: animated)
    }
    
    public func setNavigationBarHidden(_ isHidden: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.navigationView?.setNavigationBarHidden(isHidden)
            }
            return
        }
        self.navigationView?.setNavigationBarHidden(isHidden)
    }
    
    public func recreate(type: NavigationType) {
        let isHidden = navigationView?.hidden ?? false
        navigationView?.recreateNavigation(for: type, hidden: isHidden)
        evaluateInfoBarStatus(animated: true)
        navigationControllerDelegate?.navigationDidAppear(controller: self)
    }
    
    public func configure(with interfaceConfig: NavigationInterfaceConfiguration) {
        navigationView?.viewConfiguration = interfaceConfig
    }
    
    public func prepareToShow() {
        navigationView?.stateConfiguration = stateConfiguration
        navigationView?.collectionViewControllerDataSource = self
        navigationView?.prepareToShow()
        navigationView?.hideInfoBarAction = {
            self.infoBarDelegate?.didRequestToHideInfoBar()
        }
    }
    
    public func adjustNavigation(action: AdjustAction) {
        adjustNavigationTimer?.invalidate()
        adjustNavigationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            if action == .hide {
                if self.isLandscape == true {
                    self.navigationView?.hideBottomTitleForLandscapeWithAnimation()
                    return
                }
                return
            }
            
            if self.isLandscape == true {
                self.navigationView?.showBottomTitleForLandscapeWithAnimation()
                return
            }
        })
    }
    
    @objc public func evaluateInfoBarStatus(animated: Bool) {
        var changeNotification = false
        if infoBarStatus != currentInfoBarStatus {
            changeNotification = true
            infoBarStatus = currentInfoBarStatus
        }
        
        changeInfoBar(status: infoBarStatus, animated:animated, changeNotification: changeNotification)
    }
    
    public func hideCategories(animated: Bool) {
        if animated == true {
            isLandscape
                ? navigationView?.hideCategoriesForLandscapeWithAnimation()
                : navigationView?.hideCategoriesForPortraitWithAnimation()
            return
        }
        isLandscape
            ? navigationView?.hideCategoriesForLandscapeWithoutAnimation()
            : navigationView?.hideCategoriesForPortraitWithoutAnimation()
    }
    
    public func shouldHideInfoBar(_ hidden: Bool) {
        infoBarHidden = hidden
        showInfoBarIfNeeded()
        hideInfoBarIfNeeded()
    }
    
    // MARK: - Private
    
    private func showInfoBarIfNeeded() {
        guard infoBarHidden == false else {
            return
        }
        evaluateInfoBarStatus(animated: true)
    }
    
    private func hideInfoBarIfNeeded() {
        guard infoBarHidden == true else {
            return
        }
        changeInfoBar(status: .hidden, animated: true, changeNotification: false)
    }
    
    private func changeInfoBar(status: InfoBarStatus, animated:Bool, changeNotification: Bool) {
        navigationView?.changeInfoBar(status: status, animated: animated, completion: {
            if changeNotification {
                self.infoBarDelegate?.didChangeInfoBar(status: self.infoBarStatus)
            }
            self.navigationControllerDelegate?.navigationDidUpdate(controller: self)
        })
    }
    
    // MARK: - UINavigationControllerDelegate related
    
    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool,
                                     type: NavigationType) {
        prepareToShow()
        if let leftButton = navigationControllerDelegate?.didRequestLeftBarButton() {
            viewController.navigationItem.setLeftBarButton(leftButton, animated: animated)
        }
        
        navigationView?.navigationController(navigationController,
                                             willShow: viewController,
                                             animated: animated,
                                             navigationType: type)
        
        showHideCategoriesTimer?.invalidate()
        showHideCategoriesTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.hideCategories(animated: animated)
        })
        
        infoBarStatus = infoBarDelegate?.didRequestInfoBarStatus() ?? .hidden
        evaluateInfoBarStatus(animated: false)
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool,
                                     type: NavigationType) {
        navigationView?.navigationController(navigationController,
                                             didShow: viewController,
                                             animated: animated,
                                             navigationType: type)
    }
}

extension PlainNavigationController:CollectionViewControllerDataSource {
    public var cellSize: CGSize {
        guard let height = navigationView?.systemNavigationTotalHeight else {
            return .zero
        }
        let size = isLandscape ? height - 4 : scrollHeight - barBottomMargin
        return CGSize(width: size, height: size)
    }
}

extension PlainNavigationController {
    var isLandscape: Bool {
        UIViewController.isLandscape
    }
}
