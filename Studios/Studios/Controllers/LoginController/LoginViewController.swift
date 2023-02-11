//
//  LoginViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 9.02.23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

class LoginViewController: UIViewController {
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func registrationButtonDidTap(_ sender: Any) {
        let registrationVC = RegistrationUserViewController(nibName: String(describing: RegistrationUserViewController.self), bundle: nil)
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    
    @IBAction func loginButtonDidTap(_ sender: Any) {
        guard !loginTF.text.isEmptyOrNil,
              !passwordTF.text.isEmptyOrNil else { return }
        
        spinner.startAnimating()
        FirebaseProvider().signInWithUser(email: loginTF.text!, password: passwordTF.text!) {
            self.spinner.stopAnimating()
            Environment.scenDelegate?.setTabBarIsInitial()
            
        } failure: {
            self.spinner.stopAnimating()
            Alerts().showAlert(controller: self, title: "Ошибка", message: "Неверный логин или пароль") {
                self.passwordTF.text = nil
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
