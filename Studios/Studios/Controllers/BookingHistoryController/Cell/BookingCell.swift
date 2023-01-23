//
//  BookingCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 29.12.22.
//

import UIKit

class BookingCell: UITableViewCell {
    static let id = String(describing: BookingCell.self)
    @IBOutlet weak var cellStudioNameLabel: UILabel!
    @IBOutlet weak var cellBookingTimeLabel: UILabel!
    
    private var bookingModel = FirebaseBookingModel()
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func set(booking: FirebaseBookingModel) {
        self.bookingModel = booking
        setUpCell()
    }
    
    func checkArrCount(_ bookingTimeArray: [Int]) -> Bool {
        if bookingTimeArray.count > 1 {
            return true
        } else {
            return false
        }
    }
    
    private func setUpCell() {
        guard let bookingTime = bookingModel.bookingTime else { return }
        
        let dateText = bookingTime.checkArrCount() ? "\(bookingModel.bookingTime?.first?.formatData(formatType: .dMMMHHmm) ?? "") - \(bookingModel.bookingTime?.last?.formatData(formatType: .HHmm) ?? "")"
        :
        "\(bookingModel.bookingTime?.first?.formatData(formatType: .dMMMHHmm) ?? "")"
        
            cellStudioNameLabel.text = bookingModel.studioName
        cellBookingTimeLabel.text = dateText
    }
    
    
}
