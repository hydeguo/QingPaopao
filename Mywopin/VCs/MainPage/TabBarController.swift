//
//  TabBarController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/12.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation


class TabBarController: UITabBarController, UITabBarControllerDelegate {

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        print("Selected item"+item.title!)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("Selected view controller")
    }

}
