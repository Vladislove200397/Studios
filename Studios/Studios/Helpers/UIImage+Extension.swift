//
//  UIImageExtension.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 21.01.23.
//

import Foundation
import UIKit

extension UIImage {
    ///Create image with first character of string
    func imageWith(_ string: String) -> UIImage? {
        let name = string.separateForLanguage(key: "Latn").first!
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let nameLabel = UILabel(frame: frame)
        let colorArray: [UIColor] = [.blue.withAlphaComponent(0.7),
                                     .red.withAlphaComponent(0.7),
                                     .purple.withAlphaComponent(0.7),
                                     .systemPink.withAlphaComponent(0.7),
                                     .gray.withAlphaComponent(0.7),
                                     .systemCyan.withAlphaComponent(0.7),
                                     .systemMint.withAlphaComponent(0.7),
                                     .systemYellow.withAlphaComponent(0.7),
                                     .magenta.withAlphaComponent(0.7)
        ]
        
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = colorArray.randomElement()
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 50)
        nameLabel.text = "\(name)"
        UIGraphicsBeginImageContext(frame.size)
        
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
}
