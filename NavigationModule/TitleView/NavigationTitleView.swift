//  NavigationTitleView.swift
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

@objc public class NavigationTitleView: UIView {
    
    private var _title: String?
    private var _color: UIColor?
    
    var label:UILabel? {
        didSet {
            label?.numberOfLines    = 1;
            label?.font             = UIFont.systemFont(ofSize: 18, weight: .light)
            label?.lineBreakMode    = .byWordWrapping
            label?.textAlignment    = .center
            label?.textColor        = color
            label?.tintColor        = color
        }
    }
    
    var color: UIColor? {
        get {
            _color
        }
        set {
            _color = newValue
            label?.textColor = newValue
            label?.tintColor = newValue
        }
    }
    
    @objc public var title: String? {
        get {
            _title
        }
        set {
            if newValue?.count == 0, label?.isDescendant(of: self) == true {
                label?.removeFromSuperview()
                label = nil
                _title = title
                return
            }
            
            if let newTitle = newValue, newTitle.count > 0, _title != newTitle {
                _title = newTitle
                label?.removeFromSuperview()
                drawLabel()
            }
        }
    }
    
    // MARK: - Lifecycle
    
    @objc public class func titleView(title:String, color:UIColor?) -> NavigationTitleView {
        let margin = NavigationViewController.landscapeCategoryMargin
        let width = UIScreen.main.bounds.width - margin * 2
        let frame = CGRect(x: 0, y: 0, width: width, height: 45)
        let titleView = NavigationTitleView(frame: frame)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.title = title
        titleView.color = color
        return titleView
    }
    
    @objc public class func titleView(image:UIImage, color:UIColor?) -> UIImageView {
        let template = image.withRenderingMode(.alwaysTemplate)
        let titleView = UIImageView(image: template)
        titleView.tintColor = color
        titleView.contentMode = .scaleAspectFit
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    }
    
    // MARK: - Private
    private func drawLabel() {
        
        guard let title = title else {
            print("No title defined for category navigation")
            return
        }
        
        let labelRect = title.rect
        label = UILabel(frame: bounds)
        label?.text = title
        
        let selfWidth = bounds.width
        let labelWidth = labelRect.width
        
        if labelWidth > selfWidth {
            label?.font = UIFont.systemFont(ofSize: 13);
            label?.lineBreakMode = .byWordWrapping;
            label?.numberOfLines = 2;
        }
        
        guard let label = label, label.isDescendant(of: self) == false else {
            return
        }
        
        addSubview(label)
        label.sizeToFit()
        
        var frame = label.bounds
        frame.size.width += 30
        label.frame = frame
        
        inheritConstraints(subview: label)
        layoutIfNeeded()
    }
}
