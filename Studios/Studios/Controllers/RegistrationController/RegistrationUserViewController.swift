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

class RegistrationUserViewController: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var doublePasswordTF: UITextField!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField: UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        registerForKeyboardNotifications()
        setupVC()
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
        print("DEINIT")
    }
    
    private func setupVC() {
        hideKeyboardWhenTappedAround()
        scrollView.isScrollEnabled = false
        registrationButton.isEnabled = false
        self.title = "Регистрация"
    }
    
    private func setupTextFields() {
        emailTF.setupForRegEx()
        phoneNumberTF.setupForRegEx()
        passwordTF.setupForRegEx()
        
        emailTF.validateRegEx(type: .email)
        phoneNumberTF.validateRegEx(type: .phone)
        passwordTF.validateRegEx(type: .password)
    }
    
    private func isValidTextField() {
        let results = [phoneNumberTF.isValid(type:.phone), emailTF.isValid(type: .email), passwordTF.isValid(type: .password)]
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
    
    private func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
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
    
    @objc private func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
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
        
        FirebaseProvider().createUser(email: emailTF.text!,
                                      password: passwordTF.text!,
                                      displayName: nameTF.text!) { [weak self] uid in
            guard let self else { return }
            FirebaseProvider().saveUser(referenceType: .addUserInfo(userID: uid),
                                        self.emailTF.text!,
                                        self.passwordTF.text!,
                                        self.nameTF.text!,
                                        self.surnameTF.text!,
                                        self.phoneNumberTF.text!,
                                        uid)
            
            Alerts().showAlert(controller: self,
                               title: "Успешная регистрация",
                               message: "") {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } failure: {[weak self] in
            guard let self else { return }
            Alerts().showAlert(controller: self,
                               title: "Ошибка",
                               message: "Пользователь с таким email уже существует")
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
