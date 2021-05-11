//
//  InnerViewController.swift
//  NavigationViewControllerApp
//
//  Created by beequri on 29.04.21.
//

import UIKit

extension Notification.Name {
    static let didAppearInnerView = Notification.Name("didAppearInnerView")
    static let didAppearSixthView = Notification.Name("didAppearSixthView")
}

class InnerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .didAppearInnerView, object: nil)
    }

}
