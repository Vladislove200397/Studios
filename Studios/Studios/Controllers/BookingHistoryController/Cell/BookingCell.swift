//
//  BookingCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 4.03.23.
//

import UIKit

class BookingCell: UICollectionViewCell {
    static let id = String(describing: BookingCell.self)

    @IBOutlet weak var cellStudioNameLabel: UILabel!
    @IBOutlet weak var cellBookingTimeLabel: UILabel!
    
    private let cellColor = UIColor(
        hue: 0.65,
        saturation: 0.68,
        brightness: 0.63,
        alpha: 1.0
    )
    private(set) public var bookingModel = FirebaseBookingModel()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setContainerViewGradient()
    }
    
    func set(booking: FirebaseBookingModel) {
        self.bookingModel = booking
        setUpCell()
    }
    
    private func setContainerViewGradient() {
        contentView.clipsToBounds = true
        contentView.backgroundColor = cellColor
        contentView.layer.cornerRadius = 10
    }
    
    private func setUpCell() {
        guard let bookingTime = bookingModel.bookingTime,
              let firstBookingTime = bookingModel.bookingTime?.first,
              let lastBookingTime = bookingModel.bookingTime?.last else { return }
        
        let lastTime = (bookingModel.bookingTime?.last ?? 0) + 3600
        
        let dateText = bookingTime.checkArrCount() ?
        "\(firstBookingTime.formatData(formatType: .dMMMHHmm)) - \((lastBookingTime + 3600).formatData(formatType: .HHmm))"
        :
        "\(firstBookingTime.formatData(formatType: .dMMMHHmm))"
        
        cellStudioNameLabel.text = bookingModel.studioName
        cellBookingTimeLabel.text = dateText
        self.addShadow(
            corner: 10,
            color: cellColor,
            radius: 15,
            offset: CGSize(width: 0, height: 5),
            opacity: 0.3
        )
    }
}

