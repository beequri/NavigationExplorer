//  CategoryNavigationController.swift
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

@objc public protocol CollectionViewDelegate: AnyObject {
    func collectionItems() -> [CollectionItem]
    func didSelectCollectionItem(controller: CollectionNavigationController, tag: Int)
    func didDeselectCollectionItem(controller: CollectionNavigationController, tag: Int)
}

@objc public class CollectionNavigationController: CustomNavigationController {
    
    weak var categoryScrollViewDelegate: CollectionViewDelegate?
    var categoryViewHidden: Bool = false
    
    @objc public override var expectedTopOffset: CGFloat {
        navigationView!.expectedContentTopOffset
    }
    
    @objc public override var expectedNavigationHeight: CGFloat {
        navigationView!.expewctedNavigationHeight
    }
    
    override var stateConfiguration: NavigationStateConfiguration {
        return NavigationStateConfiguration(categoryBarHidden: false, titleHidden: false, shadowHidden: true)
    }
    
    // MARK: - Public
    
    public override func configure(with interfaceConfig: NavigationInterfaceConfiguration) {
        super.configure(with: interfaceConfig)
        navigationView?.collectionViewControllerDelegate = self
    }
    
    public func shouldHideCategoryBar(_ hidden: Bool) {
        categoryViewHidden = hidden
        showCategoriesIfNeeded()
        hideCategoriesIfNeeded()
    }
    
    public func shouldHideCategoryAndInfoBars(_ hidden: Bool) {
        shouldHideCategoryBar(hidden)
        shouldHideInfoBar(hidden)
    }

    
    public override func adjustNavigation(action: AdjustAction) {
        adjustNavigationTimer?.invalidate()
        adjustNavigationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            if action == .hide {
                if self.isLandscape == true {
                    self.navigationView?.hideBottomTitleForLandscapeWithAnimation()
                    return
                }
                if self.categoryViewHidden == false {
                    self.navigationView?.hideCategoriesForPortraitWithAnimation()
                }
                return
            }
            
            if self.isLandscape == true {
                self.navigationView?.showBottomTitleForLandscapeWithAnimation()
                return
            }
            
            if self.categoryViewHidden == false {
                self.navigationView?.showCategoriesForPortraitWithAnimation()
            }
        })
    }
    
    public func setCollectionScrollViewHidden(_ hidden: Bool, animated:Bool = true) {
        if hidden == true {
            if self.isLandscape == true {
                self.navigationView?.hideCategoriesForLandscapeWithAnimation()
                return
            }
            if self.categoryViewHidden == false {
                if animated {
                    self.navigationView?.hideCategoriesForPortraitWithAnimation()
                    return
                }
                self.navigationView?.hideCategoriesForPortraitWithoutAnimation()
            }
            return
        }
        
        if self.isLandscape == true {
            self.navigationView?.showCategoriesForLandscapeWithAnimation()
            return
        }
        
        if self.categoryViewHidden == false {
            if animated {
                self.navigationView?.showCategoriesForPortraitWithAnimation()
                return
            }
            self.navigationView?.showCategoriesForPortraitWithoutAnimation()
        }
    }
    
    // MARK: - Private
    
    private func showCategoriesIfNeeded() {
        if let items = self.categoryScrollViewDelegate?.collectionItems(), items.count > 0 {
            categoryViewHidden = false
        }
        
        guard categoryViewHidden == false else {
            return
        }
        isLandscape
            ? navigationView?.showCategoriesForLandscapeWithAnimation()
            : navigationView?.showCategoriesForPortraitWithAnimation()
    }
    
    private func hideCategoriesIfNeeded() {
        if let items = self.categoryScrollViewDelegate?.collectionItems(), items.count == 0 {
            categoryViewHidden = true
        }
        
        guard categoryViewHidden == true else {
            return
        }
        isLandscape
            ? navigationView?.hideCategoriesForLandscapeWithAnimation()
            : navigationView?.hideCategoriesForPortraitWithAnimation()
    }
    
    // MARK: - UIViewController related
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        guard UIApplication.shared.applicationState != .background else {
            return
        }
        
        navigationView?.willTransition(to: newCollection, with: coordinator, navigationType: .privacyCategories, completion: {
            self.hideCategoriesIfNeeded()
            self.navigationView?.collectionViewControllerDelegate = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.evaluateInfoBarStatus(animated: true)
            }
        })
    }
    
    // MARK: - UINavigationControllerDelegate related
    
    public override func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool,
                                     type: NavigationType) {
        navigationView?.stateConfiguration = stateConfiguration
        prepareToShow()
        if let leftButton = navigationControllerDelegate?.didRequestLeftBarButton() {
            viewController.navigationItem.setLeftBarButton(leftButton, animated: true)
        }
        navigationView?.navigationController(navigationController,
                                             willShow: viewController,
                                             animated: animated,
                                             navigationType: type)
        
        showHideCategoriesTimer?.invalidate()
        showHideCategoriesTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { _ in
            self.hideCategoriesIfNeeded()
            self.navigationControllerDelegate?.navigationDidUpdate(controller: self)
        })
        
        infoBarStatus = infoBarDelegate?.didRequestInfoBarStatus() ?? .hidden
        evaluateInfoBarStatus(animated: false)
    }
    
    public override func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool,
                                     type: NavigationType) {
        
        navigationView?.navigationController(navigationController,
                                             didShow: viewController,
                                             animated: animated,
                                             navigationType: type)
    }
    
}

extension CollectionNavigationController:CollectionViewControllerDelegate {
    
    public func didSelectItem(controller: CollectionView, tag: Int) {
        categoryScrollViewDelegate?.didSelectCollectionItem(controller: self, tag: tag)
    }
    
    public func didDeselectItem(controller: CollectionView, tag: Int) {
        categoryScrollViewDelegate?.didDeselectCollectionItem(controller: self, tag: tag)
    }
    
    public func collectionItems() -> [CollectionItem] {
        return categoryScrollViewDelegate?.collectionItems() ?? []
    }
}
