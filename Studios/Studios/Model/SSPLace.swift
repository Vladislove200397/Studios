//
//  SSPLace.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 9.11.22.
//

import Foundation
import RealmSwift
//Скорее всего будет удален, а все ID студий перенесены в Firebase
class SSPlace: Object {
    @objc dynamic var coordinatesLat: Double = 0.0
    @objc dynamic var coordinatesLng: Double = 0.0
    @objc dynamic var placeID: String = ""

    convenience init(
        placeID: String,
        coordinatesLat: Double,
        coordinatesLng: Double
    ) {
        self.init()
        self.placeID = placeID
        self.coordinatesLat = coordinatesLat
        self.coordinatesLng = coordinatesLng
    }
    
    func createStudios() {
        let studios: [SSPlace] = [
            SSPlace(
                placeID: "ChIJRyjZzk3P20YR5OzgUsh9Zt0",
                coordinatesLat: 53.89008190576222,
                coordinatesLng: 27.56942121154621
            ),
            SSPlace(
                placeID: "ChIJpaqYN9DP20YR73hF4NmE6t8",
                coordinatesLat: 53.890056770971995,
                coordinatesLng: 27.5699165455818
            ),
            SSPlace(
                placeID: "ChIJaxs5X2_P20YRaQjKTdEGmrk",
                coordinatesLat: 53.88589806270611,
                coordinatesLng: 27.581649364152707
            ),
            SSPlace(
                placeID: "ChIJeUKnNpbP20YRlnkX8rcjtcM",
                coordinatesLat: 53.88575574363853,
                coordinatesLng: 27.58150470537655
            ),
            SSPlace(
                placeID: "ChIJ7TnotQTP20YRbk05dRHyhW8",
                coordinatesLat: 53.927064960834926,
                coordinatesLng: 27.613928014004912
            ),
            SSPlace(
                placeID: "ChIJ394Rgx7P20YRZUSXGM-b9Cg",
                coordinatesLat: 53.93769980668535,
                coordinatesLng: 27.581443240678077
            ),
            SSPlace(
                placeID: "ChIJ49rlGhLP20YRK-Qtn3NvgGA",
                coordinatesLat: 53.917505503652066,
                coordinatesLng: 27.583371865336133
            ),
            SSPlace(
                placeID: "ChIJS-_NDA7P20YRAgIDRR-0Ffs",
                coordinatesLat: 53.920489444503865,
                coordinatesLng: 27.56434466439447
            )
        ]
        
        studios.forEach { studio in
            RealmManager<SSPlace>().write(object: studio)
        }
    }
}
