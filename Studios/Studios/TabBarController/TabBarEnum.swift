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
    case profile = "Профиль"
    
    var viewController: UIViewController {
        switch self {
            case .studios:
                let mapVC = MapController()
                return mapVC
            case .favorite:
                let vc = LikedStudiosViewController(nibName: String(describing: LikedStudiosViewController.self), bundle: nil)
                return self.wrappedInNavigationController(with: vc)
            case .booking:
                let vc = BookingHistoryController(nibName: String(describing: BookingHistoryController.self), bundle: nil)
                return self.wrappedInNavigationController(with: vc)
            case .profile:
                let vc = ProfileViewController(nibName: String(describing: ProfileViewController.self), bundle: nil)
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
            case .profile:
                return UIImage(systemName: "person.circle")!
        }
    }
    
    private func wrappedInNavigationController(with: UIViewController) -> UINavigationController {
         UINavigationController(rootViewController: with)
    }
}
