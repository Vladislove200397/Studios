//
//  UIViewExtension.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 22.12.22.
//

import Foundation
import UIKit

extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func setGradientBackground(topColor: CGColor, bottomColor: CGColor) {
        let colorTop =  topColor
        let colorBottom = bottomColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 0.5]
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func addBlurredBackground(style: UIBlurEffect.Style, alpha: Double,blurColor: UIColor) {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        customBlurEffectView.frame =  self.bounds
        customBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let dimmedDraw = UIView()
        dimmedDraw.backgroundColor = blurColor.withAlphaComponent(alpha)
        dimmedDraw.frame =  self.frame
        dimmedDraw.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(customBlurEffectView)
        self.addSubview(dimmedDraw)
    }
    
    func addCellGradientBackground(topColor: CGColor, bottomColor: CGColor) {
        let colorTop =  topColor
        let colorBottom = bottomColor
        
        let gradientLayer = CAGradientLayer()
        clipsToBounds = true
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 0.5]
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at:0)
    }
}
