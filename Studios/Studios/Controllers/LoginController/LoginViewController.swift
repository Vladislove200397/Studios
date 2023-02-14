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
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainLogoBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasswordTextField()
        setupVC()
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    
    private func setupVC() {
        self.hideKeyboardWhenTappedAround()
        self.registerForKeyboardShowNotifications(selector: #selector(self.keyboardWillShow))
        self.registerForKeyboardHideNotifications(selector: #selector(self.keyboardWillHide))
    }
    
    private func setupPasswordTextField() {
        passwordTF.enablePasswordToggle()
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if loginTF.isEditing || passwordTF.isEditing {
                moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.loginButtonBottomConstraint, keyboardWillShow: true)
            }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.loginButtonBottomConstraint, keyboardWillShow: false)
    }
    
    func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        // Keyboard's animation curve
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        // Change the constant
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0) // Check if safe area exists
            let bottomConstant: CGFloat = 20
            viewBottomConstraint.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
            self.mainLogoBottomConstraint.constant = 16
        } else {
            viewBottomConstraint.constant = 200
            self.mainLogoBottomConstraint.constant = 100
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            // Update Constraints
            self?.view.layoutIfNeeded()
        }
        
        // Perform the animation
        animator.startAnimation()
        
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
    
    private func signIn() {
        guard !loginTF.text.isEmptyOrNil,
              !passwordTF.text.isEmptyOrNil else { return }
        
        spinner.startAnimating()
        FirebaseProvider().signInWithUser(email: loginTF.text!, password: passwordTF.text!) {[weak self] in
            guard let self else { return }
            self.spinner.stopAnimating()
            Environment.scenDelegate?.setTabBarIsInitial()
            
        } failureWithEmailOrPassword: {[weak self] error in
            guard let self else { return }
            self.spinner.stopAnimating()
            Alerts().showAlert(controller: self, title: "Ошибка", message: "\(error)") {
                self.passwordTF.text = nil
            }
            
        } failureWithEmailAuthentification: {[weak self] error in
            guard let self else { return }
            self.spinner.stopAnimating()
            Alerts().showAlertsWithTwoAction(controller: self, title: "Ошибка", titleForSecondButton: "Отправить письмо еще раз", message: "\(error) \(self.loginTF.text!)") {
                self.passwordTF.text = nil
                self.logOut()
            } okComplition: {
                Auth.auth().currentUser?.sendEmailVerification()
            }
        }
    }
    
    @IBAction func loginButtonDidTap(_ sender: Any) {
        signIn()
    }
    
    @IBAction func forgotPasswordButtonDidTap(_ sender: Any) {
        Alerts().showAlertsWithTextField(controller: self,
                                         title: "Сброс пароля",
                                         textFieldPlaceHoledr: "Введите email",
                                         message: "Введите email который используется для входа в аккаунт") {[weak self] login in
            guard let self else { return }
            Auth.auth().sendPasswordReset(withEmail: login) { error in
                if let error {
                    Alerts().showAlert(controller: self, title: "Ошибка", message: "Аккаунт с таким логином не найден или логин введен не корректно.")
                    print(error.localizedDescription)
                } else {
                    Alerts().showAlert(controller: self,
                                       title: "",
                                       message: "На почтовый ящик \(login) отправлено письмо с инструкцией по сбросу пароля")
                }
            }
        } failure: {
            Alerts().showAlert(controller: self, title: "Ошибка", message: "Введите логин")
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case loginTF:
                passwordTF.becomeFirstResponder()
                return true
            case passwordTF:
                signIn()
                textField.resignFirstResponder()
                return true
            default: break
        }
        return true
    }
}
