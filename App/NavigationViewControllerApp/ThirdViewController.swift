import UIKit
import NavigationExplorer

class ThirdViewController: TableViewController {
    
    var lastContentOffset: CGFloat = 0
    
    override func loadView() {
        super.loadView()
        infoBarStatus = .shown
        title = "Third view controller"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Second view controller")
        navigationViewController?.type = .privacyCategories
        navigationViewController?.navigationDelegate = self
        navigationViewController?.infoBarDelegate = self
        navigationViewController?.collectionViewDelegate = self
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
