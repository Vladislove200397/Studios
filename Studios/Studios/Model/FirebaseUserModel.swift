//
//  FirebaseUserModel.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 12.12.22.
//

import Foundation
import FirebaseAuth

class FirebaseUser {
    var userName: String
    var userEmail: String
    var userPhone: String
    var uid: String
    var photoURL: String
    
    init(userName: String, userEmail: String, userPhone: String, uid: String, photoURL: String) {
        self.userName = userName
        self.userEmail = userEmail
        self.userPhone = userPhone
        self.uid = uid
        self.photoURL = photoURL
    }
}
