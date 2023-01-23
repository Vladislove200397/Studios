//
//  FirebaseProvider.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 29.12.22.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

public class FirebaseProvider {
    
    func postBookingModel(bookingModel: FirebaseBookingModel, referenceType: FirebaseReferenses, succed: @escaping () -> Void, failure: @escaping () -> Void) {
    
        //get the uniqID path for save data to booking list
        let bookingID = Int(NSDate.timeIntervalSinceReferenceDate)
        guard let userID = bookingModel.userID,
              let userName = bookingModel.userName,
              let userEmail = bookingModel.userEmail,
              let userPhone = bookingModel.userPhone,
              let bookingTime = bookingModel.bookingTime,
              let studioID = bookingModel.studioID,
              let studioName = bookingModel.studioName,
              let comment = bookingModel.comment else { return }
        
        let booking = ["user_id": userID,
                       "user": userName,
                       "user_email": userEmail,
                       "user_phone": userPhone,
                       "booking_time": bookingTime,
                       "studio_id": studioID,
                       "studio_name": studioName,
                       "booking_id": bookingID,
                       "comment": comment,
        ] as [String : Any]
        
        let ref: DatabaseReference = referenceType.references
        
        ref.child("\(bookingID)").setValue(booking) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                failure()
                print(error.localizedDescription)
            } else {
                succed()
            }
        }
    }
    
    func getBookingTimes(referenceType: FirebaseReferenses, succed: @escaping ([Int]) -> Void, failure: @escaping () -> Void) {
        let ref: DatabaseReference = referenceType.references
        
        var timesArray: [Int] = []
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for booking in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let bookingObject = booking.value as? [String: Any] else { return }
                    let times = bookingObject["booking_time"] as! [Int]
                    times.forEach { time in
                        timesArray.append(time)
                    }
                }
            }
            succed(timesArray)
            ref.removeAllObservers()
        }) { error in
            failure()
            print(error.localizedDescription)
        }
    }
    
    func getBookings(referenceType: FirebaseReferenses, succed: @escaping ([FirebaseBookingModel]) -> Void, failure: @escaping () -> Void) {
        let ref = referenceType.references
        var bookingArr: [FirebaseBookingModel] = []
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for booking in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let bookingObject = booking.value as? [String: Any] else { return }
                    let time = bookingObject["booking_time"] as! [Int]
                    let studioName = bookingObject ["studio_name"] as! String
                    let bookingID = bookingObject ["booking_id"] as! Int
                    let studioID = bookingObject["studio_id"] as! String
                    
                    let firebaseBooking = FirebaseBookingModel(bookingTime: time, studioName: studioName, bookingID: bookingID, studioID: studioID)
                    
                    bookingArr.append(firebaseBooking)
                }
            }
            succed(bookingArr)
            ref.removeAllObservers()
        }) { error in
            failure()
            print(error.localizedDescription)
        }
    }
    
    func getLike(referenceType: FirebaseReferenses, succed: @escaping (Bool) -> Void, failure: (() -> Void)? = nil) {
        let ref = referenceType.references
        
        ref.getData(completion: { error, snapshot in
            if let error {
                print(error.localizedDescription)
            } else {
                guard let snapshot else { return }
                let value = snapshot.value as? NSDictionary
                let like = value?["like"] as? Bool ?? false
                succed(like)
            }
        })
        ref.removeAllObservers()
    }
}


