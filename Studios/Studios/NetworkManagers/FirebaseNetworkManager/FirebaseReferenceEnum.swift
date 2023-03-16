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
    case getLikedStudios(userID: String)
    case removeLikedStudio(userID: String, studioID: String)
    case addUserInfo(userID: String)
    case getUserInfo
    case removeStudioBookingRef(studioID: String)
    case removeUserBookingRef(userID: String)
    
    var references: DatabaseReference {
        switch self {
            case .postStudioBookingRef(studioID: let studioID):
                return Database
                        .database()
                        .reference()
                        .child("studios_data")
                        .child("booking")
                        .child("studios")
                        .child("\(studioID)")
                
            case .postUserBookingRef(userID: let userID):
                return Database
                        .database()
                        .reference()
                        .child("users_data")
                        .child("booking")
                        .child("users")
                        .child("\(userID)")
                
            case .getBookingTimesForStudioRef(studioID: let studioID):
                return Database
                        .database()
                        .reference()
                        .child("studios_data")
                        .child("booking")
                        .child("studios")
                        .child("\(studioID)")
                
            case .getBookingForUserRef(userID: let userID):
                return Database
                        .database()
                        .reference()
                        .child("users_data")
                        .child("booking")
                        .child("users")
                        .child("\(userID)")
                
            case .getLike(userID: let userID, studioID: let studioID):
                return Database
                        .database()
                        .reference()
                        .child("users_data")
                        .child("\(userID)")
                        .child("like")
                        .child("\(studioID)")
                
            case .postLike(userID: let userID, studioID: let studioID):
                return Database
                        .database()
                        .reference()
                        .child("users_data")
                        .child("\(userID)")
                        .child("likedStudios")
                        .child("\(studioID)")
                
                
            case .getLikedStudios(userID: let userID):
                return Database
                        .database()
                        .reference()
                        .child("users_data")
                        .child("\(userID)")
                        .child("likedStudios")
               
                
            case .removeLikedStudio(userID: let userID, studioID: let studioID):
                return Database
                        .database()
                        .reference()
                        .child("users_data")
                        .child("\(userID)")
                        .child("likedStudios")
                        .child("\(studioID)")
               
                
            case .addUserInfo(userID: let userID):
                return Database
                        .database()
                        .reference()
                        .child("private_users_data")
                        .child("\(userID)")
                
            case .getUserInfo:
                return Database
                        .database()
                        .reference()
                        .child("private_users_data")
                
            case .removeStudioBookingRef(studioID: let studioID):
                return Database
                        .database()
                        .reference()
                        .child("studios_data")
                        .child("booking")
                        .child("studios")
                        .child("\(studioID)")
                
            case .removeUserBookingRef(userID: let userID):
                return Database
                        .database()
                        .reference()
                        .child("users_data")
                        .child("booking")
                        .child("users")
                        .child("\(userID)")
               
        }
    }
}
