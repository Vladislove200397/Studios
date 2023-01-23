//
//  HoursCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 26.12.22.
//

import UIKit

class HoursCell: UICollectionViewCell {
    static let id = String(describing: HoursCell.self)
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hourLabel: UILabel!
    
    var bookingTime = 0
    private var isPastTime = Bool()
    private var selectedColor = UIColor(hue: 0.7, saturation: 0.4, brightness: 0.37, alpha: 1.0) // #40385e
    
    override var isSelected: Bool {
        didSet {
            if bookingTime != 0 {
                self.containerView.backgroundColor = isSelected ? selectedColor : .white
                self.hourLabel.textColor = isSelected ? .white : .black
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func set(bookingTime: Int, label: Int, timeIsBusy: Bool, timeIsPast: Bool) {
        self.bookingTime = bookingTime
        self.containerView.layer.cornerRadius = 12
        hourLabel.text = label.formatData(formatType: .HHmm)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        containerView.layer.borderWidth = 1
        hourLabel.textColor = !timeIsBusy ? UIColor.black : UIColor.lightGray
        setupPastTimeCell(timeIsPast, bookingTime)
    }
    
    func setupPastTimeCell(_ timeIsPast: Bool, _ bookingTime: Int) {
        self.bookingTime = timeIsPast ? 0 : bookingTime
        self.hourLabel.isHidden = timeIsPast
        self.containerView.isHidden = timeIsPast
    }
}
