//  NavigationInfoBar.swift
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

@objc public class NavigationInfoBar: NSObject {
    
    let viewConfiguration: NavigationInterfaceConfiguration
    
    private var firstLabel: UILabel?
    private var secondLabel: UILabel?
    private var icon: UIImageView?
    
    public var infoContainerBar: UIView?
    public var infoBar: UIView?
    public var hideInfoBarAction: (()->())?
    
    private var _icon: UIImageView? {
        let icon = UIImageView(frame: .zero)
        icon.image = viewConfiguration.infoIcon?.withRenderingMode(.alwaysTemplate)
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }
    
    private var _firstLabel: UILabel? {
        let firstLabel = UILabel(frame: .zero)
        firstLabel.font = viewConfiguration.firstLabelFont
        firstLabel.textColor = .white
        firstLabel.text = viewConfiguration.infoViewFirstText
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        return firstLabel
    }
    
    private var _secondLabel: UILabel {
        let label = UILabel(frame: .zero)
        label.font = viewConfiguration.secondLabelFont
        label.textColor = .white
        label.textAlignment = .right
        label.text = viewConfiguration.infoViewSecondText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private var _bar: UIView? {
        guard let icon = icon,
              let firstLabel = firstLabel,
              let secondLabel = secondLabel else {
            return nil
        }
        
        var shadowRadius:CGFloat = UIViewController.isLandscape ? ladscapeShadowRadius : portraitShadowRadius
        if UIViewController.isLandscape == false, viewConfiguration.shadowHidden == true {
            shadowRadius = 0
        }
        
        let infoBar = UIView(frame: .zero)
        infoBar.backgroundColor = viewConfiguration.tintColor
        infoBar.translatesAutoresizingMaskIntoConstraints = false
        infoBar.layer.shadowColor = UIColor.black.cgColor
        infoBar.layer.shadowOpacity = 1
        infoBar.layer.shadowOffset = UIViewController.isLandscape ? CGSize(width: 0, height: 30) : CGSize.zero
        infoBar.layer.shadowRadius = shadowRadius
        
        // Add Gesture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapInfoBar))
        infoBar.addGestureRecognizer(gesture)
        
        let equalSide: CGFloat = loginBarHeight - 6
        infoBar.addSubview(icon)
        infoBar.addConstraints(subview: icon, top: 2, right: nil, bottom: nil, left: 10, height: equalSide, width: equalSide)

        infoBar.addSubview(firstLabel)
        let x = (icon.constraint(attribute: .width)?.constant ?? 0) + 16.0
        infoBar.addConstraints(subview: firstLabel, top: 2, right: nil, bottom: nil, left: x, height: equalSide, width: nil)

        infoBar.addSubview(secondLabel)
        infoBar.addConstraints(subview: secondLabel, top: 2, right: -10, bottom: nil, left: nil, height: equalSide, width: nil)
        
        return infoBar
    }
    
    private var _infoContainerBar: UIView? {
        guard let login = infoBar else {
            return nil
        }
        let infoContainer = TouchTransparentView(frame: .zero)
        infoContainer.clipsToBounds = true
        infoContainer.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.addSubview(login)
        infoContainer.addConstraints(subview: login, top: 0, right: 0, bottom: nil, left: 0, height: loginBarHeight, width: nil)
        login.transform = CGAffineTransform(translationX: 0, y: loginBarHeight * -1)
        return infoContainer
    }
    
    @objc public var userInteractionEnabled: Bool = true {
        didSet {
            infoBar?.isUserInteractionEnabled = userInteractionEnabled
            if !userInteractionEnabled {
                let newColor = viewConfiguration.tintColor.adjust(saturationBy: -0.2)
                UIView.animate(withDuration: 0.15) {
                    self.infoBar?.backgroundColor = newColor
                }
                return
            }
            UIView.animate(withDuration: 0.15) {
                self.infoBar?.backgroundColor = self.viewConfiguration.tintColor
            }
        }
    }
    
    init(viewConfiguration: NavigationInterfaceConfiguration) {
        self.viewConfiguration = viewConfiguration
    }
    
    public func setup() {
        // First initialize subviews
        icon              = _icon
        firstLabel        = _firstLabel
        secondLabel       = _secondLabel
        infoBar           = _bar
        infoContainerBar  = _infoContainerBar
    }
    
    public func clean() {
        icon?.removeFromSuperview()
        icon = nil
        
        firstLabel?.removeFromSuperview()
        firstLabel = nil
        
        secondLabel?.removeFromSuperview()
        secondLabel = nil
        
        infoBar?.removeFromSuperview()
        infoBar = nil
        
        infoContainerBar?.removeFromSuperview()
        infoContainerBar = nil
    }
    
    @objc private func didTapInfoBar() {
        hideInfoBarAction?()
    }
    
}
