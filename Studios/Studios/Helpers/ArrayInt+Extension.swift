//
//  ArrayIntExtension.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 23.01.23.
//

import Foundation

extension Array<Int> {
    
    func checkArrCount() -> Bool {
        if self.count > 1 {
            return true
        } else {
            return false
        }
    }
}
