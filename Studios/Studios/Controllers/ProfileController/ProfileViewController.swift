//
//  ProfileViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 11.02.23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileAvatarImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var user: FirebaseUser?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        getUserInfo()
    }
    
    private func setupVC() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Выйти",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(logOut))
        
        profileAvatarImage.layer.cornerRadius = profileAvatarImage.bounds.width / 2
    }
    
    private func getUserInfo() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        spinner.startAnimating()
        FirebaseProvider().getUserInfo(referenceType: .getUserInfo(userID: userID), userID) {[weak self] user in
            guard let self else { return }
            self.user = user
            self.spinner.stopAnimating()
            self.setOutlets()
        } failure: {
            print("ZALUPA")
        }
    }
    
    private func setOutlets() {
        guard let user else { return }
        profileNameLabel.text = "\(user.userName) \(user.userSurname)"
    }
    
    @objc private func logOut() {
            let ud = UserDefaults.standard
            let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            Environment.scenDelegate?.setLoginIsInitial()
            ud.set(nil, forKey: "uid")
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}


