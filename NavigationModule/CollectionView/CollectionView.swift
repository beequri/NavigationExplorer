//  CollectionView.swift
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

public protocol CollectionViewControllerDataSource: AnyObject {
    var cellSize:CGSize { get }
}

public protocol CollectionViewControllerDelegate: AnyObject {
    func collectionItems() -> [CollectionItem]
    func didSelectItem(controller: CollectionView, tag: Int)
    func didDeselectItem(controller: CollectionView, tag: Int)
}

public class CollectionView: UIView {
    
    weak var dataSource: CollectionViewControllerDataSource?
    weak var delegate:CollectionViewControllerDelegate?
    private let stateConfiguration: NavigationStateConfiguration
    private let viewConfiguration: NavigationInterfaceConfiguration
    
    var scrollBar: UICollectionView?
    var scrollBarContainer: UIView?
    var flowLayout: UICollectionViewFlowLayout?
    var seperator: UIView?
    
    var fillColorLansdscape: UIColor = UIColor.label.withAlphaComponent(0.6)
    var fillColorPortrait: UIColor = UIColor.label.withAlphaComponent(0.4)
    var borderColorPortrait: UIColor = UIColor.label.withAlphaComponent(0.1)
    
    var categoryItems: [CollectionItem] {
        if UIViewController.isLandscape {
            return delegate?.collectionItems().reversed() ?? []
        }
        return delegate?.collectionItems() ?? []
    }
    
    var currentScrollHeight: CGFloat {
        scrollBarContainer?.constraint(attribute: .height)?.constant ?? 0
    }
    
    lazy var maskImage: UIImage? = {
        let bundle = Bundle(for: CollectionNavigationController.self)
        let image = UIImage(named:"fading_mask", in:bundle, compatibleWith:nil)
        return image
    }()
    
    private var _seperator: UIView? {
        let seperator = UIView(frame: .zero)
        seperator.backgroundColor = UIColor(named: "separatorColor", in:Bundle.this(), compatibleWith:nil)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        return seperator
    }
    
    private var _flowLayout: UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = dataSource?.cellSize ?? .zero
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }
    
    private var _scrollBar: UICollectionView? {
        guard let flowLayout = flowLayout else {
            return nil
        }
        
        let scrollBar = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        scrollBar.clipsToBounds = false
        scrollBar.backgroundColor = .clear
        scrollBar.delegate = self
        scrollBar.dataSource = self
        scrollBar.alwaysBounceHorizontal = true
        scrollBar.showsHorizontalScrollIndicator = false
        scrollBar.translatesAutoresizingMaskIntoConstraints = false

        if UIViewController.isLandscape {
            scrollBar.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        return scrollBar
    }
    
    private var _scrollBarContainer: UIView? {
        guard flowLayout != nil, let scrollBar = scrollBar else {
            return nil
        }
        
        let scrollBarContainer = TouchTransparentView(frame: .zero)
        scrollBarContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollBarContainer.addSubview(scrollBar)
        
        return scrollBarContainer
    }
    
    // MARK: - Lifecycle
    
    init(stateConfiguration: NavigationStateConfiguration,
         viewConfiguration: NavigationInterfaceConfiguration) {
        self.stateConfiguration = stateConfiguration
        self.viewConfiguration = viewConfiguration
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public
    func loadCategories() {
        scrollBar?.reloadData()
    }
    
    func setup() {
        // Flow layout
        flowLayout          = _flowLayout

        // main views
        scrollBar           = _scrollBar
        scrollBarContainer  = _scrollBarContainer
        seperator           = _seperator

        // Register nib
        let nib = UINib(nibName: "CollectionViewCell", bundle: Bundle(for: self.classForCoder))
        scrollBar?.register(nib, forCellWithReuseIdentifier: "cell")
    }
    
    func clean() {
        flowLayout = nil

        scrollBar?.removeFromSuperview()
        scrollBar = nil

        scrollBarContainer?.removeFromSuperview()
        scrollBarContainer = nil
        
        seperator?.removeFromSuperview()
        seperator = nil
    }
    
    func updateConstraints(height: CGFloat, margin: CGFloat) {
        guard let scrollBar = scrollBar,
              let scrollBarContainer = scrollBarContainer  else {
            return
        }
        
        let adjustedHeight: CGFloat
        if height == 0 {
            adjustedHeight = 0
        } else {
            adjustedHeight = UIViewController.isLandscape ? height : height - barBottomMargin
        }
        
        scrollBarContainer.addConstraints(subview: scrollBar, top: 0, right: 0, bottom: nil, left: 0, height: adjustedHeight, width: nil)
        scrollBar.contentInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)

        if let seperator = seperator, UIViewController.isLandscape == false {
            scrollBarContainer.addSubview(seperator)
            let height = scrollBarContainer.constraint(attribute: .height)?.constant ?? 0
            scrollBarContainer.addConstraints(subview: seperator, top: height - 1, right: 0, bottom: nil, left: 0, height: 1.0, width: nil)
        }
        
    }
    
    func updateHeight(height:CGFloat) {
        let adjustedHeight: CGFloat
        if height == 0 {
            adjustedHeight = 0
        } else {
            adjustedHeight = UIViewController.isLandscape ? height : height - barBottomMargin
        }
        
        scrollBarContainer?.updateConstraint(attribute: .height, constant: height)
        scrollBar?.updateConstraint(attribute: .height, constant: adjustedHeight)
    }
    
    func slideOffWithAnimation(completion: (()->())? = nil) {
        UIView.animate(withDuration: 0.2) {
            self.scrollBarContainer?.transform = CGAffineTransform(translationX: 0, y: -100)
            self.scrollBarContainer?.alpha = 0
        } completion: { _ in
            self.scrollBarContainer?.isHidden = true
            completion?()
        }
    }
    
    func slideOffWithoutAnimation() {
        scrollBarContainer?.transform = CGAffineTransform(translationX: 0, y: -100)
        scrollBarContainer?.alpha = 0
        scrollBarContainer?.isHidden = true
    }
    
    func slideInWithAnimation(completion: (()->())? = nil) {
        scrollBarContainer?.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.scrollBarContainer?.transform = CGAffineTransform(translationX: 0, y: 0)
            self.scrollBarContainer?.alpha = 1
        } completion: { _ in
            completion?()
        }
    }
    
    func slideInWithoutAnimation() {
        scrollBarContainer?.isHidden = false
        scrollBarContainer?.transform = CGAffineTransform(translationX: 0, y: 0)
        scrollBarContainer?.alpha = 1
    }
    
    func hideWithoutAnimationIfNeeded() {
        if stateConfiguration.categoryBarHidden == true {
            scrollBarContainer?.alpha = 0
            scrollBarContainer?.isHidden = true
        }
    }
}

extension  CollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.imageView.image = categoryItems[indexPath.row].image

        if UIViewController.isLandscape {
            // The horizontal collection would be nice to be align tor right, so reverese all
            let cats = categoryItems
            cell.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.imageView.tintColor = cats[indexPath.row].isSelected ? viewConfiguration.tintColor : fillColorLansdscape
            return cell
        }
        cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        cell.imageView.tintColor = fillColorPortrait
        cell.layer.borderColor = categoryItems[indexPath.row].isSelected ? viewConfiguration.tintColor.cgColor : borderColorPortrait.cgColor
        return cell
    }
}

extension  CollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = categoryItems[indexPath.row]
        let tag = item.tag
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        item.isSelected = !item.isSelected
        
        if item.isSelected {
            if UIViewController.isLandscape {
                cell.imageView.tintColor = viewConfiguration.tintColor
            } else {
                cell.imageView.tintColor = fillColorLansdscape
                cell.layer.borderColor   = viewConfiguration.tintColor.cgColor
            }
            delegate?.didSelectItem(controller: self, tag: tag)
        } else {
            if UIViewController.isLandscape {
                cell.imageView.tintColor = .label
            } else {
                cell.imageView.tintColor = fillColorPortrait
                cell.layer.borderColor   = fillColorPortrait.cgColor
            }
            delegate?.didDeselectItem(controller: self, tag: tag)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}
