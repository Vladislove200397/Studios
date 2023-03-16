//
//  FlexibleViewTypes.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.12.22.
//

import Foundation
import UIKit
import SnapKit

//Скорее всего будет удалено
enum FlexibleViewTypes: String, CaseIterable {
    case date = "Выберите дату"
    case time = "Time"
    
    var viewDatePicker: UIDatePicker {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        return picker
    }
    
    var childView: UIView {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
}
