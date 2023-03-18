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

final class ProfileEditViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var profileImageValue: UIImage?
    private var profileInfoCellIndexPath: [IndexPath] = []
    private var user: FirebaseUser?
    private var userName: String?
    private var userSurname: String?
    private var userPhoneNumber: String?
    private var updateImageBlock: ImageBlock?
    private var tableViewDataSource: [[ProfileEditCellTypes]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setBackgroundGradient()
    }
    
    private func setBackgroundGradient() {
        let topColor = UIColor(
            hue: 0.71,
            saturation: 0.72,
            brightness: 0.25,
            alpha: 1.0).cgColor
        
        self.view.setGradientBackground(
            topColor: topColor,
            bottomColor: UIColor.black.cgColor
        )
    }
    
    private func setupVC() {
        hideKeyboardWhenTappedAround()
        setupTableViewSections()
        registerCell()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func registerCell() {
        let profileCellNib = UINib(nibName: ProfileCell.id, bundle: nil)
        let profileEditCellNib = UINib(nibName: ProfileEditCell.id, bundle: nil)
        tableView.register(profileCellNib, forCellReuseIdentifier: ProfileCell.id)
        tableView.register(profileEditCellNib, forCellReuseIdentifier: ProfileEditCell.id)
    }
    
    func set(_ user: FirebaseUser, profileImage: UIImage, updateImageBlock: ImageBlock? = nil) {
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
    
    private func setupTableViewSections() {
        var section: [[ProfileEditCellTypes]] = [[.profile]]
        let nameAndSurnameSection: [ProfileEditCellTypes] = [.editName,.editSurname]
        let phoneNumber: [ProfileEditCellTypes] = [.editPhoneNumber]
        let saveChanges: [ProfileEditCellTypes] = [.saveChanges]
        let dismissChanges: [ProfileEditCellTypes] = [.dismiss]
        
        section.append(nameAndSurnameSection)
        section.append(phoneNumber)
        section.append(saveChanges)
        section.append(dismissChanges)
        tableViewDataSource = section
    }
    
    func saveChangedInfo(complition: @escaping VoidBlock) {
        let group = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "uploadData-concurrentQueue", attributes: .concurrent)
        var error: Error?
        var photoURL: URL?
        
        guard let userName = user?.userName,
              let userSurname = user?.userSurname,
              let userPhoneNumber = user?.userPhone,
              let user = Auth.auth().currentUser,
              let profileImageValue else { return }
        
        let photoUploadWorkItem = DispatchWorkItem {
            FirebaseStorageManager.uploadPhoto(
                userID: user.uid,
                photo: profileImageValue) { url in
                    photoURL = url
                    group.leave()
                } failure: { requestError in
                    error = requestError
                    group.leave()
                }
        }
        
        let saveUserWorkItem = DispatchWorkItem {
            FirebaseAuthManager.saveUser(
                referenceType: .addUserInfo(userID: user.uid),
                displayName: userName,
                surname: userSurname,
                phoneNumber: userPhoneNumber) {
                    group.leave()
                } failure: { requestError in
                    error = requestError
                    group.leave()
                }
        }
        
        let saveAuthuserInfoWorkItem = DispatchWorkItem {
            guard let photoURL else {
                group.leave()
                return
            }
            FirebaseAuthManager.saveAuthuserInfo(
                photoURL: photoURL,
                displaName: userName) {
                    group.leave()
                } failure: { requestError in
                    error = requestError
                    group.leave()
                }
        }
        
        group.enter()
        concurrentQueue.async(execute: photoUploadWorkItem)
        
        group.notify(queue: .main) {
            guard error != nil,
                  photoURL == nil else {
                group.enter()
                concurrentQueue.async(execute: saveAuthuserInfoWorkItem)
                group.enter()
                concurrentQueue.async(execute: saveUserWorkItem)
                complition()
                return
            }
        }
    }
    
    private func chageProfileButtonDidTap() {
        let popupConfigure = PopUpConfiguration(
            confirmButtonTitle: "Камера",
            dismissButtonTitle: "Выбрать из фото",
            cancelButtonTitle: "Отмена",
            title: "Выберите источник фото",
            description: "Снимите новое фото или выберите из сохраненных.",
            image: UIImage(systemName: "questionmark.circle"),
            style: .threeButtons,
            imageTintColor: .tintColor,
            cancelButtonTintColor: .red
        )
        
        PopUpController.show(
            on: self,
            configure: popupConfigure
        ) {[weak self] in
            guard let self else { return }
            self.presentPicker(.camera)
            
        } discard: {[weak self] in
            guard let self else { return }
            self.presentPicker(.photoLibrary)
        }
    }
}

extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[
            UIImagePickerController
            .InfoKey
            .originalImage] as? UIImage {
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
           let image = cropper
            .originalImage
            .cropped(withCropperState: state) {
            
            self.profileImageValue = image
            tableView.reloadRows(at: profileInfoCellIndexPath, with: .fade)
        }
    }
}

extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {
        self.view.endEditing(true)
    }
}

extension ProfileEditViewController: UITableViewDataSource {
    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return tableViewDataSource.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return tableViewDataSource[section].count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cellType = tableViewDataSource[indexPath.section][indexPath.row]
        
        switch cellType {
            case .profile:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ProfileCell.id,
                    for: indexPath
                )
                guard let user else { return cell }
                
                (cell as? ProfileCell)?.set(
                    user: user,
                    controllerType: .editProfile,
                    delegate: self,
                    cellPhoto: profileImageValue
                )
                
                profileInfoCellIndexPath.append(IndexPath(row: indexPath.row, section: indexPath.section))
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ProfileEditCell.id,
                    for: indexPath
                )
                guard let user else { return cell}
                (cell as? ProfileEditCell)?.set(
                    user: user,
                    type: cellType,
                    delegate: self
                )
                return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        switch section {
            case 1:
                let footerView = ProfileEditHeaderView(
                    labelText: "Укажите имя и, если хотите добавьте фотографию для Вашего профиля."
                )
                return footerView
            case 2:
                let footerView = ProfileEditHeaderView(
                    labelText: "Можете изменить номер телефона."
                )
                return footerView
            default:
                return UIView()
        }
    }
}


extension ProfileEditViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didDeselectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProfileEditViewController: ChangeProfilePhotoDelegate {
    func changePhoto() {
        chageProfileButtonDidTap()
    }
}

extension ProfileEditViewController: ChangeProfileSaveOrDismissChangesDelegate {
    func saveChanges(user: FirebaseUser) {
        self.user = user
        saveChangedInfo {
            if let photo = self.profileImageValue {
                self.updateImageBlock?(photo)
                self.dismiss(animated: true)
            }
        }
    }
    
    func dismissChanges() {
        dismiss(animated: true)
    }
}
