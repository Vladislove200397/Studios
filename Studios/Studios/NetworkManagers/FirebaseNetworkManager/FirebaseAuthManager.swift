//
//  FirebaseAuthManager.swift
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

final class FirebaseAuthManager {
    static func createUser(
        email: String,
        password: String,
        displayName: String,
        success: @escaping StringBlock,
        failure: @escaping ErrorBlock
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if let user  {
                let uid = user.user.uid
                let changeRequest = user.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges(completion: { error in
                    if let error {
                        failure(error)
                        print(error.localizedDescription)
                    } else {
                        print("Успешно дабвлено имя пользователя")
                    }
                })
                Auth.auth().currentUser?.sendEmailVerification()
                success(uid)
            } else if let error {
                failure(error)
                print(error.localizedDescription)
            }
        }
    }
    
    static func signInWithUser(
        email: String,
        password: String,
        success: @escaping VoidBlock,
        failureWithEmailOrPassword: @escaping StringBlock,
        failureWithEmailAuthentification: @escaping StringBlock
    ) {
        let userD = UserDefaults.standard
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let user {
                let uid = user.user.uid
                if user.user.isEmailVerified {
                    success()
                    userD.set(uid, forKey: "uid")
                } else {
                    failureWithEmailAuthentification(user.user.isEmailVerifiedMessage)
                }
            } else if let error {
                failureWithEmailOrPassword(error.castToFirebaseError())
            }
        }
    }
    
    static func saveUser(
        referenceType: FirebaseReferenses,
        displayName: String,
        surname: String,
        phoneNumber: String,
        succes: @escaping RequestBlock,
        failure: @escaping ErrorBlock
    ) {
        let ref = referenceType.references

        let user = ["display_name": displayName,
                   "surname": surname,
                   "phone_number": phoneNumber,
        ] as? [String: Any]
        
        ref.setValue(user) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                failure(error)
            } else {
                succes()
                print("succesfully added userInfo to FIRA")
            }
        }
    }
    
    static func getUserInfo(
        referenceType: FirebaseReferenses,
        _ userID: String,
        success: @escaping FirebaseUserBlock,
        failure: @escaping VoidBlock
    ) {
        let ref = referenceType.references
        
        ref.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                guard let userObject = snapshot.childSnapshot(forPath: "\(userID)").value as? [String: Any],
                        let user = try? FirebaseUser(dict: userObject)
                else { return }
                success(user)
            }
            ref.removeAllObservers()
        } withCancel: { error in
            failure()
            print(error.localizedDescription)
        }
    }
    
    static func saveAuthuserInfo(
        photoURL: URL,
        displaName: String,
        complition: @escaping RequestBlock,
        failure: @escaping ErrorBlock
    ) {
        guard let user = Auth.auth().currentUser else { return }
        
        let changeRequest = user.createProfileChangeRequest()
        
        changeRequest.displayName = displaName
        changeRequest.photoURL = photoURL
        changeRequest.commitChanges { error in
            guard let error else {
                complition()
                return
            }
            failure(error)
            print(error.localizedDescription)
        }
    }
}
