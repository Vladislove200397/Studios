//
//  PaddingLabel.swift
//  UniversalPopUp
//
//  Created by Vlad Kulakovsky  on 14.02.23.
//

import UIKit

 class PaddingLabel: UILabel {
     var insets = UIEdgeInsets.zero
     
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left  + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }

    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (insets.left + insets.right)
        }
    }
}
