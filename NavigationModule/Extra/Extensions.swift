//  Extensions.swift
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

extension UIView {
    
    enum ConstraintId: String {
        case top
        case left
        case right
        case bottom
        case width
        case height
        
        static func id(for attribute: NSLayoutConstraint.Attribute) -> ConstraintId? {
            switch attribute {
            case .left:
                return .left
            case .right:
                return right
            case .top:
                return top
            case .bottom:
                return bottom
            case .width:
                return width
            case .height:
                return height
            default:
                return nil
            }
        }
    }
    
    func inheritConstraints(subview: UIView) {
        
        self.addConstraint(NSLayoutConstraint.init(item: subview, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint.init(item: subview, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint.init(item: subview, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint.init(item: subview, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        
    }
    
    func addConstraints(subview: UIView, top:CGFloat?, right:CGFloat?, bottom:CGFloat?, left:CGFloat?, height:CGFloat?, width:CGFloat?) {
        
        if let t = top {
            let constraint = NSLayoutConstraint.init(item: subview, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: t)
            constraint.identifier = ConstraintId.top.rawValue
            self.addConstraint(constraint)
        }
        
        if let r = right {
            let constraint = NSLayoutConstraint.init(item: subview, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: r)
            constraint.identifier = ConstraintId.right.rawValue
            self.addConstraint(constraint)
        }
        
        if let b = bottom {
            let constraint = NSLayoutConstraint.init(item: subview, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: b)
            constraint.identifier = ConstraintId.bottom.rawValue
            self.addConstraint(constraint)
        }
        
        if let l = left {
            let constraint = NSLayoutConstraint.init(item: subview, attribute: .left,   relatedBy: .equal, toItem: self, attribute: .left,   multiplier: 1, constant: l)
            constraint.identifier = ConstraintId.left.rawValue
            self.addConstraint(constraint)
        }
       
        if let w = width {
            let constraint = NSLayoutConstraint(item:subview, attribute:.width, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:0, constant:w)
            constraint.identifier = ConstraintId.width.rawValue
            subview.addConstraint(constraint)
        }
        
        if let h = height {
            let constraint = NSLayoutConstraint(item:subview, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:0, constant:h)
            constraint.identifier = ConstraintId.height.rawValue
            subview.addConstraint(constraint)
        }
    }
    
    func updateConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> Void {
        updateConstraint(attribute: attribute, constant: constant, immediately: true)
    }
    
    func updateConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat, immediately:Bool) -> Void {
        let constraintId = ConstraintId.id(for: attribute)?.rawValue
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute && $0.identifier == constraintId}.first) {
            constraint.constant = constant
            if immediately == true {
                self.layoutIfNeeded()
            }
        }
    }
    
    func constraint(attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        let constraintId = ConstraintId.id(for: attribute)?.rawValue
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute && $0.identifier == constraintId}.first) {
            return constraint
        }
        return nil
    }
}

extension UIViewController {
    
    static var isLandscape: Bool {
        if UIViewController.isPad {
            return false
        }
        return UIViewController.statusBarOrientation?.isLandscape ?? false
    }
    
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var statusBarOrientation: UIInterfaceOrientation? {
        get {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                #if DEBUG
                fatalError("Could not obtain UIInterfaceOrientation from a valid windowScene")
                #else
                return nil
                #endif
            }
            return orientation
        }
    }
    
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            let bundle = Bundle(for: self)
            return T.init(nibName: String(describing: T.self), bundle: bundle)
        }

        return instantiateFromNib()
    }
    
    var isPad: Bool {
        UIViewController.isPad
    }
    
    var isLandscape: Bool {
        UIViewController.isLandscape
    }
    
    var statusBarOrientation: UIInterfaceOrientation? {
        UIViewController.statusBarOrientation
    }
}

extension Bundle {
    static func this() -> Bundle {
        Bundle(for: NavigationViewController.self)
    }
}

extension NavigationViewController {
    static var landscapeCategoryMargin: CGFloat {
        let safeInset = UIApplication.shared.windows[0].safeAreaInsets
        if safeInset.top > 0 || safeInset.right > 0 {
            return 110 // ???: For iPad ok, but check for iPhone 8
        }
        return 70
    }
    
    var landscapeCategoryMargin: CGFloat {
        NavigationViewController.landscapeCategoryMargin
    }
    
    /**
            Height of the navigation bar including status bar
     */
    var totalHeight: CGFloat {
        var top = navigationBar.frame.height
        top += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return top
    }
    
    /**
            Height of the navigation bar without status bar
     */
    var contentHeight: CGFloat {
        return navigationBar.frame.height
    }
    
    var topPadding: CGFloat {
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        return topPadding * -1
    }
}

extension UIBarButtonItem {
    @objc public static func backButton(target: Any?, action: Selector?) -> UIBarButtonItem {
        let image = UIImage(systemName: "chevron.left")
        return UIBarButtonItem(image: image, style: .plain, target: target, action: action)
    }
}

extension String {
    var rect:CGRect {
        let font = UIFont.systemFont(ofSize: 18)
        let attributes = [NSAttributedString.Key.font: font]
        return NSString(string: self).boundingRect(with: CGSize(width: 5000, height: 0),
                                                   options: .usesLineFragmentOrigin,
                                                   attributes: attributes,
                                                   context: nil)
    }
}

extension UIColor {

    public func adjust(hueBy hue: CGFloat = 0, saturationBy saturation: CGFloat = 0, brightnessBy brightness: CGFloat = 0) -> UIColor {

        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return UIColor(hue: currentHue + hue,
                       saturation: currentSaturation + saturation,
                       brightness: currentBrigthness + brightness,
                       alpha: currentAlpha)
        } else {
            return self
        }
    }
}

class TouchTransparentView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let subview = super.hitTest(point, with: event)
        if subview !== self {
            return subview
        }
        return nil
    }
}

func delayInMilliseconds(_ milliseconds: Int, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds)) {
        block()
    }
}
