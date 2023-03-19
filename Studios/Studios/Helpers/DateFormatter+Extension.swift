//
//  ExtensionDateFormatter.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 29.12.22.
//

import Foundation

extension Int {    
    func formatData(formatType: FormatTypes) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = formatType.rawValue
        dayTimePeriodFormatter.locale = .current
        let dateString = dayTimePeriodFormatter.string(from: date)
        
        return dateString
    }
}
