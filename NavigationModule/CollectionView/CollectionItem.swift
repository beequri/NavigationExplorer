//  CollectionItem.swift
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

@objc public class CollectionItem: NSObject {
    private var _selectedImage: UIImage?
    private var _unselectedImage: UIImage?
    
    @objc public var tag: Int = 0
    @objc public var isSelected: Bool = false
    
    @objc public var selectedImage: UIImage? {
        get {
            _selectedImage
        }
        set {
            if _selectedImage != newValue {
                _selectedImage = newValue?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    @objc public var unselectedImage: UIImage? {
        get {
            _unselectedImage
        }
        set {
            if _unselectedImage != newValue {
                _unselectedImage = newValue?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    public var image: UIImage? {
        get {
            if isSelected == true {
                return selectedImage
            }
            return unselectedImage
        }
    }
    
    public override var description: String {
        "tag: \(tag), isSelected: \(isSelected)"
    }
}
