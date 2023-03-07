//
//  LikedStudioCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 3.03.23.
//

import UIKit
import Cosmos

class LikedStudioCell: UICollectionViewCell {
    static let id = String(describing: LikedStudioCell.self)
    
    @IBOutlet weak var cellStudioNameLabel: UILabel!
    @IBOutlet weak var cellStudioRatingLabel: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var containerView: UIView!
    
    private let cellColor = UIColor(hue: 1, saturation: 0.69, brightness: 0.63, alpha: 1.0)
    private var likedStudio: FirebaseLikedStudioModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setContainerViewGradient()
    }
    

    func set(likedStudio: FirebaseLikedStudioModel) {
        self.likedStudio = likedStudio
        setupCell()
    }
    
    private func setContainerViewGradient() {
        contentView.clipsToBounds = true
        contentView.backgroundColor = cellColor
        contentView.layer.cornerRadius = 10
    }
    
    private func setupCell() {
        guard let likedStudio else { return }
        let rating = String(format: "%.01f", likedStudio.studioRating)
        cellStudioNameLabel.text = likedStudio.studioName
        cellStudioRatingLabel.text = rating
        setupRatingStarView()
        self.addShadow(corner: 10, color: cellColor, radius: 15, offset: CGSize(width: 0, height: 5), opacity: 0.3)
    }
    
    private func setupRatingStarView() {
        guard let likedStudio else { return }
        starRatingView.rating = Double(likedStudio.studioRating)
        starRatingView.settings.fillMode = .precise
        starRatingView.settings.updateOnTouch = false

    }
}
