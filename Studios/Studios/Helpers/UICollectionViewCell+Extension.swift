//
//  UICollectionViewCell+Extension.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 4.03.23.
//

import UIKit


extension UICollectionViewCell {
    func addShadow(corner: CGFloat = 10, color: UIColor = .black, radius: CGFloat = 15, offset: CGSize = CGSize(width: 0, height: 0), opacity: Float = 0.2) {
        layer.cornerRadius = corner
        layer.borderWidth = 0.0
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
}
