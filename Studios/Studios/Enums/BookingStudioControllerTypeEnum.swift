//
//  BookingStudioControllerTypeEnum.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 8.02.23.
//

import Foundation

enum BookingStudioControllerType {
    case booking
    case editBooking
}

extension BookingStudioControllerType {
    var title: String {
        switch self {
            case .booking:          return "Выберите дату и время"
            case .editBooking:      return "Редактирование бронирования"
        }
    }
}
