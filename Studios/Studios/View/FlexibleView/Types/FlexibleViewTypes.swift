//
//  FlexibleViewTypes.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.12.22.
//

import Foundation
import UIKit
import SnapKit

enum FlexibleViewTypes: String, CaseIterable {
    case date = "Выберите дату"
    case startTime = "Выберете время начала"
    case endTime = "Выберете время завершения"
    
    var viewDatePicker: UIDatePicker {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        return picker
    }
    
    var childView: UIView {
        let view = UIView()
        view.backgroundColor = .white
        switch self {
                
            case .date:
                break
            case .startTime:
//                let vc1 = ViewController5(nibName: String(describing: ViewController5.self), bundle: nil)
//                vc1.view.frame = view.bounds
//                view.addSubview(vc1.view)
          
                return view
            case .endTime:
//                let vc1 = ViewController5(nibName: String(describing: ViewController5.self), bundle: nil)
                //let bookVC = BookingStudioController(nibName: String(describing: BookingStudioController.self), bundle: nil)
//                bookVC.addChild(vc1)
//                vc1.view.frame = view.bounds
//                view.addSubview(vc1.view)
//                bookVC.didMove(toParent: vc1)
                return view
        }
        return UIView()
    }
    
     var collectionView: UICollectionView  {
            let layout = UICollectionViewFlowLayout()
            let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.register(HoursCell.self, forCellWithReuseIdentifier: String(describing: HoursCell.self))
        cv.backgroundColor = .clear

            return cv
        }
}
