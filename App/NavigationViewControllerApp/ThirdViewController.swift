import UIKit
import NavigationExplorer

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var lastContentOffset: CGFloat = 0
    var infoBarStatus: InfoBarStatus  = .hidden
    var navigationViewController: NavigationViewController? {
        navigationController as? NavigationViewController
    }
    
    lazy var innerViewController: SixthViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "Sixth View Controller") as SixthViewController
        return controller
    }()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewController), name: .didAppearSixthView, object: nil)
        infoBarStatus = .shown
        title = "Third view controller"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Third view controller")
        navigationViewController?.type = .privacyCategories
        navigationViewController?.navigationDelegate = self
        navigationViewController?.infoBarDelegate = self
        navigationViewController?.collectionViewDelegate = self
    }
    
    // MARK: Actions
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Private
    @objc private func updateViewController() {
        navigationViewController?.titleView?.isHidden = true
        let leftButton = UIBarButtonItem.backButton(target: self, action: #selector(dismissInnerView))
        navigationItem.setLeftBarButton(leftButton, animated: true)
    }
    
    @objc private func dismissInnerView() {
        UIView.animate(withDuration: 0.35) {
            self.innerViewController.view.transform = CGAffineTransform(translationX: 0, y: 1000)
        } completion: { _ in
            self.navigationViewController?.type = .privacyCategories
            self.navigationViewController?.navigationDelegate = self
            self.navigationViewController?.infoBarDelegate = self
            self.navigationViewController?.collectionViewDelegate = self
            
            self.innerViewController.view.removeFromSuperview()
            self.innerViewController.removeFromParent()
            self.navigationItem.setLeftBarButton(nil, animated: true)
            self.title = "Third view controller"
            self.navigationViewController?.requestToUpdateTitleView(animated: true)
        }
    }
    
    private func showInnerView() {
        addChild(innerViewController)
        view.addSubview(innerViewController.view)
        navigationViewController?.type = .plain
        navigationViewController?.navigationDelegate = self
        navigationViewController?.requestToUpdateTitleView(animated: true)
        title = "Sixth view"
    }
}
extension ThirdViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "hello"
        return cell
    }
}

extension ThirdViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                showInnerView()
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                navigationViewController?.setNavigationBarHidden(true, animated: true)
            }
            
            if indexPath.row == 1 {
                navigationViewController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }
}

extension ThirdViewController:InfoBarDelegate {
    func didRequestInfoBarStatus() -> InfoBarStatus {
        infoBarStatus
    }
    
    func didRequestToHideInfoBar(controller: PlainNavigationController) {
        infoBarStatus = .hidden
        controller.evaluateInfoBarStatus()
    }
    
    func didChangeInfoBarStatus(controller: PlainNavigationController, infoBarStatus: InfoBarStatus) {
        //
    }
}

extension ThirdViewController:CollectionViewDelegate {
    func collectionItems() -> [CollectionItem] {
        let categories = Items(selectedTags:[])
        return categories.selected
    }
    
    func didSelectCollectionItem(controller: CollectionNavigationController, tag: Int) {
        //
    }
    
    func didDeselectCollectionItem(controller: CollectionNavigationController, tag: Int) {
        //
    }
}

extension ThirdViewController:NavigationControllerDelegate {
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
