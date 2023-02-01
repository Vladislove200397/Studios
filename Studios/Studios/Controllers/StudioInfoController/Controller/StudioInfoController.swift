//
//  StudioInfoController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 14.11.22.
//

import UIKit
import GooglePlaces
import Cosmos
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class StudioInfoController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratinView: CosmosView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var controllerView: UIView!
    @IBOutlet weak var openStatusLabel: UILabel!
    @IBOutlet weak var openHoursLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var studio: GMSPlace?
    private var controllers = [UIViewController]()
    private var selctedIndex = 0
    private var reviews: ReviewModel?
    private var user = Auth.auth().currentUser
    
    var likeFromFIR = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratinView.settings.fillMode = .precise
        ratinView.settings.updateOnTouch = false
        collectionView.dataSource = self
        sheetPresent()
        registerCell()
        setupData()
        configureControllers()
        insertController()
        setUpViews()
        setupLikeButton()
    }
    
    deinit {
        print("DEINIT")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    
    private func registerCell() {
        let photoNib = UINib(nibName: PhotoCell.id, bundle: nil)
        collectionView.register(photoNib, forCellWithReuseIdentifier: PhotoCell.id)
    }
    
    private func configureControllers() {
        let infoVcNib = String(describing: InfoViewController.self)
        let infoVc = InfoViewController(nibName: infoVcNib, bundle: nil)
        infoVc.setVc(studio: studio!)
        controllers.append(infoVc)
        
        let reviewVCNib = String(describing: ReviewTableController.self)
        let reviewVC = ReviewTableController(nibName: reviewVCNib, bundle: nil)
        
        reviewVC.set(placeID: (studio?.placeID)!)
        controllers.append(reviewVC)
    }
    
    private func insertController() {
        let controller = controllers[selctedIndex]
        self.addChild(controller)
        controller.view.frame = self.controllerView.bounds
        self.controllerView.addSubview(controller.view)
        self.didMove(toParent: controller)
    }
    
    private func sheetPresent() {
        let mediumHieghtDetent = (self.collectionView.frame.height / 2)+self.segmentedControl.frame.height+self.controllerView.frame.height
        let smallHeightDetent = self.contentView.frame.height-15
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.prefersGrabberVisible = true
            presentationController.largestUndimmedDetentIdentifier = .medium
            presentationController.selectedDetentIdentifier = .medium
            presentationController.accessibilityElementsHidden = true
            presentationController.prefersEdgeAttachedInCompactHeight = false
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            presentationController.detents = [
                .custom(identifier: .medium, resolver: { context in
                    mediumHieghtDetent
                }),
                .custom(resolver: { context in
                    smallHeightDetent
                }),
                .large(),
            ]}
    }
    
    func set(studio: GMSPlace?) {
        guard let studio else { return }
        self.studio = studio
    }
    
    private func setupData() {
        guard let name = studio?.name,
              let address = studio?.formattedAddress,
              let rating = studio?.rating,
              let totalUserRating = studio?.userRatingsTotal
        else { return }
        
        nameLabel.text = name
        addressLabel.text = address
        ratingLabel.text = "\(rating)"
        ratinView.rating = Double(rating)
        typeLabel.text = "(\(totalUserRating))"
        studioIsOpen(studio: studio)
    }
    
    private func setUpViews() {
        self.contentView.dropShadow(color: .gray, offSet: CGSize(width: -1, height: 1))
    }
    
    private func studioIsOpen(studio: GMSPlace?) {
        guard let studio else { return }
        
        let isOpen = studio.isOpen(at: Date.now)
        guard let openingHoursArr = studio.openingHours?.periods else { return }
        let calendarDay = Calendar.current.dateComponents( [.weekday], from: Date.now)
        var closeHour: UInt?
        var closeMinute: UInt?
        var openHour: UInt?
        var openMinute: UInt?
        
        openingHoursArr.enumerated().forEach { (index, value) in
            if index+1 == calendarDay.weekday {
                closeHour = value.closeEvent?.time.hour
                closeMinute = value.closeEvent?.time.minute
                openHour = value.openEvent.time.hour
                openMinute = value.openEvent.time.minute
            }
        }
        
        guard let closeHour,
              let closeMinute,
              let openHour,
              let openMinute else { return }
        
        switch isOpen {
            case .unknown:
                openStatusLabel.text = "Неизвестно"
            case .open:
                openStatusLabel.text = "Открыто"
                openHoursLabel.text = " • Закроется в \(closeHour):0\(closeMinute)"
                openStatusLabel.textColor = UIColor(hue: 0.38, saturation: 0.72, brightness: 0.72, alpha: 1.0) // #34b859
            case .closed:
                openStatusLabel.text = "Закрыто"
                openHoursLabel.text = " • Откроется в \(openHour):0\(openMinute)"
                openStatusLabel.textColor = UIColor(hue: 0.01, saturation: 0.64, brightness: 0.75, alpha: 1.0) // #bf4f45
            default:
                break
        }
    }
    private func setupLikeButton() {
        let heartFill = UIImage(systemName: "heart.fill")
        let heart = UIImage(systemName: "heart")!
        
        self.likeButton.setImage( likeFromFIR ? heartFill : heart .withRenderingMode(.alwaysTemplate), for: .normal)
        self.likeButton.tintColor = .red
    }
    
    private func getLike() {
        guard let studioID = studio?.placeID,
              let userID = user?.uid else { return }
        FirebaseProvider().getLike(referenceType: .getLike(userID: userID, studioID: studioID)) { like in
            self.likeFromFIR = like
            self.setupLikeButton()
        }
    }
    
    //    private func postLike(referenceType: FirebaseReferenses) {
    //        let ref = referenceType.references
    //        let sendLike = ["like": likeFromFIR ? false : true ] as [String : Any]
    //        ref.setValue(sendLike)
    //
    //    }
    
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
        guard sender.selectedSegmentIndex < 2 else { return }
        self.selctedIndex = sender.selectedSegmentIndex
        insertController()
    }
    
    @IBAction func bookingButtonDidTap(_ sender: Any) {
        guard let studio else { return }
        let bookingVC =  BookingStudioController(nibName: String(describing: BookingStudioController.self), bundle: nil)
        let nav = UINavigationController(rootViewController:    bookingVC)
        
        bookingVC.setData(studio: studio)
        present(nav, animated: true)
    }
    
    @IBAction func likeButtonDidTap(_ sender: Any) {
        guard let studio = studio,
              let studioID = studio.placeID,
              let userID =  user?.uid else { return }
        FirebaseProvider().setLikeValue(self.likeFromFIR, referenceType: .getLike(userID: userID, studioID: studioID)) {
            self.getLike()
        }
        if likeFromFIR {
            FirebaseProvider().removeStudioFromLiked(referenceType: .removeLikedStudio(userID: userID, studioID: studioID)) {
                print("Удалено")
            }

        } else {
            FirebaseProvider().postLikedStudio(studio: studio, referenceType: .postLike(userID: userID, studioID: studioID)) {
                print("успешно")
            }
        }
    }
}


extension StudioInfoController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (studio?.photos!.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath)
        guard let photoCell = cell as? PhotoCell else { return cell }

        photoCell.set(indexPath.row, studio)
        return photoCell
    }
}
