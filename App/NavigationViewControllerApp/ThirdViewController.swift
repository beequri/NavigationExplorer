import UIKit
import NavigationExplorer

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let titles1 = ["Private and Categories", "Second Navigation View"]
    let titles2 = ["Hide Navigation", "Show Navigation"]
    let titles3 = ["Hide Categories", "Show Categories"]
    let titles4 = ["Remove Category", "Add Category"]
    let images1 = ["arrow.right.square", "rectangle.on.rectangle"]
    let images2 = ["rectangle","rectangle.topthird.inset"]
    let images3 = ["menubar.rectangle","macwindow"]
    let images4 = ["circle.dashed","circle"]
    
    var categories: Items = Items(selectedTags:[])
    var lastContentOffset: CGFloat = 0
    var infoBarStatus: InfoBarStatus  = .hidden
    var navigationViewController: NavigationViewController? {
        navigationController as? NavigationViewController
    }
    
    lazy var secondNavigationViewController: NavigationViewController? = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "Second Navigation") as? NavigationViewController
    }()
    
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
    
    private func showModalNavigationView() {
        guard let navigation = secondNavigationViewController else {
            return
        }
        navigation.modalPresentationStyle = .overFullScreen
        present(navigation, animated: false)
    }
}
extension ThirdViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            if let img = UIImage(systemName: images1[indexPath.row]) {
                cell.imageView?.image = img
                cell.tintColor = .black
            }
            cell.backgroundColor = .systemTeal
            cell.textLabel?.text = titles1[indexPath.row]
        } else if indexPath.section == 1 {
            if let img = UIImage(systemName: images2[indexPath.row]) {
                cell.imageView?.image = img
                cell.tintColor = .white
            }
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .systemPink
            cell.textLabel?.text = titles2[indexPath.row]
        } else if indexPath.section == 2 {
            if let img = UIImage(systemName: images3[indexPath.row]) {
                cell.imageView?.image = img
                cell.tintColor = .black
            }
            cell.backgroundColor = .lightGray
            cell.textLabel?.text = titles3[indexPath.row]
        } else {
            if let img = UIImage(systemName: images4[indexPath.row]) {
                cell.imageView?.image = img
                cell.tintColor = .black
            }
            cell.textLabel?.text = titles4[indexPath.row]
        }
        return cell
    }
}

extension ThirdViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                showModalNavigationView()
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
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                navigationViewController?.setCollectionScrollViewHidden(true)
            }
            
            if indexPath.row == 1 {
                navigationViewController?.setCollectionScrollViewHidden(false)
            }
        }
        
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                categories = Items(selectedTags: [])
                navigationViewController?.setCollectionScrollViewHidden(true)
            }
            
            if indexPath.row == 1 {
                categories = Items(selectedTags: [100])
                navigationViewController?.setCollectionScrollViewHidden(false)
            }
        }
    }
}

extension ThirdViewController:InfoBarDelegate {
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

extension ThirdViewController:CollectionViewDelegate {
    func collectionItems() -> [CollectionItem] {
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
            if self.tableView.contentOffset.y < 100 {
                self.tableView.setContentOffset(CGPoint(x:0, y: -1 * controller.expectedNavigationHeight), animated: true)
            }
        } completion: { _ in
            self.tableView.contentInset = UIEdgeInsets(top: controller.expectedTopOffset, left: 0, bottom: 0, right: 0)
        }
    }
    
    func didRequestTitleView() -> UIView? {
        NavigationTitleView.titleView(title: title ?? "not available", color: .systemPink)
    }
    
    func didRequestLeftBarButton() -> UIBarButtonItem? {
        nil
    }
}
