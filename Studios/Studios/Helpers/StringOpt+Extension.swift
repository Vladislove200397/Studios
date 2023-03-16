//
//  StringOpt+Extension.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 9.02.23.
//

import Foundation

extension Optional where Wrapped == String {
    
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
}
