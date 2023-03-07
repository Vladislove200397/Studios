//
//  TableViewCellTypes.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 26.02.23.
//

import UIKit

enum TableViewCellTypes: CaseIterable {
    case profile
    case profileSettings
    case photography
    case likedStudios
    case bookingHistory
    case exit
    case sendEmailToDev
    
    var cellImage: UIImage {
        switch self {
            case .profileSettings:          return UIImage(systemName: "gear.circle")!
            case .photography:              return UIImage(systemName: "camera.circle")!
            case .likedStudios:             return UIImage(systemName: "heart")!
            case .bookingHistory:           return UIImage(systemName: "clock")!
            case .exit:                    return UIImage(systemName: "door.left.hand.open")!
            case .sendEmailToDev:           return UIImage(systemName: "message.circle")!
            default: return UIImage()
        }
    }
    
    var title: String {
        switch self {
            case .profileSettings:          return "Редактировать профиль"
            case .photography:              return "Мои фотосессии"
            case .likedStudios:             return "Избранные студии"
            case .bookingHistory:           return "История бронирований"
            case .exit:                    return "Выход"
            case .sendEmailToDev:           return "Написать разработичку"
            default: return ""
        }
    }
    
    var controllers: UIViewController {
        switch self {
            case .profileSettings:
                let profileEditVC = ProfileEditViewController(nibName: String(describing: ProfileEditViewController.self), bundle: nil)
                return profileEditVC
            default:
                return UIViewController()
        }
    }
}
