//
//  SectionHeader.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 17.01.23.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    static let id = String(describing: SectionHeader.self)
    
    @IBOutlet weak var sectionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
