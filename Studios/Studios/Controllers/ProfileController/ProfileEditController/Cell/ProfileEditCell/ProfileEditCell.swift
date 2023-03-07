//
//  ProfileEditCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 1.03.23.
//

import UIKit

class ProfileEditCell: UITableViewCell {
    static let id = String(describing: ProfileEditCell.self)

    @IBOutlet weak var cellSaveOrDismisButton: UIButton!
    @IBOutlet weak var cellTextField: UITextField!
    
    
    private(set) var type: ProfileEditCellTypes = .editSurname
    private weak var delegate: ChangeProfileSaveOrDismissChangesDelegate?
    private(set) var user: FirebaseUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellTextField.addTarget(self, action: #selector(textFieldDidBeginEditing(textField:)), for: .allEvents)
    }
    
    private func setupTextField() {
        cellTextField.setLeftPaddingPoints(10)
        cellTextField.setRightPaddingPoints(10)
        cellTextField.textColor = .lightGray
        cellTextField.attributedPlaceholder = NSAttributedString(string: type.textFieldPlaceHolder , attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
    }

    func set(user: FirebaseUser, type: ProfileEditCellTypes, delegate: ChangeProfileSaveOrDismissChangesDelegate) {
        self.type = type
        self.delegate = delegate
        self.user = user
        setupCell()
        setupTextField()
    }
    
    private func setupCell() {
        cellTextField.backgroundColor = .clear
        switch type {
            case .editSurname:
                cellSaveOrDismisButton.isHidden = true
                cellTextField.text = user?.userSurname
            case .editName:
                cellSaveOrDismisButton.isHidden = true
                cellTextField.text = user?.userName
            case .editPhoneNumber:
                cellSaveOrDismisButton.isHidden = true
                cellTextField.text = user?.userPhone
            case .dismiss:
                cellTextField.isHidden = true
                cellSaveOrDismisButton.setTitle("Отмена", for: .normal)
                cellSaveOrDismisButton.setTitleColor(.red, for: .normal)
            case .saveChanges:
                cellTextField.isHidden = true
                cellSaveOrDismisButton.setTitle("Сохранить", for: .normal)
            default:
                return
        }
    
    }
    
    @objc func textFieldDidBeginEditing(textField: UITextField) {
        guard let text = textField.text else { return }
        switch type {
            case .editName:
                user?.userName = text
            case .editSurname:
                user?.userSurname = text
            case .editPhoneNumber:
                user?.userPhone = text
            default:
                return
        }
    }
    
    @IBAction func cellButtonDidTap(_ sender: UIButton) {
        guard let user else { return }
        
        switch type {
            case .saveChanges:
                delegate?.saveChanges(user: user)
            case .dismiss:
                delegate?.dismissChanges()
            default:
                return
        }
    }
}
