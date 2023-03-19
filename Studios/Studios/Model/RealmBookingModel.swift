//
//  RealmBookingModel.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 18.03.23.
//

import Foundation
import RealmSwift

class RealmBookingModel: Object {
    @objc dynamic var bookingID: Int = 0
    @objc dynamic var studioName: String = ""
    var bookingTime = List<Int>()

    convenience init(
        bookingID: Int,
        studioName: String,
        bookingTime: List<Int>
    ) {
        self.init()
        self.bookingID = bookingID
        self.studioName = studioName
        self.bookingTime = bookingTime
    }
}
