//
//  FirebaseUserManager.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.03.23.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import GooglePlaces

final class FirebaseUserManager {
    static func getLike(
        referenceType: FirebaseReferenses,
        success: @escaping BoolBlock,
        failure: ErrorBlock? = nil
    ) {
        let ref = referenceType.references
        
        ref.getData(completion: { error, snapshot in
            if let error {
                failure?(error)
                print(error.localizedDescription)
            } else {
                guard let snapshot else { return }
                let value = snapshot.value as? NSDictionary
                let like = value?["like"] as? Bool ?? false
                success(like)
            }
        })
        ref.removeAllObservers()
    }
    
    static func postLikedStudio(
        studio: GMSPlace,
        referenceType: FirebaseReferenses,
        success: @escaping VoidBlock,
        failure: ErrorBlock? = nil
    ) {
        let ref = referenceType.references
        
        guard let stdioID = studio.placeID,
              let studioName = studio.name else { return }
        
        let rating = studio.rating
        let likedStudio = ["studio_id": stdioID,
                           "studio_name": studioName,
                           "studio_rating": rating,
        ] as [String : Any]
        
        ref.setValue(likedStudio) { error, result in
            if let error = error {
                failure?(error)
                print(error.localizedDescription)
            } else {
                success()
            }
        }
    }
    
    static func getLikedStudios(
        referenceType: FirebaseReferenses,
        success: @escaping FirebaseArrayLikedStudioBlock,
        failure: ErrorBlock? = nil
    ) {
        let ref = referenceType.references
        
        var likedStudiosArr: [FirebaseLikedStudioModel] = []
        
        ref.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                for likedStudios in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let likedObject = likedStudios.value as? [String: Any],
                          let likedStudio = try? FirebaseLikedStudioModel(dict: likedObject)
                    else { return }
                   
                    likedStudiosArr.append(likedStudio)
                }
            }
            success(likedStudiosArr)
            ref.removeAllObservers()
        } withCancel: { error in
            failure?(error)
            print(error.localizedDescription)
        }
    }
    
    static func removeStudioFromLiked(
        referenceType: FirebaseReferenses,
        success: @escaping VoidBlock,
        failure: ErrorBlock? = nil
    ) {
        let reference = referenceType.references
        reference.removeValue(completionBlock: { error, _ in
            if let error {
                print(error.localizedDescription)
            } else {
                success()
            }
        })
    }
    
    static func setLikeValue(
        _ likeFromFir: Bool,
        referenceType: FirebaseReferenses,
        success: @escaping VoidBlock,
        failure: ErrorBlock? = nil
    ) {
        let ref = referenceType.references
        let sendLike = ["like": likeFromFir ? false : true ] as [String : Any]
        ref.setValue(sendLike) { error,_  in
            if let error {
                failure?(error)
            } else {
                success()
            }
        }
    }
}
