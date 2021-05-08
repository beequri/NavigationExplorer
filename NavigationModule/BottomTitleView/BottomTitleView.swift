//  BottomTitleView.swift
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

class BottomTitleView {
    
    private let viewConfiguration: NavigationInterfaceConfiguration
    var bottomTitleLabel: UILabel?
    var bottomTitleContainer: UIView?
    
    private var _bottomTitleLabel: UILabel? {
        let bottomTitleLabel = UILabel(frame: .zero)
        bottomTitleLabel.font = viewConfiguration.titleLabelFont
        bottomTitleLabel.textColor = .white
        bottomTitleLabel.textAlignment = .left
        bottomTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return bottomTitleLabel
    }
    
    private var _bottomTitleContainer: UIView? {
        let titleView = UIView(frame: .zero)
        titleView.clipsToBounds = true
        titleView.isUserInteractionEnabled = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let bottomTitleLabel = bottomTitleLabel else {
            return nil
        }
        
        titleView.addSubview(bottomTitleLabel)
        titleView.addConstraints(subview: bottomTitleLabel, top: 5.0, right: nil, bottom: nil, left: 30.0, height: nil, width: nil)
        
        return titleView
    }
    
    // MARK: - Lifecycle
    
    init(viewConfiguration: NavigationInterfaceConfiguration) {
        self.viewConfiguration = viewConfiguration
    }
    
    // MARK: - Public
    
    func setup() {
        bottomTitleLabel = _bottomTitleLabel
        bottomTitleContainer = _bottomTitleContainer
    }
    
    func clean() {
        bottomTitleLabel?.removeFromSuperview()
        bottomTitleLabel = nil
        
        bottomTitleContainer?.removeFromSuperview()
        bottomTitleContainer = nil
    }
    
    func slideOffWithAnimation() {
        UIView.animate(withDuration: 0.25) {
            self.bottomTitleLabel?.alpha = 0
            self.bottomTitleLabel?.transform = CGAffineTransform(translationX: -1000, y: 0)
        }
    }
    
    func slideInWithAnimation() {
        UIView.animate(withDuration: 0.25) {
            self.bottomTitleLabel?.alpha = 1
            self.bottomTitleLabel?.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func hideWithAnimation(completion:(()->())?) {
        bottomTitleLabel?.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.bottomTitleLabel?.alpha = 1
        } completion: { _ in
            self.bottomTitleLabel?.isHidden = true
            completion?()
        }
    }
    
    func showWithAnimation(completion:(()->())?) {
        bottomTitleLabel?.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.bottomTitleLabel?.alpha = 1
        } completion: { _ in
            self.bottomTitleLabel?.isHidden = false
            completion?()
        }
    }
}
