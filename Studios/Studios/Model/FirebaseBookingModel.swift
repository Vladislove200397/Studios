//
//  FirebaseBookingModel.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 29.12.22.
//

import Foundation

class FirebaseBookingModel {
    var bookingTime: [Int]?
    var bookingID: Int?
    var userName: String?
    var userEmail: String?
    var userPhone: String?
    var userID: String?
    var studioID: String?
    var studioName: String?
    var comment: String?
    
    init(bookingTime: [Int]? = nil,
         bookingID: Int? = nil,
         userName: String? = nil,
         userEmail: String? = nil,
         userPhone: String? = nil,
         userID: String? = nil,
         studioID: String? = nil,
         studioName: String? = nil,
         comment: String? = nil) {
        
        self.bookingTime = bookingTime
        self.bookingID = bookingID
        self.userName = userName
        self.userEmail = userEmail
        self.userPhone = userPhone
        self.userID = userID
        self.studioID = studioID
        self.studioName = studioName
        self.comment = comment
    }
    
    convenience init(bookingTime: [Int],
                     studioName: String,
                     bookingID: Int,
                     studioID: String) {
        self.init()
        self.bookingTime = bookingTime
        self.studioName = studioName
        self.bookingID = bookingID
        self.studioID = studioID
    }
}
