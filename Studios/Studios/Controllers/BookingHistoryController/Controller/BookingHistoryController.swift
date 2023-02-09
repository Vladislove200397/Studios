//
//  BookingHistoryController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 29.12.22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

class BookingHistoryController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var calendar: HorizontalCalendar!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    
    private var user = Auth.auth().currentUser
    private var bookingArray: [FirebaseBookingModel] = []
    private var bookingDays: [Int]? = []
    private var presentingBookingArray: [FirebaseBookingModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBookings()
        registerCell()
        tableView.dataSource = self
        tableView.delegate = self
        calendar.collectionView.dataSource = self
        calendar.collectionView.delegate = self
        calendar.set(delegate: self, swipeDelegate: self)
        setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBookings()
        tableView.reloadData()
    }
    
    private func setupVC() {
        self.navigationItem.title = "История бронирований"
        alertView.isHidden = false
        tableView.isHidden = true
    }
    
    private func registerCell() {
        let nib = UINib(nibName: BookingCell.id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BookingCell.id)
    }
    
    private func getBookings() {
        guard let user else { return }
        self.spinner.startAnimating()
        FirebaseProvider().getBookings(referenceType: .getBookingForUserRef(userID: user.uid)) { booking in
            self.bookingArray = booking
            self.spinner.stopAnimating()
            self.tableView.reloadData()
            self.calendar.collectionView.reloadData()
        }
    }
    
    private func showBookingToSelectedDate(_ date: String) {
        let filtredFirebaseBookingArr = self.bookingArray.filter({$0.bookingDay?.formatData(formatType: .ddMMyyyy) == date})
        self.presentingBookingArray = filtredFirebaseBookingArr
        self.tableView.reloadData()
        if filtredFirebaseBookingArr.isEmpty {
            tableView.isHidden = true
            alertView.isHidden = false
            alertLabel.text = "На эту дату нет бронирований."
        } else {
            tableView.isHidden = false
            alertView.isHidden = true
        }
    }
}
    
    //MARK: TableViewDataSource
extension BookingHistoryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentingBookingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookingCell.id, for: indexPath)
        (cell as? BookingCell)?.set(booking: presentingBookingArray[indexPath.row])
        return cell
    }
}

//MARK: TableViewDelegate
extension BookingHistoryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BookingCell else { return }
        let bookingVC = BookingStudioController(nibName: String(describing: BookingStudioController.self), bundle: nil)
        guard let studio = Service.shared.studios.first(where: {$0.placeID == cell.bookingModel.studioID}) else { return }
        
        bookingVC.setData(studio: studio, controllerType: .editBooking, bookingModel: cell.bookingModel)
        navigationController?.pushViewController(bookingVC, animated: true)
    }
}

//MARK: CollectionViewDataSource
extension BookingHistoryController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.id, for: indexPath)
        guard let calendarCell = cell as? CalendarCell else { return cell }
        let redCircleEnabled = calendar.sevenDates[indexPath.row] == calendar.currentDate
        let selectedCell = calendar.sevenDates[indexPath.row] == calendar.dateFromCell
        let circleOfContainsBooking = bookingArray.contains(where: {$0.bookingDay?.formatData(formatType: .ddMMyyyy) == calendar.sevenDates[indexPath.row]})
        print(circleOfContainsBooking)
        
        calendarCell.set(dateToShow: calendar.selectedDate,
                         selectedDate: calendar.sevenDates[indexPath.row],
                         index: indexPath.row,
                         today: redCircleEnabled,
                         pastSelectedCell: selectedCell,
                         type: .history,
                         bookingDay: circleOfContainsBooking)
        
        return calendarCell
    }
}

//MARK: CollectionViewDelegateFlowLayout
extension BookingHistoryController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leading = 16.0
        let cellCount = 7.0
        let width = calendar.collectionView.frame.width / cellCount - leading
        let height = calendar.collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarCell else { return }
        showBookingToSelectedDate(cell.selectedDate)
    }
}

//MARK: SetDateFromViewDelegate
extension BookingHistoryController: SetDateFromViewDelegate {
    func setDate(date: String) {
    }
}

extension BookingHistoryController: SwipeCalendarDelegate {
    func didSwipeCalendar() {
    }
}
