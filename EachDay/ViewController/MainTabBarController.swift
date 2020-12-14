//
//  MainTabBarController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBadge()
    }
    
    func configureBadge() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge(_:)), name: Notifications.receiveTimeCapsule, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge(_:)), name: Notifications.dismissTimeCapsule, object: nil)
    }
    
    @objc func updateBadge(_ notification: Notification) {
        if let tabItems = self.tabBar.items {
            let tabItem = tabItems[0]
            if notification.name == Notifications.receiveTimeCapsule {
                tabItem.badgeValue = "1"
            } else {
                tabItem.badgeValue = nil
            }
            tabItem.badgeColor = UIColor(r: 247, g: 174, b: 0)
        }
    }
    
}
