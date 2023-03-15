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
    @IBOutlet var stackLabelArray: [UILabel]!
    @IBOutlet var syackImageArray: [UIImageView]!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var flexibleView: FlexView!
    
    var studio: GMSPlace?
    private var flexViewHandler: VoidBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStack()
        studioIsOpen(studio: studio)
        flexibleView.set(delegate: self, type: .date)
    }
    
    func setVc(studio: GMSPlace, flexViewHandler: VoidBlock?) {
        self.studio = studio
        self.flexViewHandler = flexViewHandler
    }
    
    private func setupStack() {
        guard let studio else { return }
        stackLabelArray.enumerated().forEach { index,label in
            switch index {
                case 0:
                    label.text = studio.formattedAddress
                case 1:
                    label.text = studio.phoneNumber
                case 2:
                    label.text = studio.website?.absoluteString ?? "Сайт недоступен"
                case 3:
                    label.text = "\(studio.rating)"
                default:
                    break
            }
        }
        
        syackImageArray.enumerated().forEach { index, image in
            switch index {
                case 0:
                    image.image = UIImage(systemName: "house")
                case 1:
                    image.image = UIImage(systemName: "phone")
                case 2:
                    image.image = UIImage(systemName: "network")
                case 3:
                    image.image = UIImage(systemName: "star")
                default:
                    break
            }
        }
        let rating = studio.rating
        ratingView.settings.fillMode = .half
        ratingView.rating = Double(rating)
    }
    
    private func studioIsOpen(studio: GMSPlace?) {
        guard let studio,
              let openingHours = studio.openingHours,
              let _ = studio.utcOffsetMinutes,
              let numberOfDay = Calendar.current.ordinality(of: .weekday, in: .weekOfYear, for: .now),
              let weekdayText = openingHours.weekdayText else { return }
        
        let weekdayTextString: String = weekdayText[numberOfDay-1]
        let numbers = weekdayTextString.components(separatedBy: ["–", " "])
        let isOpenNow = studio.isOpen()
        //        let futureTime = Date.now
        //        let isOpenAtTime = studio.isOpen(at: futureTime)
        
//        switch isOpenNow {
//            case .unknown:
//                openStatusLabel.text = "Неизвестно"
//            case .open:
//                let openColor = UIColor(hue: 0.38, saturation: 0.72, brightness: 0.72, alpha: 1.0)
//                let string = "Открыто • Закроется в \(numbers[2])"
//                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
//                attributedString.setColor(color: openColor, forText: "Открыто")
//                openStatusLabel.attributedText = attributedString
//
//            case .closed:
//                let closedColor = UIColor(hue: 0.01, saturation: 0.64, brightness: 0.75, alpha: 1.0)
//                let string = "Закрыто • Откроется в \(numbers[2])"
//                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
//                attributedString.setColor(color: closedColor, forText: "Закрыто")
//                openStatusLabel.attributedText = attributedString
//
//            default:
//                break
//        }
    }
}

    extension InfoViewController: FlexibleViewDelegate {
        func viewDidOpen(type: FlexibleViewTypes) {
    //        flexViews.forEach { flexibleView in
    //            if flexibleView.type != type {
    //                flexibleView.collapse()
    //            }
    //        }
            flexViewHandler?()
        }
    }
