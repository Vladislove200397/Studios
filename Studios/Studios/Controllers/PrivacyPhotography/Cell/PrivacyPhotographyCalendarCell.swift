//
//  PrivacyPhotographyCalendarCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.03.23.
//

import UIKit

class PrivacyPhotographyCalendarCell: UITableViewCell {
    static let id = String(describing: PrivacyPhotographyCalendarCell.self)
    
    @IBOutlet weak var calendarDatePicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
