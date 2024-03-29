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

final class LoginViewController: KeyboardHideViewController {
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainLogoBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupVC()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addBackgroundGradient()
    }
    
    private func addBackgroundGradient() {
        let topColor = UIColor(
            hue: 0.64,
            saturation: 0.68,
            brightness: 0.19,
            alpha: 1.0).cgColor // #2e3c91
        
        self.view.setGradientBackground(
            topColor: topColor,
            bottomColor: UIColor.black.cgColor
            )
    }

    private func setupVC() {
        self.hideKeyboardWhenTappedAround()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupTextFields() {
        passwordTF.enablePasswordToggle()
        loginTF.setupTextField()
        passwordTF.setupTextField()
        loginTF.backgroundColor = .clear
        passwordTF.backgroundColor = .clear
    }
    
    @objc override func keyboardWillShow(_ notification: NSNotification) {
        if loginTF.isEditing || passwordTF.isEditing {
                moveViewWithKeyboard(
                    notification: notification,
                    viewBottomConstraint: self.loginButtonBottomConstraint,
                    keyboardWillShow: true
                )
            }
    }
    
    @objc override func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(
            notification: notification,
            viewBottomConstraint: self.loginButtonBottomConstraint,
            keyboardWillShow: false
        )
    }
    
    func moveViewWithKeyboard(
        notification: NSNotification,
        viewBottomConstraint: NSLayoutConstraint,
        keyboardWillShow: Bool
    ) {
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
            viewBottomConstraint.constant = 157
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
        let registrationVC = RegistrationUserViewController(
            nibName: String(describing: RegistrationUserViewController.self),
            bundle: nil
        )
        
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    private func signIn() {
        var configure = PopUpConfiguration(
            confirmButtonTitle: "Ok",
            title: "Ошибка",
            image: UIImage(systemName: "nosign"),
            style: .error,
            imageTintColor: .red
        )
        
        guard !loginTF.text.isEmptyOrNil,
              !passwordTF.text.isEmptyOrNil else {
            configure.description = "Введите логин и пароль"
            PopUpController.show(on: self, configure: configure)
            return
        }
        
        spinner.startAnimating()

        FirebaseAuthManager.signInWithUser(
            email: loginTF.text!,
            password: passwordTF.text!
        ) { [weak self] in
            guard let self else { return }
            self.spinner.stopAnimating()
            Environment.scenDelegate?.setTabBarIsInitial()
            
        } failureWithEmailOrPassword: { [weak self] error in
            guard let self else { return }
            self.spinner.stopAnimating()
            configure.description = error
            PopUpController.show(
                on: self,
                configure: configure,
                discard:  {
                self.passwordTF.text = nil
            })
            
            
        } failureWithEmailAuthentification: {[weak self] error in
            guard let self else { return }
            configure.description = error
            configure.confirmButtonTitle = "Отправить письмо еще раз"
            self.spinner.stopAnimating()
            
            PopUpController.show(
                on: self,
                configure: configure
            ) {
                Auth.auth().currentUser?.sendEmailVerification()
                self.passwordTF.text = nil
                self.logOut()
            } discard: {
            }
        }
    }
    
    @IBAction func loginButtonDidTap(_ sender: Any) {
        signIn()
    }
    
    @IBAction func forgotPasswordButtonDidTap(_ sender: Any) {
        let resetPasswordVC = ResetPasswordViewController(
            nibName: String(describing: ResetPasswordViewController.self),
            bundle: nil
        )
        
        navigationController?.pushViewController(resetPasswordVC, animated: true)
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
