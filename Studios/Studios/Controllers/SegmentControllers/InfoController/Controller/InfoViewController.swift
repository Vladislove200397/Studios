//
//  InfoViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 22.11.22.
//

import UIKit
import GooglePlaces
import Cosmos

class InfoViewController: UIViewController {
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet var stackLabelArray: [UILabel]!
    @IBOutlet var syackImageArray: [UIImageView]!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var studio: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStack()
        studioIsOpen(studio: studio)
    }

    func setVc(studio: GMSPlace) {
        self.studio = studio
    }

    private func setupStack() {
        guard let studio else { return }
        stackLabelArray.enumerated().forEach { index,label in
            switch index {
                case 0:
                    label.text = studio.formattedAddress
                case 2:
                    label.text = studio.phoneNumber
                case 3:
                    label.text = studio.website?.absoluteString ?? "Сайт недоступен"
                default:
                    break
            }
        }
        
        syackImageArray.enumerated().forEach { index, image in
            switch index {
                case 0:
                    image.image = UIImage(systemName: "house")
                case 1:
                    image.image = UIImage(systemName: "clock")
                case 2:
                    image.image = UIImage(systemName: "phone")
                case 3:
                    image.image = UIImage(systemName: "network")
                case 4:
                    image.image = UIImage(systemName: "star")
                default:
                    break
            }
        }
        let rating = studio.rating
        ratingView.settings.fillMode = .half
        ratingView.rating = Double(rating)
        ratingLabel.text = "\(rating)"
    }
    
    private func studioIsOpen(studio: GMSPlace?) {
        guard let studio else { return }
        
        let isOpen = studio.isOpen(at: Date.now)
        guard let openingHoursArr = studio.openingHours?.periods else { return }
        let calendarDay = Calendar.current.dateComponents( [.weekday], from: Date.now)
        var closeHour: UInt?
        var closeMinute: UInt?
        var openHour: UInt?
        var openMinute: UInt?
        
        openingHoursArr.enumerated().forEach { (index, value) in
            if index+1 == calendarDay.weekday {
                closeHour = value.closeEvent?.time.hour
                closeMinute = value.closeEvent?.time.minute
                openHour = value.openEvent.time.hour
                openMinute = value.openEvent.time.minute
            }
        }
        
        guard let closeHour,
              let closeMinute,
              let openHour,
              let openMinute else { return }
        
        switch isOpen {
            case .unknown:
                stackLabelArray[1].text = "Неизвестно"
            case .open:
                stackLabelArray[1].text = "Открыто • Закроется в \(closeHour):0\(closeMinute)"
            case .closed:
                stackLabelArray[1].text = "Закрыто • Откроется в \(openHour):0\(openMinute)"
            default:
                break
        }
    }
}

