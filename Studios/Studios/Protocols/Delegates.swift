//
//  Delegates.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.12.22.
//

import Foundation

protocol PushButtonDelegate: AnyObject {
    func pushButton(studioID: String)
}

protocol FlexibleViewDelegate: AnyObject {
    func viewDidOpen(type: FlexibleViewTypes)
}

protocol SetDateFromViewDelegate: AnyObject {
    func setDate(date: String)
}

protocol SetSelectedCellDelegate: AnyObject {
    func setSelectedCell(date: String)
}

protocol SwipeCalendarDelegate: AnyObject {
    func didSwipeCalendar()
}
