//
//  SceneDelegate.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 8.11.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let readDF = UserDefaults.standard

        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: windowScene)
            window?.windowScene = windowScene
            checkToken()
            window?.makeKeyAndVisible()
    }

    func setTabBarIsInitial() {
        let tabBar = TabBarController(nibName: String(describing: TabBarController.self), bundle: nil)
        window?.rootViewController = UINavigationController(rootViewController: tabBar)
    }
    
    func setLoginIsInitial() {
        window?.rootViewController = UINavigationController(rootViewController: TestController(nibName: String(describing: TestController.self), bundle: nil))
        
    }
    
    private func checkToken() {
        if readDF.value(forKey: "uid") != nil {
            setTabBarIsInitial()
        } else {
            setLoginIsInitial()
        }
    }
}