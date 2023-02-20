//
//  TabBarController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 20.12.22.
//

import UIKit


class TabBarController: UITabBarController {
    
    let dataSource = TabItem.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurateTabBar()
    }

    func configurateTabBar() {
        var controllers: [UIViewController] = []
        
        dataSource.forEach { controller in
            controllers.append(controller.viewController)
        }
        
        viewControllers = controllers
        tabBar.tintColor = .red
        tabBar.unselectedItemTintColor = .lightGray
        
        viewControllers?.enumerated().forEach({ index, controller in
            controller.tabBarItem = UITabBarItem(title: dataSource[index].rawValue, image: dataSource[index].iconImage, tag: dataSource[index].hashValue)
        })
    }
}
