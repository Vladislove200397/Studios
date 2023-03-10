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
import SnapKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileHeaderLabel: UILabel!
    @IBOutlet weak var navView: UIView!
    
    private var user: FirebaseUser?
    private var tableViewDataSource: [[TableViewCellTypes]] = []
    private var profileCellNameLabel = UILabel()
    private var profileCellImageView = UIImageView()
    private var profileCellPhoneNumberLabel = UILabel()
    private var didChangeTitle = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupUser()
        registerCell()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setBackgroundGradient()
    }
    
    private func setupVC() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupTableViewSections()
        navView.alpha = 0
        navView.addBlurredBackground(style: .dark, alpha: 0.7, blurColor: .black.withAlphaComponent(0.7))
        navView.bringSubviewToFront(profileHeaderLabel)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setBackgroundGradient() {
        let topColor = UIColor(hue: 0.71, saturation: 0.72, brightness: 0.25, alpha: 1.0).cgColor
        self.view.setGradientBackground(topColor: topColor, bottomColor: UIColor.black.cgColor)
    }
    
    private func registerCell() {
        let profileCellNib = UINib(nibName: ProfileCell.id, bundle: nil)
        let defaultProfileCellNib = UINib(nibName: DefaultProfileCell.id, bundle: nil)
        
        tableView.register(profileCellNib, forCellReuseIdentifier: ProfileCell.id)
        tableView.register(defaultProfileCellNib, forCellReuseIdentifier: DefaultProfileCell.id)
    }

    private func setupUser() {
        getUserInfo()
    }
    
    private func setupTableViewSections() {
        var section: [[TableViewCellTypes]] = [[.profile]]
        let profileSettingSection: [TableViewCellTypes] = [.profileSettings]
        let historySection: [TableViewCellTypes] = [.photography, .bookingHistory]
        let accountExtSection: [TableViewCellTypes] = [.exit]
        let sendEmailToDevSection: [TableViewCellTypes] = [.sendEmailToDev]
        section.append(profileSettingSection)
        section.append(historySection)
        section.append(accountExtSection)
        section.append(sendEmailToDevSection)
        tableViewDataSource = section
    }
    
    private func getUserInfo() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        spinner.startAnimating()
        FirebaseProvider().getUserInfo(referenceType: .getUserInfo(userID: userID), userID) {[weak self] user in
            guard let self else { return }
            self.user = user
            self.setupUser()
            self.spinner.stopAnimating()
            self.tableView.reloadData()
        } failure: {
            
        }
    }
    
    private func presentPopupForLogoutAction() {
        let popupConfigure = PopUpConfiguration(
            confirmButtonTitle: "Отмена",
            dismissButtonTitle: "Ок",
            title: "Выход",
            description: "Выйти из аккаунта?",
            image: UIImage(systemName: "exclamationmark.circle"),
            style: .confirmation,
            imageTintColor: .systemYellow,
            dismissButtonTintColor: .red
        )
        
        PopUpController.show(on: self, configure: popupConfigure, discard:  {
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
    
    private func showAndHideNavView(_ didChangeTitle: Bool) {
        self.profileHeaderLabel.text = self.profileCellNameLabel.text
        self.profileCellNameLabel.alpha = didChangeTitle ? 0 : 1
        UIView.animate(withDuration: 0.05) {[weak self] in
            guard let self else { return }
            self.navView.alpha = didChangeTitle ? 1 : 0
        }
    }
    
    private func showAndHideNavViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y - profileCellNameLabel.frame.origin.y) + (scrollView.contentOffset.y + profileCellNameLabel.frame.height) / 2) >= profileHeaderLabel.frame.minY && !didChangeTitle {
            didChangeTitle = true
            showAndHideNavView(didChangeTitle)
            
        } else if ((scrollView.contentOffset.y - profileCellNameLabel.frame.origin.y) + (scrollView.contentOffset.y + profileCellNameLabel.frame.height) / 2) < profileHeaderLabel.frame.minY  && didChangeTitle {
            didChangeTitle = false
            showAndHideNavView(didChangeTitle)
        }

    }
    
    private func upperProfileLabelFont(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        let profileNameLabelScale = min(2.0, max(1.0 - offset / -500.0, 1.0))
        let profileViewsLabelScale = min(max(1.0 - offset / 400.0, 0.0), 1.0)
        let profileViewsAlphaScale = min(max(1.0 - offset / 120.0, 0.0), 1.0)
        
        profileCellNameLabel.transform = CGAffineTransform(scaleX: profileNameLabelScale, y: profileNameLabelScale)
        profileCellPhoneNumberLabel.transform = CGAffineTransform(scaleX: profileViewsLabelScale, y: profileViewsLabelScale)
        profileCellImageView.transform = CGAffineTransform(scaleX: profileViewsLabelScale, y: profileViewsLabelScale)
        profileCellImageView.alpha = profileViewsAlphaScale
        profileCellPhoneNumberLabel.alpha = profileViewsAlphaScale
    }
    
    private func presentProfileEditController(_ type: TableViewCellTypes) {
        guard let vc = type.controllers as? ProfileEditViewController,
              let user,
              let image = profileCellImageView.image else { return }
        vc.set(user, profileImage: image)
        vc.updateBlock = { profileImage in
            self.profileCellImageView.image = profileImage
            self.setupUser()
        }
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewDataSource[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellType = tableViewDataSource[indexPath.section][indexPath.row]
        switch cellType {
            case .profile:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.id, for: indexPath)
               guard let profileCell = cell as? ProfileCell,
                     let user else { return cell}
                profileCell.set(
                    user: user,
                    controllerType: .profile
                )
                profileCellNameLabel = profileCell.profileNameLabel
                profileCellPhoneNumberLabel = profileCell.profilePhoneNumberLabel
                profileCellImageView = profileCell.profileImageView
              
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: DefaultProfileCell.id, for: indexPath)
                (cell as? DefaultProfileCell)?.set(type: cellType)
                
                return cell
        }
    }
}


extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = tableViewDataSource[indexPath.section][indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        

        switch type {
            case .profileSettings:
                presentProfileEditController(type)
            case .exit:
                presentPopupForLogoutAction()
            default:
                return
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        upperProfileLabelFont(scrollView)
        showAndHideNavViewDidScroll(scrollView)
    }
}
