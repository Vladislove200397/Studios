//
//  Delegates.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.12.22.
//

import Foundation

protocol FlexibleViewDelegate: AnyObject {
    func viewDidOpen()
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

protocol ChangeProfilePhotoDelegate: AnyObject {
    func changePhoto()
}

protocol ChangeProfileSaveOrDismissChangesDelegate: AnyObject {
    func saveChanges(user: FirebaseUser)
    func dismissChanges()
}

protocol PopUpControllerDelegate: AnyObject {
    func dismissAction()
    func confirmAction()
}
