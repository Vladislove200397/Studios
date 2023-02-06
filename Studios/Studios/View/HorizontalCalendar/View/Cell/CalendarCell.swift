//
//  CalendarCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.01.23.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    static let id = String(describing: CalendarCell.self)
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var redCircle: UIView!
    @IBOutlet weak var grayCircle: UIView!
    
    private(set) var type: CalendarCellType = .booking
    private var dateToShow = ""
    var selectedDate = ""
    private var index = 0
    var pastSelectedCell = false
    private var today = false
    private var selectedColor = UIColor(hue: 0.7, saturation: 0.4, brightness: 0.37, alpha: 1.0) // #40385e
    private var todayColor = UIColor(hue: 0.71, saturation: 0.13, brightness: 0.82, alpha: 1.0) // #bdb5d1
    private var bookingDay = false
    
    override var isSelected: Bool {
        didSet {
            self.stackView.backgroundColor = isSelected ? selectedColor : UIColor.clear
            self.dayLabel.textColor = isSelected ? UIColor.white : UIColor.lightGray
            self.dateLabel.textColor = isSelected ? UIColor.white : UIColor.black
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(dateToShow: String, selectedDate: String, index: Int, today: Bool, pastSelectedCell: Bool, type: CalendarCellType, bookingDay: Bool? = nil) {
        self.selectedDate = selectedDate
        self.dateToShow = dateToShow
        self.today = today
        self.index = index
        self.pastSelectedCell = pastSelectedCell
        guard let bookingDay else {
            setUpCell()
            return
        }
        self.bookingDay = bookingDay
        setUpCell()
    }
    
   private func setUpCell() {
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterMonth.dateFormat = "dd-MM-yyyy"
        let date = dateFormatterMonth.date(from: selectedDate)!
        
        let dateFormatterMonth1 = DateFormatter()
        dateFormatterMonth1.dateFormat = "dd"
        let dayNum = dateFormatterMonth1.string (from: date)
        
        dateFormatterMonth1.dateFormat = "E"
        let dayLit = dateFormatterMonth1.string(from: date)
        
        self.dayLabel.text = dayLit
        self.dateLabel.text = dayNum
        self.redCircle.isHidden = !today
        self.grayCircle.isHidden = !bookingDay
        self.redCircle.layer.cornerRadius = self.redCircle.bounds.width / 2
        self.redCircle.clipsToBounds = true
        self.grayCircle.layer.cornerRadius = self.grayCircle.bounds.width / 2
        self.grayCircle.clipsToBounds = true
        self.stackView.layer.cornerRadius = 12
        self.checkSelectedDate()
    }
    
    func checkSelectedDate() {
        self.stackView.backgroundColor = self.pastSelectedCell ? selectedColor : UIColor.clear
        self.dayLabel.textColor = self.pastSelectedCell ? UIColor.white : UIColor.lightGray
        self.dateLabel.textColor = self.pastSelectedCell ? UIColor.white : UIColor.black
    }
}
