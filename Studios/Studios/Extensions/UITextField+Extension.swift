//
//  UITextFieldExtension.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 22.01.23.
//

import Foundation
import UIKit

extension UITextField {
    ///Return "true" if text in Field is validate or "false" if invalidate
    func isValid(type: ValidationType) -> Bool {
            let result = validate(string: self.text, pattern: type)
            result ? setValidState() : setInvalidState()
            return result
    }
    
    /// Setup UITextField for RegEx
    func setupForRegEx() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.8
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.leftViewMode = .always
    }
    
    //Validate UITextField
    func validateRegEx(type: ValidationType) {
        var timer: Timer?
        timer?.invalidate()
        timer = nil
        
        guard let text = self.text, !text.isEmpty else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            guard let self else { return }
            if self.validate(string: self.text, pattern: type) {
                self.setValidState()
            } else {
                self.setInvalidState()
            }
        })
    }
    
    private func setInvalidState() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.layer.borderColor = UIColor.red.cgColor
        } completion: { [weak self] isFinish in
            guard let self else { return }
            self.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    private func setValidState() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    private func validate(string: String?, pattern: ValidationType) -> Bool {
        if pattern == .none {
            return true
        }
        guard let string else { return false }
        let passPred = NSPredicate(format: "SELF MATCHES %@", pattern.rawValue)
        return passPred.evaluate(with: string)
    }

//    func enablePasswordToggle(button: UIButton) {
//        button.setImage(UIImage(named: "eye-72"), for: .normal)
//        button.setImage(UIImage(named: "closed-eye-72"), for: .selected)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
//
//        button.addTarget(self, action: #selector(togglePasswordView), for: .touchDragInside)
//        self.rightView = button
//        self.rightViewMode = .always
//
//        button.alpha = 0.4
//    }
//
//    @objc func togglePasswordView(_ button: UIButton, _ sender: Any) {
//        isSecureTextEntry.toggle()
//        button.isSelected.toggle()
//    }
    
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry){
            button.setImage(UIImage(named: "eye-72"), for: .normal)
        }else{
            button.setImage(UIImage(named: "closed-eye-72"), for: .normal)

        }
    }

    func enablePasswordToggle(){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}

