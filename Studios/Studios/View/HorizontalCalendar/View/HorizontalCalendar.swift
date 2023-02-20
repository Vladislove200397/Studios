//
//  HorizontalCalendar.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.01.23.
//

import UIKit

class HorizontalCalendar: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    weak var dateDelegate: SetDateFromViewDelegate?
    weak var swipeDelegate: SwipeCalendarDelegate?
    var date = Date()
    var month = [""]
    var sevenDates: [String] = [""]
    var days: [Int] = []
    var currentDate = ""
    var selectedDatesIndex = 0
    var monthToShow = ""
    var lastDateInTheArray = ""
    var firstDateInTheArray = ""
    var currentMonth = ""
    var selectedDate = ""
    var dateFromCell = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let id = String(describing: HorizontalCalendar.self)
        Bundle.main.loadNibNamed(id, owner: self)
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
        self.monthLabel.textColor = UIColor(hue: 0.68, saturation: 0.27, brightness: 0.70, alpha: 1.0) // #38364a
        registerCell()
        getCurrentDate()
        getSevenDays()
        preformGesture()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: CalendarCell.id, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: CalendarCell.id)
    }
    
    func set(delegate: SetDateFromViewDelegate, swipeDelegate: SwipeCalendarDelegate? = nil) {
        self.dateDelegate = delegate
        if let swipeDelegate {
            self.swipeDelegate = swipeDelegate
        }
    }
    
    private func getCurrentDate() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: date)
        self.currentDate = dateString
        
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyy")
        let currentMonth = dateFormatter.string(from: date)
        self.monthLabel.text = currentMonth.localizedCapitalized
    }
    
    
    private func getSevenDays() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "EEEE"
        let weekDay = dateFormatter1.string(from: date)
        self.selectedDatesIndex = 0
        switch weekDay {
            case "Sunday":
                selectedDatesIndex = 0
                break
            case "Monday":
                selectedDatesIndex = 1
                break
            case "Tuesday":
                selectedDatesIndex = 2
                break
            case "Wednesday":
                selectedDatesIndex = 3
                break
            case "Thursday":
                selectedDatesIndex = 4
                break
            case "Friday":
                selectedDatesIndex = 5
                break
            case "Saturday":
                selectedDatesIndex = 6
                break
            default:
                break
        }
        var sevenDaysToShow: [String] = []
        sevenDaysToShow.removeAll()
        
        for index in 0..<7 {
            let newIndex = index - selectedDatesIndex
            sevenDaysToShow.append(getDates(i: newIndex, currentDate: date).0)
        }
        
        let monthSelectionFrom = sevenDaysToShow[3]
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterMonth.dateFormat = "dd-MM-yyyy"
        let monthDate = dateFormatterMonth.date(from: monthSelectionFrom)!
        
        let dateFormatterMonth1 = DateFormatter()
        dateFormatterMonth1.locale = Locale(identifier: "ru_RU")
        dateFormatterMonth1.setLocalizedDateFormatFromTemplate("MMMM yyy")
        let month = dateFormatterMonth.string(from: monthDate)
        self.monthToShow = month
        
        self.lastDateInTheArray = sevenDaysToShow.last ?? ""
        self.firstDateInTheArray = sevenDaysToShow.first ?? ""
        self.sevenDates = sevenDaysToShow
    }
    
    func getDates(i: Int, currentDate: Date) -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        var date = currentDate
        let cal = Calendar.current
        date = cal.date(byAdding: .day, value: i, to: date)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let stringFormate1 = dateFormatter.string (from: date)
        dateFormatter.dateFormat = "dd"
        let stringFormate2 = dateFormatter.string (from: date)
        
        return (stringFormate1, stringFormate2)
    }
    
    
    func getNextSevenDays (CompletionHandler: @escaping (String) -> Void) {
        let selectedDataInString = self.lastDateInTheArray
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: selectedDataInString)!
        var sevenDaysToShow: [String] = []
        
        for index in 1...7 {
            sevenDaysToShow.append(getDates(i: index, currentDate: date).0)
        }
        
        //Month Selection
        let monthSelectionFrom = sevenDaysToShow[3]
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterMonth.dateFormat = "dd-MM-yyyy"
        let monthDate = dateFormatterMonth.date(from: monthSelectionFrom)!
        
        let dateFormatterMonth1 = DateFormatter()
        dateFormatterMonth.locale = Locale(identifier: "ru_RU")
        dateFormatterMonth1.setLocalizedDateFormatFromTemplate("MMMM yyy")
        let month = dateFormatterMonth1.string(from: monthDate)
        self.monthToShow = month
        
        self.lastDateInTheArray = sevenDaysToShow.last ?? ""
        self.firstDateInTheArray = sevenDaysToShow.first ?? ""
        self.sevenDates = sevenDaysToShow
        return CompletionHandler("getNextDates")
    }
    
    func getPreviousSevenDays(CompletionHandler: @escaping (String) -> Void) {
        let selectedDataInString = self.firstDateInTheArray
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: selectedDataInString)!
        var sevenDaysToShow: [String] = []
        var count = 7
        while count != 0 {
            sevenDaysToShow.append(getDates(i: -count, currentDate: date).0)
            count = count - 1
        }
        
        //Month Selection
        let monthToSelectFrom = sevenDaysToShow[3]
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterMonth.dateFormat = "dd-MM-yyyy"
        let monthDate = dateFormatterMonth.date(from: monthToSelectFrom)!
        
        let dateFormatterMonth1 = DateFormatter()
        dateFormatterMonth.locale = Locale(identifier: "ru_RU")
        dateFormatterMonth1.setLocalizedDateFormatFromTemplate("MMMM yyy")
        let month = dateFormatterMonth1.string (from: monthDate)
        self.monthToShow = month
        
        self.lastDateInTheArray = sevenDaysToShow.last ?? ""
        self.firstDateInTheArray = sevenDaysToShow.first ?? ""
        self.sevenDates = sevenDaysToShow
        return CompletionHandler("getPreviouslyDates")
    }
    
    
    func preformGesture(){
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
        
        leftGesture.direction = .left
        rightGesture.direction = .right
        
        self.collectionView.addGestureRecognizer(leftGesture)
        self.collectionView.addGestureRecognizer(rightGesture)
    }
    
    func swipeTransitionToLeftSide(leftSide: Bool) -> CATransition {
        let transition = CATransition()
        transition.startProgress = 0.0
        transition.endProgress = 1.0
        transition.type = CATransitionType.push
        transition.subtype = leftSide ? CATransitionSubtype.fromRight : CATransitionSubtype.fromLeft
        transition.duration = 0.3
        
        return transition
    }
    
    @objc func handleSwipes (sender: UISwipeGestureRecognizer) {
        switch sender.direction {
            case .left:
                self.getNextSevenDays { [weak self] response in
                    guard let self else { return }
                    if response == "getNextDates" {
                        self.collectionView.layer.add(self.swipeTransitionToLeftSide(leftSide: true), forKey: nil)
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        self.collectionView.layoutSubviews()
                        self.collectionView.reloadData()
                        self.monthLabel.text = self.monthToShow.localizedCapitalized
                        self.swipeDelegate?.didSwipeCalendar()
                    }
                }
            case .right:
                self.getPreviousSevenDays { [weak self] response in
                    if response == "getPreviouslyDates" {
                        guard let self else { return }
                        self.collectionView.layer.add(self.swipeTransitionToLeftSide(leftSide: false), forKey: nil)
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        self.collectionView.layoutSubviews()
                        self.collectionView.reloadData()
                        self.monthLabel.text = self.monthToShow.localizedCapitalized
                        self.swipeDelegate?.didSwipeCalendar()
                    }
                }
            default:
                break
        }
    }
}
