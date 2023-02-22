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
    @IBOutlet weak var profilePhoneNumberLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var topMenu = UIMenu()
    private var user: FirebaseUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupUser()
        setupButtonMenu()
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
    
    private func setupButtonMenu() {
        let presentEditPrifileVcAction = UIAction(
            title: "Редактировать профиль",
            image: UIImage(systemName: "person")) { _ in
                self.presetnEditProfileVc()
            }
        
        let logoutAction = UIAction(
            title: "Выход",
            image: UIImage(systemName: "door.left.hand.open"),
            attributes: .destructive) { _ in
                self.presentPopupForLogoutAction()
            }
        
        let submenu = UIMenu(
            options: .displayInline,
            children: [logoutAction]
        )
        
        topMenu = UIMenu(
            title: "Настройки",
            children: [
                presentEditPrifileVcAction,
                submenu
            ])
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
            self.profilePhoneNumberLabel.text = user.userPhone
            self.setupUser()
            self.spinner.stopAnimating()
        } failure: {
        }
    }
    
    private func presentPopupForLogoutAction() {
        let popupConfigure = PopUpConfiguration(
            confirmButtonTitle: "Отмена",
            dismissButtonTitle: "Ок",
            title: "Выход",
            titleColor: .black,
            titleFont: .systemFont(ofSize: 17, weight: .bold),
            description: "Выйти из аккаунта?",
            descriptionColor: .black,
            descriptionFont: .systemFont(ofSize: 15, weight: .thin),
            image: UIImage(systemName: "exclamationmark.circle"),
            style: .confirmation,
            buttonFonts: .boldSystemFont(ofSize: 15),
            imageTintColor: .systemYellow,
            backgroundColor: .white,
            buttonBackgroundColor: .lightGray,
            confirmButtonTintColor: .white,
            dismissButtonTintColor: .red
        )
        
        PopupManager().showPopup(controller: self, configure: popupConfigure, discard:  {
            self.logOut()
        })
    }
    
    private func logOut() {
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
    
    private func presetnEditProfileVc() {
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
    
    @IBAction func settingsButtonDidTap(_ sender: UIButton) {
        sender.showsMenuAsPrimaryAction = true
        sender.menu = topMenu
    }
}



