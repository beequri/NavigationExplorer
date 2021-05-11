import UIKit
import NavigationExplorer

class FifthViewController: TableViewController {
    override func loadView() {
        super.loadView()
        infoBarStatus = .shown
        title = "Fifth view controller"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationViewController?.type = .custom
        navigationViewController?.navigationDelegate = self
        navigationViewController?.infoBarDelegate = self
    }
    
    // MARK: ScrollViewDelegate
    var lastContentOffset: CGFloat = 0
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
//            if self.lastContentOffset < scrollView.contentOffset.y {
//                // did move up
//                categoryNavigationController?.hideScrollView()
//            } else if self.lastContentOffset > scrollView.contentOffset.y {
//                // did move down
//            } else {
//                categoryNavigationController?.revealScrollView()
//            }
            
            break
        }
    }
}

extension FifthViewController:InfoBarDelegate {
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
