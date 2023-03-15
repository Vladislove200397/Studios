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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navViewLabel: UILabel!
    @IBOutlet weak var emptyLikedStudioArrView: UIView!
    @IBOutlet weak var emptyLikedStudioArrLabel: UILabel!
    
    
    private var didChangeTitle = false
    private var user = Auth.auth().currentUser
    private var likedStudios: [FirebaseLikedStudioModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLikedStudios()
        registerCell()
        setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLikedStudios()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setBackgroundGradient()
    }
    
    private func setBackgroundGradient() {
        let topColor = UIColor(hue: 0.94, saturation: 0.77, brightness: 0.25, alpha: 1.0).cgColor // #851f42
        self.view.setGradientBackground(topColor: topColor, bottomColor: UIColor.black.cgColor)
    }
    
    private func setupVC() {
        collectionView.dataSource = self
        collectionView.delegate = self
        emptyLikedStudioArrView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func registerCell() {
        let nib = UINib(nibName: LikedStudioCell.id, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: LikedStudioCell.id)
    }
    
    private func getLikedStudios() {
        spinner.startAnimating()
        FirebaseProvider().getLikedStudios(referenceType: .getLikedStudios(userID: user!.uid)) {[weak self] likedStudios in
            guard let self else { return }
            self.likedStudios = likedStudios
            self.collectionView.reloadData()
            self.spinner.stopAnimating()
            self.showEmptyArrayView()
        }
    }
    
    private func getLike(studioID: String, succed: @escaping (Bool) -> Void) {
        guard let userID = user?.uid else { return }
        FirebaseProvider().getLike(referenceType: .getLike(userID: userID, studioID: studioID)) { like in
            succed(like)
        }
    }
    
    private func showAndHideBlurOnNavView() {
        if !didChangeTitle {
            navView.addBlurredBackground(style: .dark, alpha: 0.7, blurColor: .black.withAlphaComponent(0.7))
            navView.bringSubviewToFront(navViewLabel)
        } else if didChangeTitle {
            navView.subviews.forEach { view in
                if view != navViewLabel {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    private func showEmptyArrayView() {        
        if likedStudios.isEmpty {
            collectionView.isHidden = true
            emptyLikedStudioArrView.isHidden = false
            emptyLikedStudioArrLabel.text = "Нет избранных студий"
        } else {
            collectionView.isHidden = false
            emptyLikedStudioArrView.isHidden = true
        }
    }
    
    private func presentLikedStudioDidTapOnCell(indexPath: IndexPath) {
        let selectedStudio = likedStudios[indexPath.row]
        guard let studio = Service.shared.studios.first(where: {$0.placeID == selectedStudio.studioID}),
              let studioID = selectedStudio.studioID else { return }
        
        getLike(studioID: studioID) {[weak self] like in
            guard let self else { return }
            
            let studioInfoVC = StudioInfoController(nibName: String(describing: StudioInfoController.self), bundle: nil)
            
            self.dismiss(animated: true)
            
            studioInfoVC.set(
                studio: studio,
                likeFromFir: like
            ) {
                self.dismiss(animated: true) {
                    self.collectionView.performBatchUpdates {
                        self.likedStudios.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                    } completion: { _ in
                        self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                    }
                }
            }
            self.present(studioInfoVC, animated: true)
        }
    }
}

extension LikedStudiosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        likedStudios.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikedStudioCell.id, for: indexPath)
        guard let likedStudioCell = cell as? LikedStudioCell else { return cell}
        likedStudioCell.set(likedStudio: likedStudios[indexPath.row])

        
        return likedStudioCell
    }
}

extension LikedStudiosViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= (navView.frame.origin.y - navViewLabel.frame.height) && !didChangeTitle {
            showAndHideBlurOnNavView()
            didChangeTitle = true
        } else if scrollView.contentOffset.y < (navView.frame.origin.y - navViewLabel.frame.height) && didChangeTitle {
            showAndHideBlurOnNavView()
            didChangeTitle = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = 20.0
        let width = collectionView.frame.width - inset
        return CGSize(width: width, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        presentLikedStudioDidTapOnCell(indexPath: indexPath)
    }
}
