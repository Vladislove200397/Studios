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
    
    func showAlertsWithTextField(controller: UIViewController, title: String, textFieldPlaceHoledr: String, message: String, completion: @escaping ((String) -> Void), failure: @escaping (()-> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Далее", style: .default) { (alertAction) in
            guard let textField = alertController.textFields?.first else { return }

            if !textField.text.isEmptyOrNil {
                completion(textField.text!)
            } else {
                failure()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive)
        
        alertController.addTextField { (textField) in
        textField.placeholder = "\(textFieldPlaceHoledr)"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
}
