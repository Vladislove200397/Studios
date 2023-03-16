//
//  PrivacyPhotographyCalendarCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.03.23.
//

import UIKit

class PrivacyPhotographyCalendarCell: UITableViewCell {
    static let id = String(describing: PrivacyPhotographyCalendarCell.self)
    
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var timeContainerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        dotView.clipsToBounds = true
        self.dotView.layer.cornerRadius = dotView.frame.width / 2
        timeContainerView.layer.cornerRadius = 6
    }
}
