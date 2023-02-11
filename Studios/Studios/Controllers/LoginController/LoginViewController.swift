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
    
    private let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasswordTextField()
    }
    
    private func setupPasswordTextField() {
        let button = UIButton()
        passwordTF.enablePasswordToggle(button: button)
    }
    
    private func logOut() {
        let ud = UserDefaults.standard
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            ud.set(nil, forKey: "uid")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func registrationButtonDidTap(_ sender: Any) {
        let registrationVC = RegistrationUserViewController(nibName: String(describing: RegistrationUserViewController.self), bundle: nil)
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    @IBAction func loginButtonDidTap(_ sender: Any) {
        guard !loginTF.text.isEmptyOrNil,
              !passwordTF.text.isEmptyOrNil else { return }
        
        spinner.startAnimating()
        FirebaseProvider().signInWithUser(email: loginTF.text!, password: passwordTF.text!) {[weak self] in
            guard let self else { return }
            self.spinner.stopAnimating()
            Environment.scenDelegate?.setTabBarIsInitial()
        } failureWithEmailOrPassword: {[weak self] in
            guard let self else { return }
            self.spinner.stopAnimating()
            Alerts().showAlert(controller: self, title: "Ошибка", message: "Неверный логин или пароль") {
                self.passwordTF.text = nil
            }
        } failureWithEmailAuthentification: {[weak self] in
            guard let self else { return }
            self.spinner.stopAnimating()

            Alerts().showAlertsWithTwoAction(controller: self, title: "Ошибка", titleForSecondButton: "Отправить письмо еще раз", message: "Необходимо подтвердить адрес электронной почты. Проверьте почтовый ящик \(self.loginTF.text!)") {
                self.passwordTF.text = nil
                self.logOut()
            } okComplition: {
                Auth.auth().currentUser?.sendEmailVerification()
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
