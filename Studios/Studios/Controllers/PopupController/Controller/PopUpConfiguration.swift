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
    var titleColor: UIColor = .black
    var titleFont: UIFont = UIFont.systemFont(ofSize: 17, weight: .bold)
    
    var description = "Test"
    var descriptionColor: UIColor = .black
    var descriptionFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .thin)
    
    var image: UIImage?
    var style: PopUpTypes = .info
    
    var buttonFonts: UIFont = UIFont.boldSystemFont(ofSize: 15)
    
    var imageTintColor: UIColor = .lightGray
    
    var backgroundColor: UIColor = .white
    var buttonBackgroundColor: UIColor = .lightGray.withAlphaComponent(0.8)
    var confirmButtonTintColor: UIColor = .white
    var dismissButtonTintColor: UIColor = .white
    var cancelButtonTintColor: UIColor = .white
}
