import UIKit

class SixthViewController: UIViewController {
    
    var lastContentOffset: CGFloat = 0
    
    override func loadView() {
        super.loadView()
        title = "Sixth view controller"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Sixth view controller")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: .didAppearSixthView, object: nil)
    }
}
