//
//  PopUpConfiguration.swift
//  UniversalPopUp
//
//  Created by Vlad Kulakovsky  on 14.02.23.
//

import UIKit

struct PopUpConfiguration {
    static var standart = PopUpConfiguration()
    
    var confirmButtonTitle = "OK"
    var dismissButtonTitle = "Cancel"
    var inputPlaceHolder = "Input text here"
    var cancelButtonTitle = "Cancel"
    
    var title = "Test"
    var titleColor: UIColor = .white
    var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 18)
    
    var description = "Test"
    var descriptionColor: UIColor = .white
    var descriptionFont: UIFont = UIFont.boldSystemFont(ofSize: 18)
    
    var image: UIImage?
    var style: PopUpTypes = .info
    
    var buttonFonts: UIFont = UIFont.boldSystemFont(ofSize: 18)
    
    var imageTintColor: UIColor = .lightGray
    
    var backgroundColor: UIColor = .white
    var buttonBackgroundColor: UIColor = .blue
    var confirmButtonTintColor: UIColor = .white
    var dismissButtonTintColor: UIColor = .white
    var cancelButtonTintColor: UIColor = .white
}
