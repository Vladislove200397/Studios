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
    var userSurname: String
    var userPhone: String
    
    init(userName: String, userSurname: String, userPhone: String) {
        self.userName = userName
        self.userSurname = userSurname
        self.userPhone = userPhone
    }
}
