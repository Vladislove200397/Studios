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

extension Date {
    func formatData(formatType: FormatTypes) -> String {
        let date = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatType.rawValue
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}

extension String {
    func formatData(formatType: FormatTypes) -> Date {
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterMonth.dateFormat = formatType.rawValue
        guard let date = dateFormatterMonth.date(from: self) else { return Date()}
        
        return date
    }
}
