//
//  ResetPasswordViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 13.02.23.
//

import UIKit
import FirebaseAuth

final class ResetPasswordViewController: KeyboardHideViewController {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var resetPasswordButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupVC()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addBackgroundGradient()
    }
    
    private func setupVC() {
        navigationItem.setHidesBackButton(true, animated: true)
        emailTF.setupTextField()
        emailTF.backgroundColor = .clear
    }
    
    private func addBackgroundGradient() {
        let topColor = UIColor(
            hue: 0.85,
            saturation: 0.46,
            brightness: 0.19,
            alpha: 1.0).cgColor // #301a2e
        self.view.setGradientBackground(topColor: topColor, bottomColor: UIColor.black.cgColor)
    }
    
    @objc override func keyboardWillShow(_ notification: NSNotification) {
        if emailTF.isEditing  {
            moveViewWithKeyboard(
                notification: notification,
                viewBottomConstraint: self.resetPasswordButtonBottomConstraint,
                keyboardWillShow: true
            )
        }
    }
    
    @objc override func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(
            notification: notification,
            viewBottomConstraint: self.resetPasswordButtonBottomConstraint,
            keyboardWillShow: false
        )
    }
    
    func moveViewWithKeyboard
    (notification: NSNotification,
     viewBottomConstraint: NSLayoutConstraint,
     keyboardWillShow: Bool
    ) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
            let bottomConstant: CGFloat = 20
            viewBottomConstraint.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
        } else {
            viewBottomConstraint.constant = 50
        }
        
        let animator = UIViewPropertyAnimator(
            duration: keyboardDuration,
            curve: keyboardCurve) { [weak self] in
            self?.view.layoutIfNeeded()
        }

        animator.startAnimation()
    }
    
    @IBAction func resetPasswordButtonDidTap(_ sender: Any) {
        var popUpConfigure = PopUpConfiguration(
            confirmButtonTitle: "Ok",
            title: "Ошибка",
            image: UIImage(systemName: "nosign"),
            style: .error,
            imageTintColor: .red
        )
        
        guard !emailTF.text.isEmptyOrNil else {
            popUpConfigure.description = "Введите Email"
            PopUpController.show(
                on: self,
                configure: popUpConfigure
            )
            return
        }
        
        spinner.startAnimating()
        Auth.auth().sendPasswordReset(withEmail: emailTF.text!) {[weak self] error in
            guard let self else { return }
            if let error {
                let message = error.castToFirebaseError()
                popUpConfigure.description = message
                
                PopUpController.show(
                    on: self,
                    configure: popUpConfigure
                )
                self.spinner.stopAnimating()
            } else {
                popUpConfigure.title = "Успешно"
                popUpConfigure.image = UIImage(systemName: "checkmark.circle")!
                popUpConfigure.imageTintColor = .tintColor
                popUpConfigure.description = "На почтовый ящик \(self.emailTF.text!) отправлено письмо с инструкцией по сбросу пароля"
                
                PopUpController.show(
                    on: self,
                    configure: popUpConfigure
                    )
                self.spinner.stopAnimating()
            }
        }
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}
