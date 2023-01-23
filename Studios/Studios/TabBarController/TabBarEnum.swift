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
                let tableVC = storyboard.instantiateViewController(withIdentifier: String(describing: StudiosTableViewController.self))
                return tableVC
            case .booking:
                return BookingHistoryController(nibName: String(describing: BookingHistoryController.self), bundle: nil)

            case .test:
                return ViewController5(nibName: String(describing: ViewController5.self), bundle: nil)
            case . test1:
                return ViewController3(nibName: String(describing: ViewController3.self), bundle: nil)
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
}
