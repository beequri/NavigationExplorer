//  NavigationInterfaceConfiguration.swift
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

struct NavigationStateConfiguration {
    let categoryBarHidden: Bool
    let titleHidden:Bool
    let shadowHidden: Bool
    
    init(categoryBarHidden: Bool = true,
         titleHidden: Bool = true,
         shadowHidden: Bool = true) {
        
        self.categoryBarHidden = categoryBarHidden
        self.titleHidden = titleHidden
        self.shadowHidden = shadowHidden
    }
}

@objc public class NavigationInterfaceConfiguration:NSObject {
    @objc public let secondLabelFont = UIFont(name: "Avenir-Oblique", size: 12)
    @objc public let firstLabelFont = UIFont.systemFont(ofSize: 15, weight: .bold)
    @objc public let titleLabelFont = UIFont.systemFont(ofSize: 28, weight: .bold)
    
    @objc public var infoViewSecondText: String?
    @objc public var infoViewFirstText: String?
    @objc public var tintColor: UIColor = .gray
    @objc public var shadowHidden: Bool = true
    @objc public var infoIcon: UIImage?
}
