//
//  FirebaseStudioManager.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.03.23.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import GooglePlaces

final class FirebaseStudioManager {
    static func getStartDayTime(timeStamp: Int) -> Int {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let todayStartOfDay = Calendar.current.startOfDay(for: date)
        let timeOfStartDay = Int(todayStartOfDay.timeIntervalSince1970)
        return timeOfStartDay
    }
    
    static func postBookingModel(
        type: BookingStudioControllerType,
        bookingModel: FirebaseBookingModel,
        referenceType: FirebaseReferenses,
        success: @escaping VoidBlock,
        failure: @escaping ErrorBlock
    ) {
        let bookingID = Int(Date.timeIntervalSinceReferenceDate)
        
        guard let userID = bookingModel.userID,
              let userName = bookingModel.userName,
              let userEmail = bookingModel.userEmail,
              let userPhone = bookingModel.userPhone,
              let bookingTime = bookingModel.bookingTime,
              let studioID = bookingModel.studioID,
              let studioName = bookingModel.studioName,
              let comment = bookingModel.comment else { return }
        
        let timeOfStartDay = getStartDayTime(timeStamp: bookingTime.first ?? 0)
        let booking = ["user_id": userID,
                       "user": userName,
                       "user_email": userEmail,
                       "user_phone": userPhone,
                       "booking_time": bookingTime,
                       "studio_id": studioID,
                       "studio_name": studioName,
                       "booking_id": bookingID,
                       "comment": comment,
                       "booking_day": timeOfStartDay
        ] as [String : Any]
        
        var ref: DatabaseReference = referenceType.references
        
        switch type {
            case .booking:
                ref = ref.child("\(bookingID)")
            case .editBooking:
                guard let bookingID = bookingModel.bookingID else { return }
                ref = ref.child("\(bookingID)")
        }
        
        ref.setValue(booking) {
            (error: Error?, ref: DatabaseReference) in
            if let error {
                failure(error)
                print(error.localizedDescription)
            } else {
                success()
            }
        }
    }
        
    static func getBookingTimes(
        referenceType: FirebaseReferenses,
        success: @escaping ArrayIntBlock,
        failure: ErrorBlock? = nil
    ) {
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
            success(timesArray)
            ref.removeAllObservers()
        }) { error in
            failure?(error)
            print(error.localizedDescription)
        }
    }
    
    static func getBookings(
        referenceType: FirebaseReferenses,
        success: @escaping FirebaseArrayBookingBlock,
        failure: ErrorBlock? = nil
    ) {
        let ref = referenceType.references
        var bookingArr: [FirebaseBookingModel] = []
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for booking in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let bookingObject = booking.value as? [String: Any],
                          let bookingModel = try? FirebaseBookingModel(dict: bookingObject) else { return }

                    bookingArr.append(bookingModel)
                }
            }
            success(bookingArr)
            ref.removeAllObservers()
        }) { error in
            
            failure?(error)
            print(error.localizedDescription)
        }
    }
    
    static func removeBooking(
        bookingModel: FirebaseBookingModel,
        referenceType: FirebaseReferenses,
        success: @escaping VoidBlock,
        failure: @escaping ErrorBlock
    ) {
        let ref = referenceType.references
        guard let bookingID = bookingModel.bookingID else { return }
        ref.child("\(bookingID)").removeValue { error, _ in
            if let error {
                print(error.localizedDescription)
                failure(error)
            } else {
                success()
            }
        }
    }
}
