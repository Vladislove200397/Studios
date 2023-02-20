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
import FirebaseStorage

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileAvatarImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var user: FirebaseUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupUser()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setBackgroundGradient()
    }
    
    private func setBackgroundGradient() {
        let topColor = UIColor(hue: 0.71, saturation: 0.72, brightness: 0.25, alpha: 1.0).cgColor
        self.view.setGradientBackground(topColor: topColor, bottomColor: UIColor.black.cgColor)
    }
    
    private func setupVC() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        profileAvatarImage.clipsToBounds = true
        profileAvatarImage.layer.cornerRadius = profileAvatarImage.frame.width / 2
    }
    
    private func setupUser() {
        getUserInfo()
        FirebaseProvider().downloadData { image in
            self.profileAvatarImage.image = image
        }
    }
    
    private func getUserInfo() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        spinner.startAnimating()
        FirebaseProvider().getUserInfo(referenceType: .getUserInfo(userID: userID), userID) {[weak self] user in
            guard let self else { return }
            self.user = user
            self.profileNameLabel.text = "\(user.userName) \(user.userSurname)"
            self.setupUser()
            self.spinner.stopAnimating()
        } failure: {
        }
    }
    
    @IBAction func changeProfileInfoButtonDidTap(_ sender: Any) {
        guard let user else { return }
        let profileEditVC = ProfileEditViewController(nibName: String(describing: ProfileEditViewController.self), bundle: nil)
        profileEditVC.set(user, profileImage: profileAvatarImage.image!)
        
        profileEditVC.updateBlock = { profileImage in
            self.profileAvatarImage.image = profileImage
            self.setupUser()
        }
        
        profileEditVC.modalTransitionStyle = .crossDissolve
        profileEditVC.modalPresentationStyle = .overCurrentContext
        present(profileEditVC, animated: true)
    }
}


