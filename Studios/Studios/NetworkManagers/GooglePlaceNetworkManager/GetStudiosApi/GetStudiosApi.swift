//
//  GetStudiosApi.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.01.23.
//

import Foundation
import GooglePlaces

final class GetStudiosAPI {
    static func getInfoFromPlaceId(
        placeID: String,
        succed: @escaping VoidBlock
    ) {
         let placeId = placeID
         let placesClient = GMSPlacesClient()
         let fields:
        GMSPlaceField = GMSPlaceField(
            rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.rating.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.userRatingsTotal.rawValue) |
            UInt(GMSPlaceField.photos.rawValue) |
            UInt(GMSPlaceField.phoneNumber.rawValue) |
            UInt(GMSPlaceField.website.rawValue) |
            UInt(GMSPlaceField.utcOffsetMinutes.rawValue) |
            UInt(GMSPlaceField.openingHours.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue)
        )

         placesClient.fetchPlace(
            fromPlaceID: placeId,
            placeFields: fields,
            sessionToken: nil,
            callback: { (place: GMSPlace?, error: Error?) in

             if let error = error {
                 print("ERROR \(error.localizedDescription)")
             }
             guard let place = place else { return }
             Service.shared.studios.append(place)
             succed()
         })
     }
}
