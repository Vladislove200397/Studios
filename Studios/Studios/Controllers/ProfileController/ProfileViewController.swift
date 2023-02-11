//
//  ProfileViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 11.02.23.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileAvatarImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        
    }
    
    private func setupVC() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Выйти",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(logOut))
        
        profileAvatarImage.layer.cornerRadius = profileAvatarImage.bounds.width / 2
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


