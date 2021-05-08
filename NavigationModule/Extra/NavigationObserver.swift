//  NavigationObserver.swift
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

public protocol NavigationObserverDelegate: AnyObject{
    func didRequestToUpdateNavigationLayout()
}

class NavigationObserver {
    
    private var isLandscape: Bool?
    private weak var delegate:NavigationObserverDelegate?
    
    init(delegate: NavigationObserverDelegate) {
        self.delegate = delegate
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateIfNecessary),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(snapshot),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }
    
    @objc private func snapshot() {
        isLandscape = UIViewController.isLandscape
    }
    
    @objc private func updateIfNecessary() {
        if let isLandscape = isLandscape, isLandscape != UIViewController.isLandscape {
            print("Did request to update navigation layout")
            delegate?.didRequestToUpdateNavigationLayout()
        }
    }
    
    
}
