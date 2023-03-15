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
import SnapKit

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
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var controllerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var studio: GMSPlace?
    private var controllers = [UIViewController]()
    private var selctedIndex = 0
    private var reviews: ReviewModel?
    private var user = Auth.auth().currentUser
    private var likeBlock: VoidBlock?
    private var photoArr: [UIImage] = []
    
    
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
        setupLikeButton()
        loadImages()
//        fetchOpenStatus(studio: studio)
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
       print(self.scrollContainerView.frame.height)
        print(self.controllerView.frame.height)
        print(self.collectionView.frame.height)
        infoVc.setVc(studio: studio!) {
//
//            let scrollViewHeght = self.scrollContainerView.frame.height + infoVc.flexibleView.containerView.frame.height
//            let height = self.controllerView.frame.height + infoVc.flexibleView.containerView.frame.height
////
//            self.controllerView.snp.remakeConstraints { make in
//                make.height.greaterThanOrEqualTo(height).priority(.medium)
//            }
//
//            self.scrollContainerView.snp.remakeConstraints { make in
//                make.height.greaterThanOrEqualTo(self.scrollView.frameLayoutGuide.layoutFrame.height).offset(scrollViewHeght).priority(.)
//            }
//
//            self.collectionView.snp.updateConstraints { make in
//                make.height.equalTo(265)
//            }
//
//            self.view.layoutIfNeeded()
//            print(self.scrollContainerView.frame.height)
//             print(self.controllerView.frame.height)
//             print(self.collectionView.frame.height)
        }
                     
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
        let smallHeightDetent = self.contentView.frame.height - 15
        
        if let presentationController = presentationController as? UISheetPresentationController {
           
            presentationController.delegate = self
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
    
    func set(studio: GMSPlace?, likeFromFir: Bool, updateBlock: VoidBlock? = nil) {
        guard let studio else { return }
        self.studio = studio
        self.likeFromFIR = likeFromFir
        self.likeBlock = updateBlock
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
        fetchOpenStatus(studio: studio)
    }
    
    private func setUpViews() {
        self.contentView.dropShadow(color: .gray, offSet: CGSize(width: -1, height: 1))
    }
    
    private func fetchOpenStatus(studio: GMSPlace?) {
        guard let studio,
              let openingHours = studio.openingHours,
              let _ = studio.utcOffsetMinutes,
              let numberOfDay = Calendar.current.ordinality(of: .weekday, in: .weekOfYear, for: .now),
              let weekdayText = openingHours.weekdayText else { return }
        
        let weekdayTextString: String = weekdayText[numberOfDay-1]
        let numbers = weekdayTextString.components(separatedBy: ["–", " "])
        let isOpenNow = studio.isOpen()
//        let futureTime = Date.now
//        let isOpenAtTime = studio.isOpen(at: futureTime)
        
        switch isOpenNow {
            case .unknown:
                openStatusLabel.text = "Неизвестно"
            case .open:
                let openColor = UIColor(hue: 0.38, saturation: 0.72, brightness: 0.72, alpha: 1.0)
                let string = "Открыто • Закроется в \(numbers[2])"
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
                attributedString.setColor(color: openColor, forText: "Открыто")
                openStatusLabel.attributedText = attributedString
                
            case .closed:
                let closedColor = UIColor(hue: 0.01, saturation: 0.64, brightness: 0.75, alpha: 1.0)
                let string = "Закрыто • Откроется в \(numbers[2])"
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
                attributedString.setColor(color: closedColor, forText: "Закрыто")
                openStatusLabel.attributedText = attributedString

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
    
    private func loadImages() {
        let placesClient = GMSPlacesClient()
        guard let photosMetadata = studio?.photos else { return }
        
        photosMetadata.forEach { photoMetadata in
            placesClient.loadPlacePhoto(photoMetadata) { photo, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    self.photoArr.append(photo!)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    


    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
        guard sender.selectedSegmentIndex < 2 else { return }
        self.selctedIndex = sender.selectedSegmentIndex
        insertController()
    }
    
    @IBAction func bookingButtonDidTap(_ sender: Any) {
        guard let studio else { return }
        let bookingVC =  BookingStudioController(nibName: String(describing: BookingStudioController.self), bundle: nil)
        let nav = UINavigationController(rootViewController:    bookingVC)
        
        bookingVC.setData(studio: studio, controllerType: .booking)
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
            self.likeBlock?()
        } else {
            FirebaseProvider().postLikedStudio(studio: studio, referenceType: .postLike(userID: userID, studioID: studioID)) {
                print("успешно")
            }
            self.likeBlock?()
        }
    }
}

extension StudioInfoController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
//        guard let photos = studio?.photos?.count else { return 0}
        return photoArr.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath)
        guard let photoCell = cell as? PhotoCell else { return cell }
        photoCell.set(indexPath.row, studio)
        photoCell.stdioImage.image = photoArr[indexPath.row]
        return photoCell
    }
}

extension NSMutableAttributedString {
    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}

extension StudioInfoController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        if sheetPresentationController.selectedDetentIdentifier != .medium, sheetPresentationController.selectedDetentIdentifier != .large {
            segmentedControl.isHidden = true
        } else {
            segmentedControl.isHidden = false
        }
    }
}
