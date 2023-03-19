//
//  NotificationsManager.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 18.03.23.
//

import Foundation
import UserNotifications

final class NotificationsManager {
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { acces, error in
            if acces {
                print("acces granted")
            }
        }
    }
    
    func createPushFor(_ booking: FirebaseBookingModel, time: [Double]) {
        guard let studioName = booking.studioName,
            let bookingTimeStamp = booking.bookingTime?.first else { return }
        
        let bookingStringDate = bookingTimeStamp.formatData(formatType: .dMMMHHmm)
        let content = UNMutableNotificationContent()
        content.title = "Studios"
        content.subtitle = "У вас бронь в \(studioName) на \(bookingStringDate)"
        content.sound = .default
        
        let calendar = Calendar.current
        
        time.forEach { time in
            let timeStamp = Double(bookingTimeStamp) - time
            let finalDate = Date(timeIntervalSince1970: timeStamp)
            let finalComponents = calendar.dateComponents([ .year, .month, .day, .hour, .minute], from: finalDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: finalComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            notificationCenter.add(request)
        }
    }
}

