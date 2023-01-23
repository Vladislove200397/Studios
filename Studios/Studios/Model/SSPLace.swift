//
//  SSPLace.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 9.11.22.
//

import Foundation
import RealmSwift

class SSPlace: Object {
    @objc dynamic var coordinatesLat: Double = 0.0
    @objc dynamic var coordinatesLng: Double = 0.0
    @objc dynamic var placeID: String = ""

    
    convenience init(placeID: String, coordinatesLat: Double, coordinatesLng: Double) {
        self.init()
        self.placeID = placeID
        self.coordinatesLat = coordinatesLat
        self.coordinatesLng = coordinatesLng

    }
    
}
