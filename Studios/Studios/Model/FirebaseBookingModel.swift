//
//  FirebaseBookingModel.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 29.12.22.
//

import Foundation

final class FirebaseBookingModel {
    var bookingTime: [Int]?
    var bookingID: Int?
    var userName: String?
    var userEmail: String?
    var userPhone: String?
    var userID: String?
    var studioID: String?
    var studioName: String?
    var comment: String?
    var bookingDay: Int?
    
    init(bookingTime: [Int]? = nil,
         bookingID: Int? = nil,
         userName: String? = nil,
         userEmail: String? = nil,
         userPhone: String? = nil,
         userID: String? = nil,
         studioID: String? = nil,
         studioName: String? = nil,
         comment: String? = nil,
         bookingDay: Int? = nil) {
    
        self.bookingTime = bookingTime
        self.bookingID = bookingID
        self.userName = userName
        self.userEmail = userEmail
        self.userPhone = userPhone
        self.userID = userID
        self.studioID = studioID
        self.studioName = studioName
        self.comment = comment
        self.bookingDay = bookingDay
    }
    
    convenience init(bookingTime: [Int],
                     studioName: String,
                     bookingID: Int,
                     studioID: String,
                     bookingDay: Int) {
        self.init()
        self.bookingTime = bookingTime
        self.studioName = studioName
        self.bookingID = bookingID
        self.studioID = studioID
        self.bookingDay = bookingDay
    }
    
    init(dict: [String: Any]) throws{
        self.bookingTime = dict["booking_time"] as? [Int]
        self.studioName = dict["studio_name"] as? String
        self.bookingID = dict["booking_id"] as? Int
        self.studioID = dict["studio_id"] as? String
        self.bookingDay = dict["booking_day"] as? Int
        self.comment = dict["comment"] as? String
        self.userPhone = dict["user_phone"] as? String
    }
  
}
