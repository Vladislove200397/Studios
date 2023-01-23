//
//  ViewController1.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 20.12.22.
//

//import UIKit
//import GooglePlaces
//import FirebaseDatabase
//import FirebaseAuth
//import FirebaseCore
//
//class BookingStudioController: UIViewController {
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var testLabel: UILabel!
//    @IBOutlet weak var studioNameLabel: UILabel!
//    @IBOutlet weak var datePicker: UIDatePicker!
//    
//    var refHandle: DatabaseHandle!
//    
//    var studio: GMSPlace?
//    var user: User?
//    var hoursArray: [Int] = []
//    var timesArray: [Int] = []
//    var completeDataToSend = Int() {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
//    var timeStampFromDatePicker = 0 {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
//    var currentTimeStamp = 0
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        readData()
//        registerCell()
//        setUpVC()
//        collectionView.delegate = self
//        getTimetodayStartOfDay()
//        enableTableViewScroll()
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
//        self.collectionView.dataSource = self
//        }
//    }
//    
//    private func registerCell() {
//        let nib = UINib(nibName: HoursCell.id, bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: HoursCell.id)
//    }
//    
//    private func enableTableViewScroll() {
//        if hoursArray.count >= 16 {
//            collectionView.isScrollEnabled = true
//        } else {
//            collectionView.isScrollEnabled = false
//        }
//    }
//    
//    func setData(user: User, studio: GMSPlace) {
//        self.studio = studio
//        self.user = user
//        self.title = "Выберите дату и время"
//    }
//    
//    private func setUpVC() {
//        guard let studio else { return }
//        self.studioNameLabel.text = studio.name
//        getWorkHours()
//    }
//    
//    @IBAction func saveDidTap(_ sender: Any) {
//        guard let user,
//              let studioID = studio?.placeID,
//                let studioName = studio?.name
//        else { return }
//        
//        let studioBookingRef = Database.database().reference().child("booking").child("studios").child("\(studioName)")
//        
//        //get the uniqID path for save data to booking list
//        let bookingID = Int(NSDate.timeIntervalSinceReferenceDate)
//        
//        let userBooking = Database.database().reference().child("booking").child("users").child("\(user.uid)")
//        
//        let booking = ["userID": user.uid,
//                       "user": user.displayName!,
//                       "userEmail": user.email!,
//                       "booking_time": completeDataToSend,
//                       "studioID": studioID,
//                       "studioName": studioName,
//                       "bookingID": bookingID]
//        as [String : Any]
//        
//        studioBookingRef.child("\(bookingID)").setValue(booking)
//        userBooking.child("\(bookingID)").setValue(booking)
//        
//        readData()
//        dismiss(animated: true)
//    }
//    
//    func readData() {
//        guard let studioName = studio?.name else { return }
//        
//        let readRef = Database.database().reference().child("booking").child("studios").child("\(studioName)")
//        
//        readRef.observe(DataEventType.value, with: { (snapshot) in
//            if snapshot.childrenCount > 0 {
//                for booking in snapshot.children.allObjects as! [DataSnapshot] {
//                    guard let bookingObject = booking.value as? [String: Any] else { return }
//                    let times = bookingObject["booking_time"] as! Int
//                    self.timesArray.append(times)
//                }
//            }
//        })
//
//    }
//    
//    //    @IBAction func logOutDidTap(_ sender: Any) {
//    //        let ud = UserDefaults.standard
//    //        let firebaseAuth = Auth.auth()
//    //    do {
//    //      try firebaseAuth.signOut()
//    //        Environment.scenDelegate?.setLoginIsInitial()
//    //        ud.set(nil, forKey: "uid")
//    //    } catch let signOutError as NSError {
//    //      print("Error signing out: %@", signOutError)
//    //    }
//    //    }
//    
//    private func getWorkHours() {
//        guard let studio = studio else { return }
//        hoursArray.removeAll()
//        
//        guard let openingHoursArr = studio.openingHours?.periods else { return }
//        let calendarDay = Calendar.current.dateComponents( [.weekday], from: datePicker.date)
//        var closeHour: UInt?
//        var openHour: UInt?
//        
//        openingHoursArr.enumerated().forEach { (index, value) in
//            if index+1 == calendarDay.weekday {
//                closeHour = value.closeEvent?.time.hour
//                openHour = value.openEvent.time.hour
//            }
//        }
//        
//        if let openHour, let closeHour {
//            if openHour != 0, closeHour != 0 {
//                for hour in openHour...closeHour {
//                    hoursArray.append(Int(hour))
//                }
//            } else {
//                for hour in 0...24 {
//                    hoursArray.append(hour)
//                }
//            }
//        }
//        
//        collectionView.reloadData()
//    }
//    
//    private func getTimetodayStartOfDay() {
//        let todayStartOfDay = Calendar.current.startOfDay(for: datePicker.date)
//        datePicker.minimumDate = Date.now
//        timeStampFromDatePicker = Int(todayStartOfDay.timeIntervalSince1970)
//        currentTimeStamp = Int(Date.now.timeIntervalSince1970)
//    }
//    
//    @IBAction func didDatePickerChange(_ sender: Any) {
//        readData()
//        getTimetodayStartOfDay()
//        getWorkHours()
//    }
//}
//
//extension BookingStudioController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        readData()
//        return hoursArray.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HoursCell.id, for: indexPath)
//        guard let buttonsCell = cell as? HoursCell else { return cell }
//        
//        let compareTime = (hoursArray[indexPath.row]*3600) + timeStampFromDatePicker
//        let isEnabled = timesArray.contains(where: {$0 == compareTime})
//        let thirtyMinutes = 1800
//        let isHidden = currentTimeStamp > compareTime - thirtyMinutes
//        
//        buttonsCell.set(bookingTime: compareTime,
//                        currentTime: currentTimeStamp,
//                        buttonLabel: "\(hoursArray[indexPath.row])",
//                        delegate: self,
//                        buttonEnabled: isEnabled,
//                        buttonHidden: isHidden)
//        return cell
//    }
//}
//
//extension BookingStudioController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//    }
//}
//
//extension BookingStudioController: PushButtonDelegate {
//    func pushButton(bookingTimeStamp: Int) {
//        completeDataToSend = bookingTimeStamp
//        testLabel.text = "\(completeDataToSend)"
//    }
//}
