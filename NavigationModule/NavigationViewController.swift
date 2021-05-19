//  NavigationViewController.swift
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

@objc public class NavigationViewController: UINavigationController, UINavigationControllerDelegate {
    /**
     Custom configuration should be initiated before view is loaded
     */
    @objc public var configuration = NavigationInterfaceConfiguration()
    @objc public var titleView: UIView? {
        currentNavigationController.titleView
    }
    
    private var viewWillAppearTimer: Timer?
    private weak var currentViewController: UIViewController?
    private var navigationObserver: NavigationObserver?
    private var currentNavigationController: PlainNavigationController {
        switch type {
        case .plain:
            return plainNavigationController
        case .custom:
            return customNavigationController
        case .privacyCategories:
            return collectionNavigationController
        }
    }
    
    lazy var navigationView: NavigationView = {
        NavigationView(controller: self)
    }()
    lazy internal var plainNavigationController: PlainNavigationController = {
        PlainNavigationController(navigationController: self)
    }()
    lazy internal var customNavigationController: CustomNavigationController = {
        CustomNavigationController(navigationController: self)
    }()
    lazy internal var collectionNavigationController: CollectionNavigationController = {
        CollectionNavigationController(navigationController: self)
    }()
    
    @objc public var expectedTopOffset: CGFloat {
        currentNavigationController.expectedTopOffset
    }
    
    @objc public var expectedNavigationHeight: CGFloat {
        currentNavigationController.expectedNavigationHeight
    }
    
    @objc public var infoBar: NavigationInfoBar? {
        currentNavigationController.infoBar
    }
    
    @objc public var categoryScrollView: CollectionView? {
        currentNavigationController.categoryScrollView
    }
    
    @objc public var rightBarButtonButton: UIBarButtonItem? {
        navigationItem.rightBarButtonItem
    }
    
    @objc public var leftBarButtonItem: UIBarButtonItem? {
        navigationItem.leftBarButtonItem
    }
    
    /**
     Changes the type of the navigation to `plain`, `privacy` or  `privacyCategory`. This needs to be set up before assigning any delegate
     */
    @objc public var type: NavigationType = .plain {
        didSet {
            if oldValue != type {
                resetDelegates()
            }
            configure()
        }
    }
    
    @objc public weak var navigationDelegate: NavigationControllerDelegate? {
        get {
            currentNavigationController.navigationControllerDelegate
        }
        set {
            currentNavigationController.navigationControllerDelegate = newValue
            super.delegate = self
            notifyViewWillAppear()
        }
    }
    
    @objc public weak var infoBarDelegate: InfoBarDelegate? {
        get {
            currentNavigationController.infoBarDelegate
        }
        set {
            currentNavigationController.infoBarDelegate = newValue
            notifyViewWillAppear()
        }
    }
    
    @objc public weak var collectionViewDelegate: CollectionViewDelegate? {
        get {
            guard type == .privacyCategories else {
                return nil
            }
            return collectionNavigationController.categoryScrollViewDelegate
        }
        set {
            guard type == .privacyCategories else {
                print("Failed to assign delegate. First please define navigation type `.privacyCategories`")
                return
            }
            collectionNavigationController.categoryScrollViewDelegate = newValue
            notifyViewWillAppear()
        }
    }
    
    // MARK: - Lifecycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentNavigationController.viewWillAppear()
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        guard UIApplication.shared.applicationState != .background else {
            return
        }
        
        currentNavigationController.willTransition(to: newCollection, with: coordinator)
    }
    
    @objc public override func setNavigationBarHidden(_ isHidden: Bool, animated: Bool) {
        currentNavigationController.setNavigationBarHidden(isHidden, animated:animated)
    }
    
    // MARK: - Public
    
    @objc public func requestToUpdateTitleView(animated: Bool) {
        currentNavigationController.requestToUpdateTitleView(animated: animated)
    }
    
    @objc public func evaluateInfoBarStatus() {
        currentNavigationController.evaluateInfoBarStatus()
    }
    
    @objc public func adjustNavigationIfNeeded(action: AdjustAction) {
        switch currentNavigationController {
        case is CollectionNavigationController:
            collectionNavigationController.adjustNavigation(action: action)
            return
            
        case is CustomNavigationController:
            customNavigationController.adjustNavigation(action: action)
            return
            
        default:
            return
        }
    }
    
    @objc public func setCollectionScrollViewHidden(_ hidden: Bool, completion: (()->())? = nil) {
        switch currentNavigationController {
        case is CollectionNavigationController:
            collectionNavigationController.setCollectionScrollViewHidden(hidden, completion: completion)
            return
            
        default:
            return
        }
    }
    
    // MARK: - Private
    
    private func notifyViewWillAppear() {
        viewWillAppearTimer?.invalidate()
        viewWillAppearTimer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false, block: { _ in
            
            guard let viewController = self.viewControllers.last else {
                return
            }
            self.currentViewController = viewController
            self.currentNavigationController.navigationController(self,
                                                                  willShow: viewController,
                                                                  animated: true,
                                                                  type: self.type)
        })
    }
    
    private func resetDelegates() {
        // Clean all delegate references which conform to navigation protocol
        plainNavigationController.navigationControllerDelegate = nil
        customNavigationController.navigationControllerDelegate = nil
        collectionNavigationController.navigationControllerDelegate = nil
        
        // Clean all delegate references which conform to privacy protocol
        plainNavigationController.infoBarDelegate = nil
        customNavigationController.infoBarDelegate = nil
        collectionNavigationController.infoBarDelegate = nil
        
        // Clean category scroll view delegate
        collectionNavigationController.categoryScrollViewDelegate = nil
    }
    
    private func configure() {
        navigationObserver = NavigationObserver(delegate: self)
        currentNavigationController.configure(with: configuration)
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool) {
        
        currentNavigationController.navigationController(navigationController,
                                                         didShow: viewController,
                                                         animated: animated,
                                                         type: type)
        
    }
}

extension NavigationViewController: NavigationObserverDelegate {
    public func didRequestToUpdateNavigationLayout() {
        currentNavigationController.recreate(type: type)
    }
}
