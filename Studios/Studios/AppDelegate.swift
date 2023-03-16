//
//  AppDelegate.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 8.11.22.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(Constants.GMSMAPSAPIKEY)
        GMSPlacesClient.provideAPIKey(Constants.GMSPLACESAPIKEY)
        FirebaseApp.configure()
        setAppereanse()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func setAppereanse() {
        UITabBar.appearance().barTintColor = .blue
        UITabBar.appearance().tintColor = .red
        UITabBar.appearance().isTranslucent = true

        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            
            navigationBarAppearance.configureWithTransparentBackground()
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            
            let blurEffect = UIBlurEffect(style: .dark)
            let appearance = UITabBarAppearance()
            
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = blurEffect
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = UITabBar.appearance().standardAppearance
        }
    }
}

