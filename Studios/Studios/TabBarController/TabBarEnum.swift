//
//  TabBarEnum.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 20.12.22.
//

import Foundation
import UIKit

enum TabItem: String, CaseIterable {
    case studios = "Студии"
    case favorite = "Избранное"
    case booking = "Бронирования"
    case test = "Test"
    case test1 = "Test1"
    
    var viewController: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch self {
            case .studios:
                let mapVC = storyboard.instantiateViewController(withIdentifier: "ViewController")
                return mapVC
            case .favorite:
                let vc = LikedStudiosViewController(nibName: String(describing: LikedStudiosViewController.self), bundle: nil)
                return self.wrappedInNavigationController(with: vc)
            case .booking:
                let vc = BookingHistoryController(nibName: String(describing: BookingHistoryController.self), bundle: nil)
                return self.wrappedInNavigationController(with: vc)
            case .test:
                let vc = ProfileViewController(nibName: String(describing: ProfileViewController.self), bundle: nil)
                return self.wrappedInNavigationController(with: vc)
            case .test1:
                let vc = Test2ViewController(nibName: String(describing: Test2ViewController.self), bundle: nil)
                return self.wrappedInNavigationController(with: vc)
        }
    }
    
    var iconImage: UIImage {
        switch self {
            case .studios:
                return UIImage(systemName: "mappin.circle")!
            case .favorite:
                return UIImage(systemName: "heart.circle")!
            case .booking:
                return UIImage(systemName: "calendar.circle")!
            case .test:
                return UIImage(systemName: "square.and.arrow.down.on.square")!
            case .test1:
                return UIImage(systemName: "square.and.arrow.down.on.square")!
            
        }
    }
    
    private func wrappedInNavigationController(with: UIViewController) -> UINavigationController {
         UINavigationController(rootViewController: with)
    }
}
