//
//  TestController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 8.12.22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

class TestController: UIViewController {
    var ref: DatabaseReference!
    
    @IBOutlet weak var eMailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var displayNameTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    
    @IBAction func signUpButtonDidTap(_ sender: Any) {
        
        guard let email = eMailTF.text,
              let password = passwordTF.text,
              let displayName = displayNameTF.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil, user != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = displayName
                changeRequest?.commitChanges(completion: { error in
                    if error == nil {

                    }
                })
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    @IBAction func signInDidTap(_ sender: Any) {
        let userD = UserDefaults.standard
        
        guard let email = eMailTF.text,
              let password = passwordTF.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] succed, error in
            guard self != nil else { return }
            if succed != nil, error == nil {
                let uid = Auth.auth().currentUser?.uid
                print("Succed Login")
                Environment.scenDelegate?.setTabBarIsInitial()
                userD.set(uid, forKey: "uid")
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
}

extension TestController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
