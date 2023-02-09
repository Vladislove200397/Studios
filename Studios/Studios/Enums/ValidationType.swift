//
//  RegularExpression.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 22.01.23.
//

import Foundation

enum ValidationType: String {
    case phone = "(\\+375|375)(29|25|44|33)(\\d{3})(\\d{2})(\\d{2})"
    case email = "[A-z0-9_.+-]+@[A-z0-9-]+(\\.[A-z0-9-]{2,})"
    case name = "[\\S]{2,16}"
    case password = "[\\S]{8,25}"
    case none = "[\\S]"
    case address = "[A-z 0-9]+, [A-z 0-9]+, (кв|квартира) +[0-9]"
}
