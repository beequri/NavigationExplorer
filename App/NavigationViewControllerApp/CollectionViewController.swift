import UIKit
import NavigationExplorer

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var infoBarStatus: InfoBarStatus  = .hidden
    let colors:[UIColor] = [
        .systemRed, .systemPink, .systemBlue, .systemTeal, .systemGray, .systemGreen,
        .systemOrange, .systemYellow, .systemPurple, .systemIndigo, .systemGray5, .systemGray3,
        .black, .brown
    ]
    
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
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: Bundle(for: self.classForCoder))
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }
    
    // MARK: Actions
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension  CollectionViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        44
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.backgroundColor = colors.randomElement()!
        return cell
    }
}

extension CollectionViewController:NavigationControllerDelegate {
    func navigationDidAppear(controller: PlainNavigationController) {
        //
    }
    
    func navigationDidUpdate(controller: PlainNavigationController) {
        UIView.animate(withDuration: 0.25) {
            self.collectionView.contentInset = UIEdgeInsets(top: controller.expectedTopOffset, left: 0, bottom: 0, right: 0)
        } completion: { _ in
            if self.collectionView.contentOffset.y < 100 {
                self.collectionView.setContentOffset(CGPoint(x:0, y: -1 * controller.expectedNavigationHeight), animated: true)
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
