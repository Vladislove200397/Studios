//
//  RegistrationUserViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 11.02.23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

class RegistrationUserViewController: KeyboardHideViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var doublePasswordTF: UITextField!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var registrationButtonBottomContraint: NSLayoutConstraint!
    
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupVC()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addBackgroundGradient()
    }
    
    private func setupVC() {
        scrollView.isScrollEnabled = false
        registrationButton.isEnabled = false
        self.hideKeyboardWhenTappedAround()
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func addBackgroundGradient() {
        let topColor = UIColor(
            hue: 0.26,
            saturation: 0.83,
            brightness: 0.19,
            alpha: 1.0).cgColor // #73db26
        
        self.view.setGradientBackground(
            topColor: topColor,
            bottomColor: UIColor.black.cgColor
        )
    }
    
    private func setupTextFields() {
        nameTF.setupTextField()
        surnameTF.setupTextField()
        emailTF.setupTextField()
        phoneNumberTF.setupTextField()
        passwordTF.setupTextField()
        doublePasswordTF.setupTextField()
        
        nameTF.backgroundColor = .clear
        surnameTF.backgroundColor = .clear
        emailTF.backgroundColor = .clear
        phoneNumberTF.backgroundColor = .clear
        passwordTF.backgroundColor = .clear
        doublePasswordTF.backgroundColor = .clear
        
        emailTF.validateRegEx(type: .email)
        phoneNumberTF.validateRegEx(type: .phone)
        passwordTF.validateRegEx(type: .password)
    }
    
    private func isValidTextField() {
        let results = [phoneNumberTF.isValid(type:.phone),
                       emailTF.isValid(type: .email),
                       passwordTF.isValid(type: .password)]
        
        let positive = results.filter( {$0 }).count == results.count
        
        if positive {
            registrationButton.isEnabled = true
        } else {
            registrationButton.isEnabled = false
        }
    }
    
    private func checkPassword() {
        let positive = passwordTF.text == doublePasswordTF.text
        if positive {
            registrationButton.isEnabled = true
        } else {
            registrationButton.isEnabled = false
        }
    }
    
    @objc override func keyboardWillShow(_ notification: NSNotification) {
        keyboardWasShown(notification: notification)
    }
    
    @objc override func keyboardWillHide(_ notification: NSNotification) {
        keyboardWillBeHidden(notification: notification)
    }

    private func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.registrationButtonBottomContraint.constant = 20
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        if let activeField = self.activeField {
            var point = activeField.frame.origin
            point.y += activeField.frame.size.height
            if (!aRect.contains(point)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    private func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
        self.registrationButtonBottomContraint.constant = 199
    }
    
    private func presentPopup(email: String) {
        let popupConfigure = PopUpConfiguration(
            confirmButtonTitle: "Ок",
            title: "Успешная регистрация",
            titleColor: .black,
            titleFont: .systemFont(ofSize: 17, weight: .bold),
            description: "На почтовый ящик \(email) отправлено письмо для подтверждения регистрации.",
            descriptionColor: .black,
            descriptionFont: .systemFont(ofSize: 15, weight: .thin),
            image: UIImage(systemName: "checkmark.circle"),
            style: .error,
            buttonFonts: .boldSystemFont(ofSize: 15),
            imageTintColor: .systemGreen,
            backgroundColor: .white,
            buttonBackgroundColor: .lightGray,
            confirmButtonTintColor: .white
        )
        
        PopupManager().showPopup(
            controller: self,
            configure: popupConfigure) {
            self.navigationController?.popToRootViewController(animated: true)
        } discard: {
        }
    }
    
    private func presentErrorPopup() {
        let popupConfigure = PopUpConfiguration(
            confirmButtonTitle: "Ок",
            title: "Ошибка",
            titleColor: .black,
            titleFont: .systemFont(ofSize: 17, weight: .bold),
            description: "Пользователь с таким email уже существует.",
            descriptionColor: .black,
            descriptionFont: .systemFont(ofSize: 15, weight: .thin),
            image: UIImage(systemName: "nosign"),
            style: .error,
            buttonFonts: .boldSystemFont(ofSize: 15),
            imageTintColor: .red,
            backgroundColor: .white,
            buttonBackgroundColor: .lightGray,
            confirmButtonTintColor: .white
        )
        
        PopupManager().showPopup(controller: self, configure: popupConfigure) {
            self.emailTF.text = nil
        } discard: {
        }
    }
    
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func textFieldDidBeginEditing(_ sender: UITextField) {
        activeField = sender
    }
    
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        activeField = nil
    }
    
    @IBAction func textFieldsDidEditing(_ sender: UITextField) {
        switch sender.tag {
            case 1002:
                sender.validateRegEx(type: .email)
                isValidTextField()
            case 1003:
                sender.validateRegEx(type: .phone)
                isValidTextField()
            case 1004:
                sender.validateRegEx(type: .password)
                isValidTextField()
                checkPassword()
            case 1005:
                sender.validateRegEx(type: .password)
                isValidTextField()
                checkPassword()
            default: break
        }
    }
    
    @IBAction func registrationButtonDidTap(_ sender: Any) {
        guard !nameTF.text.isEmptyOrNil,
              !emailTF.text.isEmptyOrNil,
              !phoneNumberTF.text.isEmptyOrNil,
              !passwordTF.text.isEmptyOrNil,
              !surnameTF.text.isEmptyOrNil else { return }
        
        FirebaseProvider().createUser(viewController: self,
                                      email: emailTF.text!,
                                      password: passwordTF.text!,
                                      displayName: nameTF.text!) { [weak self] uid in
            guard let self else { return }
            
            FirebaseProvider().saveUser(
                referenceType: .addUserInfo(userID: uid),
                self.nameTF.text!,
                self.surnameTF.text!,
                self.phoneNumberTF.text!
            )
            self.presentPopup(email: self.emailTF.text!)
        } failure: {[weak self] in
            guard let self else { return }
            self.presentErrorPopup()
        }
    }
}

extension RegistrationUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case nameTF:
                surnameTF.becomeFirstResponder()
                return true
            case surnameTF:
                emailTF.becomeFirstResponder()
                return true
            case emailTF:
                phoneNumberTF.becomeFirstResponder()
                return true
            case phoneNumberTF:
                passwordTF.becomeFirstResponder()
                return true
            case passwordTF:
                doublePasswordTF.becomeFirstResponder()
                return true
            default:
                textField.resignFirstResponder()
                return true
        }
    }
}
