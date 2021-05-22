import UIKit
import NavigationExplorer

class FirstViewController: TableViewController {
    
    lazy var innerViewController: InnerViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "Inner View Controller") as InnerViewController
        return controller
    }()
    
    @IBOutlet weak var sheetButton: UIBarButtonItem!
    var lastContentOffset: CGFloat = 0
    
    override func loadView() {
        super.loadView()
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewController), name: .didAppearInnerView, object: nil)
        title = "Hi, this is long title to see how it fits"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationViewController?.type = .plain
        navigationViewController?.navigationDelegate = self
        navigationViewController?.infoBarDelegate = self
    }
    
    // MARK: Actions
    
    @IBAction func didPressShowInfoBarButton(_ sender: Any) {
        infoBarStatus = .shown
        navigationViewController?.evaluateInfoBarStatus()
    }
    
    @IBAction func didPressHideInfoBarButton(_ sender: Any) {
        infoBarStatus = .hidden
        navigationViewController?.evaluateInfoBarStatus()
    }
    
    // MARK: Private
    @objc private func updateViewController() {
        navigationViewController?.titleView?.isHidden = true
        sheetButton.isEnabled = false
        let leftButton = UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(dismissInnerView))
        navigationItem.setLeftBarButton(leftButton, animated: true)
    }
    
    @objc private func dismissInnerView() {
        UIView.animate(withDuration: 0.35) {
            self.innerViewController.view.transform = CGAffineTransform(translationX: 0, y: 1000)
        } completion: { _ in
            self.innerViewController.view.removeFromSuperview()
            self.innerViewController.removeFromParent()
            self.navigationItem.setLeftBarButton(nil, animated: true)
            self.title = "Hi, this is long title to see how it fits"
            self.navigationViewController?.requestToUpdateTitleView(animated: true)
        }
    }
    
    private func showInnerView() {
        addChild(innerViewController)
        view.addSubview(innerViewController.view)
        innerViewController.view.transform = CGAffineTransform(translationX: 0, y: 1000)
        UIView.animate(withDuration: 0.35) {
            self.innerViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
        } completion: { _ in
            self.title = "Inner view"
            self.navigationViewController?.requestToUpdateTitleView(animated: true)
        }
    }
    
    private func hideNavigation() {
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: ScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let yPos = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y
        
        switch scrollView.panGestureRecognizer.state {
        case .began:
            break
        case .changed:
            if abs(yPos) < 50 {
                return
            }
            
            if self.lastContentOffset < scrollView.contentOffset.y {
                // did move up
                navigationViewController?.adjustNavigationIfNeeded(action: .hide)
            } else if self.lastContentOffset > scrollView.contentOffset.y {
                // did move down
                navigationViewController?.adjustNavigationIfNeeded(action: .show)
            }
            
            break
        default:            
            break
        }
    }
    
    // MARK: - Override NavigationControllerDelegate
    override func didRequestLeftBarButton() -> UIBarButtonItem? {
        nil
    }
}

extension FirstViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                showInnerView()
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                didPressShowInfoBarButton(self)
            }
            if indexPath.row == 1 {
                didPressHideInfoBarButton(self)
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                navigationViewController?.setNavigationBarHidden(true, animated: true)
            }
            
            if indexPath.row == 1 {
                navigationViewController?.setNavigationBarHidden(false, animated: true)
            }
            
            if indexPath.row == 2 {
                navigationViewController?.infoBar?.userInteractionEnabled = false
                navigationViewController?.rightBarButtonButton?.isEnabled = false
            }
            if indexPath.row == 3 {
                navigationViewController?.infoBar?.userInteractionEnabled = true
                navigationViewController?.rightBarButtonButton?.isEnabled = true
            }
        }
        if indexPath.section == 3 {
            if indexPath.row == 1 {
                title = "updated title"
                navigationViewController?.requestToUpdateTitleView(animated: true)
            }
        }
    }
}

extension FirstViewController:InfoBarDelegate {
    func didRequestInfoBarStatus() -> InfoBarStatus {
        infoBarStatus
    }
    
    func didRequestToHideInfoBar() {
        infoBarStatus = .hidden
        navigationViewController?.evaluateInfoBarStatus()
    }
    
    func didChangeInfoBar(status: InfoBarStatus) {
        //
    }
}

extension UIViewController {
    var isLandscape: Bool {
        return statusBarOrientation?.isLandscape ?? false
    }
    
    var statusBarOrientation: UIInterfaceOrientation? {
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
}

func delayInMilliseconds(_ milliseconds: Int, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds)) {
        block()
    }
}
