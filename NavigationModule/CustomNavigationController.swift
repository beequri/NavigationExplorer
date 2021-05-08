//  CustomNavigationController.swift
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

@objc public class CustomNavigationController: PlainNavigationController {
    
    override var stateConfiguration: NavigationStateConfiguration {
        return NavigationStateConfiguration(categoryBarHidden: true, titleHidden: false, shadowHidden: true)
    }
    
    // MARK: - Lifecycle

    public override func configure(with interfaceConfig: NavigationInterfaceConfiguration) {
        super.configure(with: interfaceConfig)
    }
    
    public override func willTransition(to newCollection: UITraitCollection,
                                        with coordinator: UIViewControllerTransitionCoordinator) {
        guard UIApplication.shared.applicationState != .background else {
            return
        }
        
        self.navigationView?.willTransition(to: newCollection, with: coordinator, navigationType: .custom, completion: {
            self.evaluateInfoBarStatus()
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
        showHideCategoriesTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.hideCategoriesWithAnimation()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.evaluateInfoBarStatus()
        }
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
