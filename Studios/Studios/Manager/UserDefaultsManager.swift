//
//  UserDefaultsManager.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 7.03.23.
//

import Foundation

class UserDefaultsManager {
    static let userDefaultsManager = UserDefaults.standard
    
    static func detectFirstLaunch(notLaunched: @escaping BoolBlock) {
        let launchedBefore = userDefaultsManager.bool(forKey: "launchedBefore")
            notLaunched(launchedBefore)
    }
}
