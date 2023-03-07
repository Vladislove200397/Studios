//
//  ProfileEditCellTypes.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 1.03.23.
//

import Foundation

enum ProfileEditCellTypes {
    case profile
    case editName
    case editSurname
    case editPhoneNumber
    case saveChanges
    case dismiss
}

extension ProfileEditCellTypes {
    var textFieldPlaceHolder: String {
        switch self {
            case .editName:
                return "Имя"
            case .editSurname:
                return "Фамилия"
            case .editPhoneNumber:
                return "+375291234567"
            default:
                return ""
        }
    }
}
