//
//  FirebaseLikedStudioModel.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.01.23.
//

import Foundation

final class FirebaseLikedStudioModel {
    var studioID: String?
    var studioName: String?
    var studioRating: Float?
    
    init(
        studioID: String,
        studioName: String,
        studioRating: Float
    ) {
        self.studioID = studioID
        self.studioName = studioName
        self.studioRating = studioRating
    }
    
    init(dict: [String: Any]) throws {
        self.studioID = dict["studio_id"] as? String
        self.studioName = dict["studio_name"] as? String
        self.studioRating = dict["studio_rating"] as? Float
    }
}
