//
//  LikedStudiosViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.01.23.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class LikedStudiosViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var user = Auth.auth().currentUser
    private var likedStudios: [FirebaseLikedStudioModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        getLikedStudios()
        registerCell()
        setupController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupController() {
        self.title = "Избранное"
    }
    
    private func registerCell() {
        let nib = UINib(nibName: LikedStudioCell.id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: LikedStudioCell.id)
    }
    private func getLikedStudios() {
        spinner.startAnimating()
        FirebaseProvider().getLikedStudios(referenceType: .getLikedStudios(userID: user!.uid)) { likedStudios in
            self.likedStudios = likedStudios
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }
}

extension LikedStudiosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        likedStudios.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LikedStudioCell.id, for: indexPath)
        (cell as? LikedStudioCell)?.set(likedStudio: likedStudios[indexPath.row], delegate: self)
        
        return cell
    }
}

extension LikedStudiosViewController: PushButtonDelegate {
    func pushButton(studioID: String) {
        var allStudios = Service.shared.studios
        let studio = allStudios.first(where: {$0.placeID == studioID})
        let studioInfoVC = StudioInfoController(nibName: String(describing: StudioInfoController.self), bundle: nil)

        studioInfoVC.set(studio: studio)
        present(studioInfoVC, animated: true)
    }
}