import UIKit
import NavigationExplorer

class SixthViewController: UIViewController {
    
    var lastContentOffset: CGFloat = 0
    var infoBarStatus: InfoBarStatus  = .hidden
    
    var navigationViewController: NavigationViewController? {
        navigationController as? NavigationViewController
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let config = NavigationInterfaceConfiguration()
        config.infoIcon = UIImage(systemName: "wifi.exclamationmark")
        config.tintColor = .systemRed
        config.infoViewFirstText = "No network"
        config.infoViewSecondText = "Tap to reconnect"
        config.shadowHidden = true
        
        navigationViewController?.configuration = config
    }
    
    override func loadView() {
        super.loadView()
        title = "Sixth view controller"
        
        navigationViewController?.view.alpha = 0
        view.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Sixth view controller")
        
        navigationViewController?.type = .plain
        navigationViewController?.navigationDelegate = self
        navigationViewController?.infoBarDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.35) {
            self.navigationViewController?.view.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                self.view.alpha = 1
            }
        }

        
        NotificationCenter.default.post(name: .didAppearSixthView, object: nil)
    }
    
    @objc private func dismissModalNavigationView() {
        UIView.animate(withDuration: 0.5) {
            self.navigationViewController?.view.alpha = 0
            self.view.backgroundColor = .clear
        } completion: { _ in
            self.dismiss(animated: true)
        }
    }
}

extension SixthViewController:NavigationControllerDelegate {
    func navigationDidAppear(controller: PlainNavigationController) {
        //
    }
    
    func navigationDidUpdate(controller: PlainNavigationController) {
        //
    }
    
    func didRequestTitleView() -> UIView? {
        NavigationTitleView.titleView(title: title ?? "not available", color: .systemPink)
    }
    
    func didRequestLeftBarButton() -> UIBarButtonItem? {
        UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(dismissModalNavigationView))
    }
}

extension SixthViewController:InfoBarDelegate {
    func didRequestInfoBarStatus() -> InfoBarStatus {
        infoBarStatus
    }
    
    func didRequestToHideInfoBar() {
        infoBarStatus = .hidden
        navigationViewController?.evaluateInfoBarStatus()
    }
    
    func didChangeInfoBarStatus(infoBarStatus: InfoBarStatus) {
        //
    }
}
