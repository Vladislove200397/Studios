//
//  FirebaseReferenceEnum.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 22.01.23.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

enum FirebaseReferenses {
    
    case postStudioBookingRef(studioID: String)
    case postUserBookingRef(userID: String)
    case getBookingTimesForStudioRef(studioID: String)
    case getBookingForUserRef(userID: String)
    case getLike(userID: String, studioID: String)
    case postLike(userID: String, studioID: String)
    
    var references: DatabaseReference {
        switch self {
            case .postStudioBookingRef(studioID: let studioID):
                return  Database.database().reference().child("booking").child("studios").child("\(studioID)")
            case .postUserBookingRef(userID: let userID):
                return Database.database().reference().child("booking").child("users").child("\(userID)")
            case .getBookingTimesForStudioRef(studioID: let studioID):
                return Database.database().reference().child("booking").child("studios").child("\(studioID)")
            case .getBookingForUserRef(userID: let userID):
                return Database.database().reference().child("booking").child("users").child("\(userID)")
            case .getLike(userID: let userID, studioID: let studioID):
                return  Database.database().reference().child("users_data").child("\(userID)").child("like").child("\(studioID)")
            case .postLike(userID: let userID, studioID: let studioID):
                return Database.database().reference().child("users_data").child("\(userID)").child("likedStudios").child("\(studioID)")
        }
    }
}
