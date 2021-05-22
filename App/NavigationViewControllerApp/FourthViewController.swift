import UIKit
import NavigationExplorer

class FourthViewController: TableViewController {
    
    override func loadView() {
        super.loadView()
        infoBarStatus = .shown
        title = "Fourth view controller"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Fourth view controller")
        navigationViewController?.type = .privacyCategories
        navigationViewController?.navigationDelegate = self
        navigationViewController?.collectionViewDelegate = self
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

extension FourthViewController:CollectionViewDelegate {
    func didSelectCollectionItem(controller: CollectionNavigationController, tag: Int) {
        //
    }
    
    func didDeselectCollectionItem(controller: CollectionNavigationController, tag: Int) {
        //
    }
    
    func collectionItems() -> [CollectionItem] {
        let categories = Items(selectedTags:[100,101,102,103,104,105,106,107])
        return categories.selected
    }
}

extension FourthViewController:InfoBarDelegate {
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
