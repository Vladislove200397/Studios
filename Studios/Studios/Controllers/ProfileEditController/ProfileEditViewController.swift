//
//  ProfileEditViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 11.02.23.
//

import UIKit
import QCropper
import Photos
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseDatabase

class ProfileEditViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    
    private var profileImageValue: UIImage?
    private var user: FirebaseUser?
    var updateBlock: ((UIImage) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
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
        profileImage.clipsToBounds = true
        profileImage.image = profileImageValue
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        nameTF.setupTextField()
        surnameTF.setupTextField()
        phoneNumberTF.setupTextField()
        
        nameTF.text = user?.userName
        surnameTF.text = user?.userSurname
        phoneNumberTF.text = user?.userPhone
        hideKeyboardWhenTappedAround()
    }
    
    func set(_ user: FirebaseUser, profileImage: UIImage) {
        self.user = user
        self.profileImageValue = profileImage
    }
    
    private func presentPicker(_ cameraOrPhoto: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = cameraOrPhoto
        picker.allowsEditing = false
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
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
    
    func saveChangedInfo(complition: @escaping (() ->Void)) {
        guard !nameTF.text.isEmptyOrNil,
              !surnameTF.text.isEmptyOrNil,
              !phoneNumberTF.text.isEmptyOrNil,
              let user = Auth.auth().currentUser,
              let photo = profileImage.image else { return }
        
        FirebaseProvider().uploadPhoto(userID: user.uid, photo: photo) { url in
            FirebaseProvider().saveUser(
                referenceType: .addUserInfo(userID: user.uid),
                self.nameTF.text!,
                self.surnameTF.text!,
                self.phoneNumberTF.text!
            )
            FirebaseProvider().saveAuthuserInfo(
                photoURL: url,
                displaName: self.nameTF.text!) {
                    complition()
                }
        }
    }
    
    @IBAction func changeProfileButtonDidTap(_ sender: Any) {
        let popupConfigure = PopUpConfiguration(
            confirmButtonTitle: "Камера",
            dismissButtonTitle: "Выбрать из фото",
            cancelButtonTitle: "Отмена",
            title: "Выберите источник фото",
            titleColor: .black,
            titleFont: .systemFont(ofSize: 17, weight: .bold),
            description: "Снимите новое фото или выберите из сохраненных.",
            descriptionColor: .black,
            descriptionFont: .systemFont(ofSize: 15, weight: .thin),
            image: UIImage(systemName: "questionmark.circle"),
            style: .threeButtons,
            buttonFonts: .boldSystemFont(ofSize: 15),
            imageTintColor: .tintColor,
            backgroundColor: .white,
            buttonBackgroundColor: .lightGray,
            confirmButtonTintColor: .white,
            dismissButtonTintColor: .white,
            cancelButtonTintColor: .red
        )
        
        PopupManager().showPopup(controller: self, configure: popupConfigure) {
            self.presentPicker(.camera)
        } discard: {
            self.presentPicker(.photoLibrary)
        }
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func logoutButtonDidTap(_ sender: Any) {
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
    
    @IBAction func saveChangesButtonDidTap(_ sender: Any) {
        saveChangedInfo {
            self.updateBlock?(self.profileImage.image!)
            self.dismiss(animated: true)
        }
    }
}

extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let cropper = CropperViewController(originalImage: image)
            cropper.delegate = self
            picker.dismiss(animated: true) {
                self.present(cropper, animated: true, completion: nil)
            }
        }
    }
}

extension ProfileEditViewController: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            self.profileImage.image = image
        }
    }
}

extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
