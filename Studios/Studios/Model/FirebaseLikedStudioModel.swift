//
//  FirebaseLikedStudioModel.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.01.23.
//

import Foundation

class FirebaseLikedStudioModel {
    var studioID: String
    var studioName: String
    var studioRating: Float
    
    init(studioID: String, studioName: String, studioRating: Float) {
        self.studioID = studioID
        self.studioName = studioName
        self.studioRating = studioRating
    }
}
