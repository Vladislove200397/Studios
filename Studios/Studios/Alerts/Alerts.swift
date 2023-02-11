//
//  Alerts.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 22.01.23.
//

import Foundation
import UIKit

class Alerts {
    func showAlert(controller: UIViewController, title: String, message: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertsWithTwoAction(controller: UIViewController, title: String, titleForSecondButton: String, message: String, dismissCompletion: @escaping (() -> Void), okComplition: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Закрыть", style: .destructive) { (_) in
            dismissCompletion()
        }
        
        let okAction = UIAlertAction(title: titleForSecondButton, style: .default) {_ in
            okComplition()
        }
        
        alertController.addAction(okAction)
        alertController.addAction(dismissAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}
