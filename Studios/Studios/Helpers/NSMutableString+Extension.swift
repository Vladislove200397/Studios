//
//  NSMutableAttributedString+Extension.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.03.23.
//

import Foundation

extension NSMutableAttributedString {
    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}
