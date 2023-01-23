//
//  TabBarController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 20.12.22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

class TabBarController: UITabBarController {
    
    let dataSource = TabItem.allCases
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurateTabBar()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        guard let index = tabBar.items?.firstIndex(of: item),
              tabBar.subviews.count > index + 1,
              let imageView = tabBar.subviews[index + 1].subviews.compactMap({ $0 as? UIImageView }).first else { return }

        imageView.layer.add(bounceAnimation, forKey: nil)
        hapticAlternative()
    }
    
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.3, 0.9, 1.0]
        bounceAnimation.duration = 0.3
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()
    
    private func configurateTabBar() {
        var controllers: [UIViewController] = []
        
        dataSource.forEach { controller in
            controllers.append(controller.viewController)
        }
        
        viewControllers = controllers
        tabBar.tintColor = .red
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.backgroundColor = .white
        tabBar.alpha = 0.9
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
        
        viewControllers?.enumerated().forEach({ index, controller in
            controller.tabBarItem = UITabBarItem(title: dataSource[index].rawValue, image: dataSource[index].iconImage, tag: dataSource[index].hashValue)
        })
    }
    
    private func hapticAlternative() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    private func wrappedInNavigationController(with: UIViewController) -> UINavigationController {
         UINavigationController(rootViewController: with)
    }
}
