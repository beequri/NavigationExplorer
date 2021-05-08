//  NavigationView.swift
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

class NavigationView {
    
    private weak var currentViewController: UIViewController?
    
    public weak var collectionViewControllerDataSource:CollectionViewControllerDataSource?
    public var collectionViewControllerDelegate:CollectionViewControllerDelegate? {
        get {
            return collectionView?.delegate
        }
        set {
            collectionView?.delegate = newValue
        }
    }
    
    private weak var navigationViewController: NavigationViewController?
    
    @objc  public var navigationPrivacyBar: NavigationInfoBar?
    @objc  public var collectionView: CollectionView?
    
    private var bottomTitleView: BottomTitleView?
    
    private var bottomLine: UIView?
    private var upperTitleView: UIView?
    private var blurView: UIVisualEffectView?
    
    private var privacyStatus: InfoBarStatus = .hidden
    public var hideInfoBarAction: (()->())? {
        didSet {
            navigationPrivacyBar?.hideInfoBarAction = hideInfoBarAction
        }
    }
    
    public var viewConfiguration = NavigationInterfaceConfiguration() {
        didSet {
            styling()
        }
    }
    public var stateConfiguration = NavigationStateConfiguration()
    
    var _blurView: UIVisualEffectView? {
        let blurView = UIVisualEffectView(frame: .zero)
        blurView.effect = UIBlurEffect(style: .systemChromeMaterialLight)
        
        if let traitCollection = bar?.traitCollection {
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                blurView.effect = UIBlurEffect(style: .systemChromeMaterialLight)
            case .dark:
                blurView.effect = UIBlurEffect(style: .systemChromeMaterialDark)
            @unknown default:
                blurView.effect = UIBlurEffect(style: .systemChromeMaterialLight)
            }
        }
        
        blurView.clipsToBounds = true
        blurView.layer.zPosition = -1
        blurView.isUserInteractionEnabled = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }
    
    var _bottomLine: UIView? {
        let separator = UIView(frame: .zero)
        separator.backgroundColor = UIColor(white: 0, alpha: 0.15)
        
        if let traitCollection = bar?.traitCollection {
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                separator.backgroundColor = UIColor(white: 0, alpha: 0.15)
            case .dark:
                separator.backgroundColor = UIColor(white: 1, alpha: 0.15)
            @unknown default:
                separator.backgroundColor = UIColor(white: 0, alpha: 0.15)
            }
        }
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.alpha = 0
        return separator
    }
    
    // MARK: Lifecycle
    
    init(controller: NavigationViewController) {
        navigationViewController = controller
    }
    
    // This needs to be called in `viewWillAppear(_ animated: Bool)` in the UIViewController
    @objc public func prepareToShow() {
        guard scrollBarContainer == nil else {
            return
        }
        prepareControllers()
        styling()
        viewSetup()
        showBar(animated: false)
        collectionView?.loadCategories()
    }
    
    public func updateTitleView(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.upperTitleView?.transform = CGAffineTransform(translationX: 0, y: -10)
                self.upperTitleView?.alpha = 0
            } completion: { _ in
                self.upperTitleView = self.navigationViewController?.titleView
                self.currentViewController?.navigationItem.titleView = self.upperTitleView
                self.upperTitleView?.transform = CGAffineTransform(translationX: 0, y: -10)
                self.upperTitleView?.alpha = 0
                UIView.animate(withDuration: 0.25) {
                    self.upperTitleView?.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.upperTitleView?.alpha = 1
                }
            }
            return
        }
        upperTitleView = navigationViewController?.titleView
    }
    
    public func setNavigationBarHidden(_ isHidden: Bool) {
        if isHidden {
            let retractionValue = (loginBarHeight + loginShadowHeight + scrollHeight + systemNavigationTotalHeight) * -1
            
            self.bar?.transform                     = CGAffineTransform(translationX: 0, y: retractionValue)
            self.infoContainerBar?.transform     = CGAffineTransform(translationX: 0, y: retractionValue)
            self.blurView?.transform                = CGAffineTransform(translationX: 0, y: retractionValue)
            self.bottomLine?.transform              = CGAffineTransform(translationX: 0, y: retractionValue)
            self.scrollBarContainer?.transform      = CGAffineTransform(translationX: 0, y: retractionValue)
            self.bottomTitleContainer?.transform    = CGAffineTransform(translationX: 0, y: retractionValue)
            return
        }
        self.bar?.transform                     = CGAffineTransform(translationX: 0, y: 0)
        self.infoContainerBar?.transform     = CGAffineTransform(translationX: 0, y: 0)
        self.blurView?.transform                = CGAffineTransform(translationX: 0, y: 0)
        self.bottomLine?.transform              = CGAffineTransform(translationX: 0, y: 0)
        self.scrollBarContainer?.transform      = CGAffineTransform(translationX: 0, y: 0)
        self.bottomTitleContainer?.transform    = CGAffineTransform(translationX: 0, y: 0)
    }
    
    public func willTransition(to newCollection: UITraitCollection,
                               with coordinator: UIViewControllerTransitionCoordinator,
                               navigationType: NavigationType,
                               completion: (()->())? = nil) {
        
        let retractionValue = (loginBarHeight + loginShadowHeight + scrollHeight + systemNavigationTotalHeight) * -1
        
        coordinator.animate(alongsideTransition: { context in
            self.bar?.transform                     = CGAffineTransform(translationX: 0, y: retractionValue)
            self.infoContainerBar?.transform     = CGAffineTransform(translationX: 0, y: retractionValue)
            self.blurView?.transform                = CGAffineTransform(translationX: 0, y: retractionValue)
            self.bottomLine?.transform              = CGAffineTransform(translationX: 0, y: retractionValue)
            self.scrollBarContainer?.transform      = CGAffineTransform(translationX: 0, y: retractionValue)
            self.bottomTitleContainer?.transform    = CGAffineTransform(translationX: 0, y: retractionValue)
        })
        
        delayInMilliseconds(250) {
            self.recreateNavigation(for: navigationType)
            completion?()
        }
    }
    
    // MARK: Public
    
    public func styling() {
        bar?.setBackgroundImage(UIImage(), for: .default)
        bar?.shadowImage = UIImage()
        bar?.isTranslucent = true
        bar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: viewConfiguration.tintColor]
        bar?.tintColor = viewConfiguration.tintColor
    }
    
    public func recreateNavigation(for navigationType: NavigationType) {
        styling()
        cleanView()
        prepareControllers()
        viewSetup()
        showBar(animated: true)
        delayInMilliseconds(500) {
            self.updateView(for: navigationType)
        }
    }
    
    public func changePrivacyBar(status: InfoBarStatus, completion:(()->())?) {
        privacyStatus = status
        
        switch privacyStatus {
        case .shown:
            revealPrivacyBar(completion: completion)
        default:
            hidePrivacyBar(completion: completion)
        }
    }
    
    public func updateView(for type:NavigationType) {
        // Update navigation title
        updateNavigationTitleView()
        switch type {
        case .plain:
            updateToPlainView()
        case .custom:
            updateToCustomView()
        case .privacyCategories:
            updateToCategories()
        }
    }
    
    public func showBottomTitleForLandscapeWithAnimation() {
        guard let bottomTitleContainer = bottomTitleView?.bottomTitleContainer, let loginBar = infoBar else {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            bottomTitleContainer.transform = CGAffineTransform(translationX: 0, y: 0 + self.currentPrivacyBarHeight)
            bottomTitleContainer.alpha = 1
            loginBar.layer.shadowOpacity = 1
            self.upperTitleView?.alpha = 0
        }
    }
    
    public func hideBottomTitleForLandscapeWithAnimation() {
        guard let bottomTitleContainer = bottomTitleView?.bottomTitleContainer, let loginBar = infoBar else {
            return
        }
        
        if stateConfiguration.categoryBarHidden == true {
            upperTitleView?.isHidden = false
            upperTitleView?.alpha = 0
        }
        
        UIView.animate(withDuration: 0.2) {
            bottomTitleContainer.transform = CGAffineTransform(translationX: 0, y: -40)
            bottomTitleContainer.alpha = 0
            loginBar.layer.shadowOpacity = 0
            
            if self.stateConfiguration.categoryBarHidden == true {
                self.upperTitleView?.alpha = 1
            }
        }
    }
    
    public func hideCategoriesForLandscape(animation:Bool) {
        if animation == false {
            collectionView?.slideOffWithoutAnimation()
            return
        }
        
        collectionView?.slideOffWithAnimation()
    }
    
    public func showCategoriesForLandscape(animation:Bool) {
        if animation == false {
            collectionView?.slideInWithoutAnimation()
            return
        }
        
        collectionView?.slideInWithAnimation()
    }
    
    public func showCategoriesForPortrait(animation:Bool) {
        guard let infoContainerBar = infoContainerBar else {
            return
        }
        
        var defaultValue:CGFloat = 0
        if infoContainerBar.transform.ty == 0.0 {
            defaultValue = scrollHeight
        }
        
        if infoContainerBar.frame.origin.y >= 108, infoContainerBar.transform.ty < 50.0 {
            defaultValue = 0
        }
        
        if let constraint = blurView?.constraints.first,
           constraint.constant == systemNavigationTotalHeight + scrollHeight,
           constraint.constant == infoContainerBar.frame.origin.y,
           infoContainerBar.transform.ty == 50.0 {
            defaultValue = scrollHeight
        }
        
        collectionView?.updateHeight(height:scrollHeight)
        blurView?.updateConstraint(attribute: .height, constant: currentNavigationHeight)
        
        if animation == false {
            self.infoContainerBar?.transform = CGAffineTransform(translationX: 0, y: defaultValue)
            self.bottomLine?.alpha = 0
            self.view?.layoutIfNeeded()
            self.collectionView?.loadCategories()
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.infoContainerBar?.transform = CGAffineTransform(translationX: 0, y: defaultValue)
            self.bottomLine?.alpha = 0
            self.view?.layoutIfNeeded()
        } completion: { _ in
            self.collectionView?.loadCategories()
        }
    }
    
    public func hideCategoriesForPortrait(animation:Bool) {
        guard let infoContainerBar = infoContainerBar else {
            return
        }
        
        var defaultValue:CGFloat = scrollHeight
        if infoContainerBar.transform.ty <= 50.0 {
            defaultValue = 0
        }
        
        if infoContainerBar.transform.ty < 50.0, infoContainerBar.frame.origin.y > systemNavigationTotalHeight {
            defaultValue = -scrollHeight
        }
        
        if let scrollBarHeight = collectionView?.currentScrollHeight,
           scrollBarHeight == 0,
           infoContainerBar.transform.ty < 0 {
            // scroll bar has been temorarily hidden
            // and privacy bar is in correct postion
            return
        }
        
        collectionView?.updateHeight(height:0)
        blurView?.updateConstraint(attribute: .height, constant: systemNavigationTotalHeight)
        
        if animation == false {
            self.infoContainerBar?.transform = CGAffineTransform(translationX: 0, y: defaultValue)
            self.bottomLine?.alpha = 1
            self.view?.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.infoContainerBar?.transform = CGAffineTransform(translationX: 0, y: defaultValue)
            self.bottomLine?.alpha = 1
            self.view?.layoutIfNeeded()
        }
    }
    
    // MARK: Private
    
    private func revealPrivacyBar(completion:(()->())?) {
        let constant = isLandscape ? loginShadowHeight : loginShadowHeight + loginBarHeight
        infoContainerBar?.updateConstraint(attribute: .height, constant: constant)
        UIView.animate(withDuration: 0.25) {
            self.infoBar?.transform = CGAffineTransform(translationX: 0, y: 0)
            if self.isLandscape {
                self.bottomTitleContainer?.transform = CGAffineTransform(translationX: 0, y: loginBarHeight)
            }
            self.view?.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    private func hidePrivacyBar(completion:(()->())?) {
        infoContainerBar?.updateConstraint(attribute: .height, constant: loginShadowHeight)
        UIView.animate(withDuration: 0.25) {
            self.infoBar?.transform = CGAffineTransform(translationX: 0, y: loginBarHeight * -1)
            if self.isLandscape {
                self.bottomTitleContainer?.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            self.view?.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    private func updateToPlainView() {
        upperTitleView?.alpha = 0
        infoBar?.layer.shadowOpacity = 0
        bottomTitleView?.hideWithAnimation {
            UIView.animate(withDuration: 0.2) {
                self.upperTitleView?.alpha = 1
            } completion: { _ in
                self.upperTitleView?.isHidden = false
            }
        }
    }
    
    private func updateToCustomView() {
        if !isLandscape {
            return
        }
        upperTitleView?.isHidden = true
        bottomTitleView?.showWithAnimation {
            self.infoBar?.layer.shadowOpacity = 1.0
        }
    }
    
    private func updateToCategories() {
        updateToCustomView()
        collectionView?.scrollBar?.reloadData()
    }
    
    private func updateNavigationTitleView() {
        bottomTitleLabel?.text = currentViewController?.title
        upperTitleView = navigationViewController?.titleView
        upperTitleView?.alpha = 0
        
        // Make sure the native title will not show up
        currentViewController?.navigationItem.title = ""
        // Assign upper title view to current view controller's navigation title item
        currentViewController?.navigationItem.titleView = upperTitleView
        
        UIView.animate(withDuration: 0.2) {
            self.upperTitleView?.alpha = 1
        }
    }
    
    private func prepareControllers() {
        let categoryViewController = CollectionView(stateConfiguration: stateConfiguration,
                                                    viewConfiguration: viewConfiguration)
        collectionView = categoryViewController
        collectionView?.dataSource = collectionViewControllerDataSource
        
        let privacyBarController = NavigationInfoBar(viewConfiguration: viewConfiguration)
        navigationPrivacyBar = privacyBarController
        
        let titleView = BottomTitleView(viewConfiguration: viewConfiguration)
        bottomTitleView = titleView
    }
    
    private func showTitleIfNeeded() {
        guard !stateConfiguration.titleHidden, isLandscape else { return }
        
        bottomTitleLabel?.isHidden = false
        infoBar?.layer.shadowOpacity = 1.0
    }
    
    private func hideTitleIfNeeded() {
        guard stateConfiguration.titleHidden, isLandscape else { return }
        
        bottomTitleLabel?.isHidden = true
        infoBar?.layer.shadowOpacity = 0.2
    }
    
    private func viewSetup() {
        // Privacy bar
        navigationPrivacyBar?.setup()
        bottomTitleView?.setup()
        collectionView?.setup()
        
        // main views
        blurView = _blurView
        bottomLine = _bottomLine
        
        // title view
        upperTitleView = navigationViewController?.titleView
    }
    
    private func cleanView() {
        blurView?.removeFromSuperview()
        blurView = nil
        
        bottomLine?.removeFromSuperview()
        bottomLine = nil
        
        upperTitleView?.removeFromSuperview()
        upperTitleView = nil
        
        bottomTitleView?.clean()
        collectionView?.clean()
        navigationPrivacyBar?.clean()
    }
    
    private func hideScrollView() {
        collectionView?.updateHeight(height:0)
        blurView?.updateConstraint(attribute: .height, constant: systemNavigationTotalHeight)
        infoContainerBar?.updateConstraints()
        if isLandscape == false {
            bottomLine?.alpha = 0
        }
        view?.layoutIfNeeded()
    }
    
    private func showBar(animated: Bool) {
        if isLandscape == true {
            self.showLandscapeNavigation(animated: animated)
            return
        }
        self.showPortraitNavigation(animated: animated)
    }
    
    private func showPortraitNavigation() {
        
        guard let bar = bar,
              let view = view,
              let minY = navigationViewController?.topPadding,
              let blurView = blurView,
              let separator = bottomLine,
              let scrollBarContainer = scrollBarContainer,
              let infoContainerBar = infoContainerBar else {
            return
        }
        
        bar.addSubview(blurView)
        bar.addConstraints(subview: blurView, top: minY, right: 0, bottom: nil, left: 0, height: currentScrollHeight + systemNavigationTotalHeight, width: nil)

        view.addSubview(separator)
        view.addConstraints(subview: separator, top: systemNavigationTotalHeight, right: 0, bottom: nil, left: 0, height: 1.0, width: nil)
        
        view.addSubview(scrollBarContainer)
        view.addConstraints(subview: scrollBarContainer, top: systemNavigationTotalHeight, right: 0, bottom: nil, left: 0, height: scrollHeight, width: nil)
        collectionView?.updateConstraints(height: scrollHeight, margin: 20.0)
        
        let yPos = blurView.constraint(attribute: .height)?.constant ?? 0
        view.addSubview(infoContainerBar)
        view.addConstraints(subview: infoContainerBar, top: yPos, right: 0, bottom: nil, left: 0, height: loginShadowHeight, width: nil)
        
        scrollBarContainer.layoutIfNeeded()
        collectionView?.upadateMask()
        
        if stateConfiguration.categoryBarHidden == true {
            hideScrollView()
            separator.alpha = 1
            return
        }
    }
    
    private func showPortraitNavigation(animated: Bool) {
        showPortraitNavigation()
        
        if animated == false {
            return
        }
        
        let retractionValue             = (loginBarHeight + loginShadowHeight + currentScrollHeight + systemNavigationTotalHeight) * -1
        blurView?.transform             = CGAffineTransform(translationX: 0, y: retractionValue)
        bottomLine?.transform           = CGAffineTransform(translationX: 0, y: retractionValue)
        scrollBarContainer?.transform   = CGAffineTransform(translationX: 0, y: retractionValue)
        infoContainerBar?.alpha      = 0

        UIView.animate(withDuration: 0.25) {
            self.bar?.transform                 = CGAffineTransform(translationX: 0, y: 0)
            self.blurView?.transform            = CGAffineTransform(translationX: 0, y: 0)
            self.bottomLine?.transform          = CGAffineTransform(translationX: 0, y: 0)
            self.scrollBarContainer?.transform  = CGAffineTransform(translationX: 0, y: 0)
            self.infoContainerBar?.alpha     = 1
        }
    }
    
    private func showLandscapeNavigation() {
        guard let bar = bar,
              let view = view,
              let minY = navigationViewController?.topPadding,
              let landscapeCategoryMargin = navigationViewController?.landscapeCategoryMargin,
              let blurView = blurView,
              let separator = bottomLine,
              let scrollBarContainer = scrollBarContainer,
              let infoContainerBar = infoContainerBar,
              let bottomTitleContainer = bottomTitleContainer else {
            return
        }
        
        bar.addSubview(blurView)
        bar.addConstraints(subview: blurView, top: 0, right: 0, bottom: nil, left: 0, height: systemNavigationTotalHeight, width: nil)
        
        view.addSubview(separator)
        view.addConstraints(subview: separator, top: systemNavigationTotalHeight, right: 0, bottom: nil, left: 0, height: 1.0, width: nil)
        
        let blurViewHeight = blurView.constraint(attribute: .height)?.constant

        view.addSubview(scrollBarContainer)
        let rightMargin = landscapeCategoryMargin * -1
        let leftMargin = landscapeCategoryMargin
        view.addConstraints(subview: scrollBarContainer, top: minY, right: rightMargin, bottom: nil, left: leftMargin, height: blurViewHeight, width: nil)
        collectionView?.updateConstraints(height: blurViewHeight ?? 0, margin: 40.0)
        
        view.addSubview(infoContainerBar)
        view.addConstraints(subview: infoContainerBar, top: blurViewHeight, right: 0, bottom: nil, left: 0, height: loginShadowHeight, width: nil)
        
        infoContainerBar.addSubview(bottomTitleContainer)
        infoContainerBar.addConstraints(subview: bottomTitleContainer, top:0, right: 0, bottom: 0, left: 0, height: nil, width: nil)
        
        scrollBarContainer.layoutIfNeeded()
        
        collectionView?.upadateMask()
        collectionView?.hideWithoutAnimationIfNeeded()
        hideTitleIfNeeded()
    }
    
    private func showLandscapeNavigation(animated: Bool) {
        showLandscapeNavigation()
        if animated == false {
            return
        }
        
        let retractionValue = (loginBarHeight + loginShadowHeight + systemNavigationTotalHeight) * -1
        infoContainerBar?.transform     = CGAffineTransform(translationX: 0, y: retractionValue)
        blurView?.transform                = CGAffineTransform(translationX: 0, y: retractionValue)
        scrollBarContainer?.transform      = CGAffineTransform(translationX: 0, y: retractionValue)
        bottomLine?.transform              = CGAffineTransform(translationX: 0, y: retractionValue)
        bottomTitleContainer?.transform    = CGAffineTransform(translationX: 0, y: retractionValue)
        
        UIView.animate(withDuration: 0.25) {
            self.bar?.transform                     = CGAffineTransform(translationX: 0, y: 0)
            self.infoContainerBar?.transform     = CGAffineTransform(translationX: 0, y: 0)
            self.blurView?.transform                = CGAffineTransform(translationX: 0, y: 0)
            self.scrollBarContainer?.transform      = CGAffineTransform(translationX: 0, y: 0)
            self.bottomLine?.transform              = CGAffineTransform(translationX: 0, y: 0)
            self.bottomTitleContainer?.transform    = CGAffineTransform(translationX: 0, y: 0)
            self.bottomLine?.alpha                  = 1
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool,
                                     navigationType: NavigationType) {
        currentViewController = viewController
        updateView(for: navigationType)
        bottomTitleView?.slideOffWithAnimation()
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool,
                                     navigationType: NavigationType) {
        UIView.animate(withDuration: 0.25) {
            self.upperTitleView?.alpha = 1
        } completion: { _ in
            self.bottomTitleView?.slideInWithAnimation()
        }
    }
}

// MARK: - Shortcuts
extension NavigationView {
    // MARK: Public
    public var currentNavigationHeight: CGFloat {
        systemNavigationTotalHeight + currentScrollHeight
    }
    
    public var systemNavigationContentHeight: CGFloat {
        navigationViewController?.contentHeight ?? 0
    }
    
    public var systemNavigationTotalHeight: CGFloat {
        navigationViewController?.totalHeight ?? 0
    }
    
    public var categoryavigationTotalHeight: CGFloat {
        systemNavigationTotalHeight + currentScrollHeight
    }
    
    public var categoryavigationContentHeight: CGFloat {
        systemNavigationContentHeight + currentScrollHeight
    }
    
    public var infoContainerBar: UIView? {
        navigationPrivacyBar?.infoContainerBar
    }
    
    // MARK: Private
    private var currentPrivacyBarHeight: CGFloat {
        return privacyStatus == .shown ? loginBarHeight : 0
    }
    
    private var infoBar: UIView? {
        navigationPrivacyBar?.infoBar
    }
    
    private var bar: UINavigationBar? {
        navigationViewController?.navigationBar
    }
    
    private var view: UIView? {
        navigationViewController?.view
    }
    
    private var bottomTitleContainer: UIView? {
        bottomTitleView?.bottomTitleContainer
    }
    
    private var bottomTitleLabel: UILabel? {
        bottomTitleView?.bottomTitleLabel
    }
    
    private var scrollBarContainer: UIView? {
        collectionView?.scrollBarContainer
    }
}

