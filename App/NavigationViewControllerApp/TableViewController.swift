import UIKit
import NavigationExplorer

class TableViewController: UITableViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: Actions
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension TableViewController:NavigationControllerDelegate {
    func navigationDidAppear(controller: PlainNavigationController) {
        //
    }
    
    func navigationDidUpdate(controller: PlainNavigationController) {
        UIView.animate(withDuration: 0.25) {
            self.tableView.contentInset = UIEdgeInsets(top: controller.expectedTopOffset, left: 0, bottom: 0, right: 0)
        } completion: { _ in
            if self.tableView.contentOffset.y < 100 {
                self.tableView.setContentOffset(CGPoint(x:0, y: -1 * controller.expectedNavigationHeight), animated: true)
            }
        }
    }
    
    func didRequestTitleView() -> UIView? {
        NavigationTitleView.titleView(title: title ?? "not available", color: .systemPink)
    }
    
    func didRequestLeftBarButton() -> UIBarButtonItem? {
        nil
    }
}
