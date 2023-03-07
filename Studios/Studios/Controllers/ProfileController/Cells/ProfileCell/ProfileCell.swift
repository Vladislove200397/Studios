//
//  ProfileCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 26.02.23.
//

import UIKit

class ProfileCell: UITableViewCell {
    static let id = String(describing: ProfileCell.self)
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePhoneNumberLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var changePhotoButton: UIButton!
    

    private weak var changePhotoDelegate: ChangeProfilePhotoDelegate?
    private(set) var controllerType: ProfileControllerType = .profile
    private var profileImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        changePhotoButton.isHidden = true
        
    }

    func set(user: FirebaseUser, controllerType: ProfileControllerType, delegate: ChangeProfilePhotoDelegate? = nil, cellPhoto: UIImage? = nil) {
        profileNameLabel.text = "\(user.userName) \(user.userSurname)"
        profilePhoneNumberLabel.text = user.userPhone
        self.controllerType = controllerType
        self.changePhotoDelegate = delegate
        self.profileImageView.image = cellPhoto
        self.profileImage = cellPhoto
        setProfileImage()
        setupCell()
    }
    
    private func setupCell() {
        switch controllerType {
            case .profile:
                changePhotoButton.isHidden = true
            case .editProfile:
                changePhotoButton.isHidden = false
                profileNameLabel.isHidden = true
                profilePhoneNumberLabel.isHidden = true
        }
    }
    
    private func setProfileImage() {
        switch controllerType {
            case .profile:
                FirebaseProvider().downloadData { image in
                    self.profileImageView.image = image
                }
            case .editProfile:
                self.profileImageView.image = profileImage
        }
    }
    
    @IBAction func changePhotoButtonDidTap(_ sender: Any) {
        changePhotoDelegate?.changePhoto()
    }
}
