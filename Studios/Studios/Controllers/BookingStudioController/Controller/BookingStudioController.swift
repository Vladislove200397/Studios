//
//  BookingStudioController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 12.12.22.
//

import UIKit
import GooglePlaces
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

final class BookingStudioController: UIViewController {
    @IBOutlet weak var studioNameLabel: UILabel!
    @IBOutlet weak var calendar: HorizontalCalendar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var studioAddressLabel: UILabel!
    @IBOutlet weak var nextVCButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var studio: GMSPlace?
    private var user = Auth.auth().currentUser
    private var hoursArray: [[Int]] = []
    private var timesArray: [Int] = []
    private var timeStampDateFromCalendar = Int()
    private var dateFromCalendar: Date?
    private var compareBookingTimeStamp = Int()
    private var compareBookingTimeStampArray = [Int]()
    private var selectionType: SelectionType = .singleSelection
    private var previusSelectedIndexPathSection = 0
    private var previusSelectedIndexPathRow = 0
    private var tapCounter = 0
    private var afterResetCells = false
    private var controllerType: BookingStudioControllerType = .booking
    private var bookingModelEdit = FirebaseBookingModel()
    private var firebaseUserModel: FirebaseUser?
    private var updateBlock: FirebaseBookingBlock?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        calendar.collectionView.dataSource = self
        calendar.collectionView.delegate = self
        calendar.set(delegate: self)
        setUpVC()
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    deinit {
        print("DEINIT CHOSE TIME CONTROLLER")
    }
        
    private func setUpVC() {
        guard let studio else { return }
        self.studioNameLabel.text = studio.name
        self.studioAddressLabel.text = studio.formattedAddress
        getWorkHours()
        readData()
        getWorkHours()
        getUserInfo()
        registerCell()
        nextVCButton.isEnabled = false
        nextVCButton.setTitle("Выберите дату и время", for: .normal)
        title = controllerType.title
    }
    
    private func registerCell() {
        let nib = UINib(nibName: HoursCell.id, bundle: nil)
        let sectionHeaderNib = UINib(nibName: SectionHeader.id, bundle: nil)
        
        self.collectionView.register(nib, forCellWithReuseIdentifier: HoursCell.id)
        self.collectionView.register(
            sectionHeaderNib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.id
        )
    }
    
    func setData(
        studio: GMSPlace,
        controllerType: BookingStudioControllerType,
        bookingModel: FirebaseBookingModel? = nil,
        updateBlock: FirebaseBookingBlock? = nil
    ) {
        self.studio = studio
        self.controllerType = controllerType
        guard let bookingModel else { return }
        self.bookingModelEdit = bookingModel
        self.updateBlock = updateBlock
    }
    
    private func getCurrentDateTimeStamp() -> Int {
        let currentDate = Date.now
        let currentTimeStamp = Int(currentDate.timeIntervalSince1970)
        return currentTimeStamp
    }
    
    private func getStartDayTime() -> Int {
        let todayStartOfDay = Calendar.current.startOfDay(for: Date.now)
        let timeOfStartDay = Int(todayStartOfDay.timeIntervalSince1970)
        return timeOfStartDay
    }
    
    private func getWorkHours() {
        guard let studio = studio else { return }
        
        self.hoursArray.removeAll()
        
        guard let openingHoursArr = studio.openingHours?.periods else { return }
        let calendarDay = Calendar.current.dateComponents( [.weekday], from: self.dateFromCalendar ?? Date.now)
        var closeHour: UInt?
        var openHour: UInt?
        
        openingHoursArr.enumerated().forEach { (index, value) in
            if index+1 == calendarDay.weekday {
                closeHour = value.closeEvent?.time.hour
                openHour = value.openEvent.time.hour
            }
        }
        var morningHours: [Int] = []
        var dayHours: [Int] = []
        var eveningHours: [Int] = []
        
        if let openHour, let closeHour {
            if openHour != 0, closeHour != 0 {
                for i in openHour...closeHour {
                    let compareTime = (Int(i) * 3600) + self.timeStampDateFromCalendar
                    switch i {
                        case openHour...11:
                            morningHours.append(compareTime)
                        case 12...16:
                            dayHours.append(compareTime)
                        case 17...closeHour-1:
                            eveningHours.append(compareTime)
                        default:
                            break
                    }
                }
                
                self.hoursArray.append(morningHours)
                self.hoursArray.append(dayHours)
                self.hoursArray.append(eveningHours)
            }
        }
    }
    
    private func readData() {
        guard let studioID = self.studio?.placeID else { return }
        self.spinner.startAnimating()
        
        FirebaseStudioManager.getBookingTimes(
            referenceType: .getBookingTimesForStudioRef(studioID: studioID)
        ) {[weak self] times in
            guard let self else { return }
            self.timesArray = times
            self.collectionView.reloadData()
            self.spinner.stopAnimating()
        }
    }
    
    private func getUserInfo() {
        guard let userID = user?.uid else { return }
        FirebaseAuthManager.getUserInfo(
            referenceType: .getUserInfo,
            userID) { firebaseUser in
                self.firebaseUserModel = firebaseUser
            } failure: {
                
            }
    }
    
    private func isEnabledButton() {
        if self.compareBookingTimeStampArray.count != 0, self.timeStampDateFromCalendar != 0 {
            self.nextVCButton.isEnabled = true
            self.nextVCButton.setTitle("Далее", for: .normal)
        } else {
            self.nextVCButton.isEnabled = false
            self.nextVCButton.setTitle("Выберите время", for: .normal)
        }
    }
    
    @IBAction func saveDidTap(_ sender: Any) {
        guard let user,
              let studioID = self.studio?.placeID,
              let studioName = self.studio?.name else { return }
        
        let confirmationBookingVC = BookingConfirmController(
            nibName: String(describing: BookingConfirmController.self),
            bundle: nil
        )
        
        switch controllerType {
            case .booking:
                let bookingModel = FirebaseBookingModel(
                    bookingTime: self.compareBookingTimeStampArray,
                    userName: user.displayName,
                    userEmail: user.email,
                    userID: user.uid,
                    studioID: studioID,
                    studioName: studioName
                )
                
                confirmationBookingVC.set(
                    bookingModel: bookingModel,
                    bookingType: self.selectionType,
                    controllerType: controllerType,
                    userModel: firebaseUserModel
                )
                
                navigationController?.pushViewController(confirmationBookingVC, animated: true)
                
            case .editBooking:
                let editBookingModel = FirebaseBookingModel(
                    bookingTime: self.compareBookingTimeStampArray,
                    bookingID: bookingModelEdit.bookingID,
                    userName: user.displayName,
                    userEmail: user.email,
                    userPhone: bookingModelEdit.userPhone,
                    userID: user.uid,
                    studioID: studioID,
                    studioName: studioName,
                    comment: bookingModelEdit.comment
                )
                
                confirmationBookingVC.set(
                    bookingModel: editBookingModel,
                    bookingType: selectionType,
                    controllerType: controllerType,
                    updateBlock: updateBlock
                )
                
                navigationController?.pushViewController(confirmationBookingVC, animated: true)
        }
    }
    
    private func allowSelectNextCell(bookingTime: Int) {
        compareBookingTimeStampArray.append(bookingTime)
        isEnabledButton()
        tapCounter += 1
        afterResetCells = false
    }
    
    private func resetCollectionView() {
        self.collectionView.reloadData()
        compareBookingTimeStampArray.removeAll()
        previusSelectedIndexPathRow = 0
        previusSelectedIndexPathSection = 0
        tapCounter = 0
        afterResetCells = true
    }

    @IBAction func selectionTypeButtonDidTap(_ sender: UIButton) {
        switch self.selectionType {
            case .singleSelection:
                resetCollectionView()
                selectionType = .multipleSelection
                self.collectionView.allowsMultipleSelection = true
                sender.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                sender.tintColor = .tintColor.withAlphaComponent(0.66)
                
            case .multipleSelection:
                resetCollectionView()
                selectionType = .singleSelection
                self.collectionView.allowsMultipleSelection = false
                self.collectionView.allowsSelection = true
                sender.setImage(UIImage(systemName: "square"), for: .normal)
                sender.tintColor = .tintColor.withAlphaComponent(0.66)
        }
    }
}

extension BookingStudioController: UICollectionViewDataSource {
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        if collectionView == self.collectionView {
            return self.hoursArray.count
        } else {
            return 1
        }
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == self.collectionView {
            return self.hoursArray[section].count
        } else {
            return 7
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HoursCell.id, for: indexPath)
            collectionView.allowsSelection = true
            self.isEnabledButton()
            
            guard let hoursCell = cell as? HoursCell else { return cell }
            let hour = self.hoursArray[indexPath.section][indexPath.row]
            
            let timeIsBusy = self.timesArray.contains(where: {$0 == hour})
            
            let thirtyMinutes = 1800
            let timeIsPast = self.getCurrentDateTimeStamp() > hour - thirtyMinutes
            
            hoursCell.set(bookingTime: timeIsBusy ? 0 : hour,
                          label: hour,
                          timeIsBusy: timeIsBusy,
                          timeIsPast: timeIsPast)
            
            return hoursCell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.id, for: indexPath)
            guard let calendarCell = cell as? CalendarCell else { return cell }
            let redCircleEnabled = calendar.sevenDates[indexPath.row] == calendar.currentDate
            let selectedCell = calendar.sevenDates[indexPath.row] == calendar.dateFromCell
            
            calendarCell.set(
                dateToShow: calendar.selectedDate,
                selectedDate: calendar.sevenDates[indexPath.row],
                index: indexPath.row,
                today: redCircleEnabled,
                pastSelectedCell: selectedCell
            )
            
            return calendarCell
        }
    }
}

extension BookingStudioController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if collectionView == self.collectionView {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.id, for: indexPath)
            
            guard let textHeader = sectionHeader as? SectionHeader else { return sectionHeader }
            
            switch indexPath.section {
                case 0:     textHeader.sectionLabel.text = "Утро"
                case 1:     textHeader.sectionLabel.text = "День"
                case 2:     textHeader.sectionLabel.text = "Вечер"
                default:    textHeader.sectionLabel.text = "Section \(indexPath.section)"
            }
            return sectionHeader
        }
        return UICollectionReusableView()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == self.collectionView {
            let cellCount = 4.0
            let leading = 10.0
            let width = collectionView.frame.width / cellCount - leading
            return CGSize(width: width, height: 40)
        } else {
            let leading = 16.0
            let cellCount = 7.0
            let width = calendar.collectionView.frame.width / cellCount - leading
            let height = calendar.collectionView.frame.height
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == self.collectionView {
            return 0
        } else {
            return 16
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == self.collectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? HoursCell else { return }
            
            guard cell.bookingTime != 0 else {
                resetCollectionView()
                return
            }
            
            switch self.selectionType {
                case .singleSelection:
                    self.compareBookingTimeStampArray.removeAll()
                    self.compareBookingTimeStampArray.append(cell.bookingTime)
                    isEnabledButton()
                    
                case .multipleSelection:
                    if tapCounter == 0 {
                        allowSelectNextCell(bookingTime: cell.bookingTime)
                        
                    } else if previusSelectedIndexPathSection == indexPath.section, previusSelectedIndexPathRow+1 == indexPath.row {
                        allowSelectNextCell(bookingTime: cell.bookingTime)
                        
                    } else if previusSelectedIndexPathRow == hoursArray[previusSelectedIndexPathSection].endIndex-1, indexPath.row == 0 {
                        allowSelectNextCell(bookingTime: cell.bookingTime)
                        
                    } else if afterResetCells {
                        allowSelectNextCell(bookingTime: cell.bookingTime)
                        
                    } else {
                        resetCollectionView()
                    }
            }
            
            self.previusSelectedIndexPathSection = indexPath.section
            self.previusSelectedIndexPathRow = indexPath.row
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarCell else { return }
            self.collectionView.reloadData()
            calendar.dateDelegate?.setDate(date: cell.selectedDate)
            calendar.dateFromCell = cell.selectedDate
            calendar.collectionView.reloadData()
            compareBookingTimeStampArray.removeAll()
            previusSelectedIndexPathRow = 0
            previusSelectedIndexPathSection = 0
            tapCounter = 0
            isEnabledButton()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        if collectionView == self.collectionView {
            switch self.selectionType {
                case .multipleSelection:
                    if indexPath.row == indexPath.row, indexPath.section == indexPath.section {
                        collectionView.reloadData()
                        compareBookingTimeStampArray.removeAll()
                        previusSelectedIndexPathRow = 0
                        previusSelectedIndexPathSection = 0
                        tapCounter = 0
                    }
                case .singleSelection:
                    break
            }
        }
    }
}

extension BookingStudioController: SetDateFromViewDelegate {
    func setDate(date: String) {
        let compareDate = date.formatData(formatType: .ddMMyyyy)
        dateFromCalendar = compareDate
        timeStampDateFromCalendar = Int(compareDate.timeIntervalSince1970)
        getWorkHours()
        readData()
        nextVCButton.isEnabled = false
        nextVCButton.setTitle("Выберите время", for: .normal)
    }
}


