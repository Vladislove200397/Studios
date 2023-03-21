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

final class BookingHistoryController: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var calendar: HorizontalCalendar!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var bookingHistoryCollectionView: UICollectionView!
    
    private var contextMenuSelectedIndexPath = IndexPath()
    private var bookingHistoryActionMenu = UIMenu()
    private var user = Auth.auth().currentUser
    private var bookingArray: [FirebaseBookingModel] = []
    private var bookingDays: [Int]? = []
    private var presentingBookingArray: [FirebaseBookingModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBookings()
        registerCell()
        setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBookings()
        bookingHistoryCollectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setBackgroundGradient()
    }
    
    private func setBackgroundGradient() {
        let topColor = UIColor(
            hue: 0.58,
            saturation: 0.72,
            brightness: 0.25,
            alpha: 1.0
        ).cgColor // #40174f
        self.view.setGradientBackground(
            topColor: topColor,
            bottomColor: UIColor.black.cgColor
        )
    }
    
    private func setupVC() {
        setupBookingHistoryCellMenu()
        navigationController?.setNavigationBarHidden(true, animated: true)
        alertView.isHidden = false
        bookingHistoryCollectionView.isHidden = true
        bookingHistoryCollectionView.dataSource = self
        bookingHistoryCollectionView.delegate = self
        calendar.collectionView.dataSource = self
        calendar.collectionView.delegate = self
    }
    
    private func setupBookingHistoryCellMenu() {
        let changeBookingAction = UIAction(
            title: "Изменить время бронирвоания",
            image: UIImage(systemName: "clock.arrow.2.circlepath")
        ) {[weak self] _ in
            guard let self else { return }
            self.showVcToСhangeBooking { bookingModel in
                if self.presentingBookingArray[self.contextMenuSelectedIndexPath.row].bookingDay == bookingModel.bookingDay {
                    self.bookingHistoryCollectionView.performBatchUpdates {
                        self.presentingBookingArray.remove(at: self.contextMenuSelectedIndexPath.row)
                        self.presentingBookingArray.insert(bookingModel, at: self.contextMenuSelectedIndexPath.row)
                        self.bookingHistoryCollectionView.reloadItems(at: self.bookingHistoryCollectionView.indexPathsForVisibleItems)
                    } completion: { _ in
                        self.getBookings()
                    }
        
                } else {
                    self.bookingHistoryCollectionView.performBatchUpdates {
                        self.presentingBookingArray.remove(at: self.contextMenuSelectedIndexPath.row)
                        self.bookingHistoryCollectionView.reloadItems(at: self.bookingHistoryCollectionView.indexPathsForVisibleItems)
                    } completion: { _ in
                        self.getBookings()
                    }
                }
                self.showEmptyArrayView()
            }
        }
        
        let deleteBookign = UIAction(
            title: "Отменить бронирование",
            image: UIImage(systemName: "clock.badge.xmark"),
            attributes: .destructive
        ) {[weak self] _ in
            guard let self else { return }
            self.removeBooking {
                self.bookingHistoryCollectionView.performBatchUpdates {
                    self.presentingBookingArray.remove(at: self.contextMenuSelectedIndexPath.row)
                    self.bookingHistoryCollectionView.deleteItems(at: [self.contextMenuSelectedIndexPath])
                } completion: { _ in
                    self.getBookings()
                    self.showEmptyArrayView()
                }
            } failure: {
                print("OSHIBKA")
            }
        }
        
        bookingHistoryActionMenu = UIMenu(
            title: "",
            children: [changeBookingAction, deleteBookign]
        )
    }
    
    private func registerCell() {
        let nib = UINib(
            nibName: BookingCell.id,
            bundle: nil
        )
        
        bookingHistoryCollectionView.register(nib, forCellWithReuseIdentifier: BookingCell.id)
    }
    
    private func getBookings() {
        guard let user else { return }
        self.spinner.startAnimating()
        FirebaseStudioManager.getBookings(
            referenceType: .getBookingForUserRef(userID: user.uid)
        ) {[weak self] booking in
            guard let self else { return }
            self.bookingArray = booking
            self.spinner.stopAnimating()
            self.bookingHistoryCollectionView.reloadData()
            self.calendar.collectionView.reloadData()
        }
    }
    
    private func removeBooking(
        complition: @escaping VoidBlock,
        failure: VoidBlock?
    ) {
        var error: Error?
        let group = DispatchGroup()
        let concurrentQueue = DispatchQueue(
            label: "removeBooking-concurrentQueue",
            attributes: .concurrent
        )
        
        let selectedContextMenuElement = contextMenuSelectedIndexPath.row
        let bookingModel = presentingBookingArray[selectedContextMenuElement]
        
        guard let studioID = bookingModel.studioID,
              let userID = user?.uid else { return }
        
        let removeStudioBookingWorkItem = DispatchWorkItem {
            FirebaseStudioManager.removeBooking(
                bookingModel: bookingModel,
                referenceType: .removeStudioBookingRef(studioID: studioID)
            ) {
                group.leave()
            } failure: { requestError in
                error = requestError
                group.leave()
            }
        }
        
        let removeUserBookingWorkItem = DispatchWorkItem {
            FirebaseStudioManager.removeBooking(
                bookingModel: bookingModel,
                referenceType: .removeUserBookingRef(userID: userID)
            ) {
                group.leave()
            } failure: { requestError in
                error = requestError
                group.leave()
            }
        }
        
        group.enter()
        concurrentQueue.async(execute: removeStudioBookingWorkItem)
        
        group.enter()
        concurrentQueue.async(execute: removeUserBookingWorkItem)
        
        group.notify(queue: .main) {
            guard error != nil else {
                complition()
                return
            }
            failure?()
        }
    }
    
    private func showBookingToSelectedDate(_ date: String) {
        let filtredFirebaseBookingArr = self.bookingArray
            .filter({$0.bookingDay?.formatData(formatType: .ddMMyyyy) == date})
        
        presentingBookingArray = filtredFirebaseBookingArr
        bookingHistoryCollectionView.reloadData()
        showEmptyArrayView()
    }
    
    private func showEmptyArrayView() {
        if presentingBookingArray.isEmpty {
            bookingHistoryCollectionView.isHidden = true
            alertView.isHidden = false
            alertLabel.text = "На эту дату нет бронирований."
        } else {
            bookingHistoryCollectionView.isHidden = false
            alertView.isHidden = true
        }
    }
    
    private func showVcToСhangeBooking(updateBlock: @escaping FirebaseBookingBlock) {
        let bookingVC = BookingStudioController(
            nibName: String(describing: BookingStudioController.self),
            bundle: nil
        )
        
        let firstIndex = contextMenuSelectedIndexPath.row
        let studioID = presentingBookingArray[firstIndex].studioID
        let bookingModel = presentingBookingArray[firstIndex]
        guard let studio = Service.shared.studios.first(where: {$0.placeID == studioID}) else { return }
        bookingVC.setData(
            studio: studio,
            controllerType: .editBooking,
            bookingModel: bookingModel
        ) { bookingModel in
            updateBlock(bookingModel)
        }
        navigationController?.pushViewController(bookingVC, animated: true)
    }
}

//MARK: CollectionViewDataSource
extension BookingHistoryController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == calendar.collectionView {
            return 7
        } else {
            return presentingBookingArray.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == calendar.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.id, for: indexPath)
            guard let calendarCell = cell as? CalendarCell else { return cell }
            let redCircleEnabled = calendar.sevenDates[indexPath.row] == calendar.currentDate
            let selectedCell = calendar.sevenDates[indexPath.row] == calendar.dateFromCell
            let circleOfContainsBooking = bookingArray.contains(where: {$0.bookingDay?.formatData(formatType: .ddMMyyyy) == calendar.sevenDates[indexPath.row]})
            print(circleOfContainsBooking)
            
            calendarCell.set(
                dateToShow: calendar.selectedDate,
                selectedDate: calendar.sevenDates[indexPath.row],
                index: indexPath.row,
                today: redCircleEnabled,
                pastSelectedCell: selectedCell,
                bookingDay: circleOfContainsBooking
            )
            
            return calendarCell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookingCell.id, for: indexPath)
            guard let historyCell = cell as? BookingCell else { return cell}
        
            historyCell.set(booking: presentingBookingArray[indexPath.row])
            
            return historyCell
        }
    }
}

//MARK: CollectionViewDelegateFlowLayout
extension BookingHistoryController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        if collectionView == bookingHistoryCollectionView {
            contextMenuSelectedIndexPath = indexPath
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {[weak self] _ in
                self?.bookingHistoryActionMenu
            }
        } else {
            return nil
        }
    }
        
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == calendar.collectionView {
            let leading = 16.0
            let cellCount = 7.0
            let width = calendar.collectionView.frame.width / cellCount - leading
            let height = calendar.collectionView.frame.height
            return CGSize(width: width, height: height)
        } else {
            let inset = 20.0
            let width = collectionView.frame.width - inset
            return CGSize(width: width, height: 85)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == calendar.collectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarCell else { return }
            calendar.dateFromCell = cell.selectedDate
            calendar.collectionView.reloadData()
            showBookingToSelectedDate(cell.selectedDate)
        }
    }
}
