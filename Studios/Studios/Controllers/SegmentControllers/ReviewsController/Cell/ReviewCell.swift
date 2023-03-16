//
//  ReviewCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 27.11.22.
//

import UIKit
import Cosmos

final class ReviewCell: UITableViewCell {
    static let id = String(describing: ReviewCell.self)
    @IBOutlet weak var cellTextLabel: UILabel!
    
    @IBOutlet weak var cellReviewRating: CosmosView!
    @IBOutlet weak var cellAuthorNameLabel: UILabel!
    @IBOutlet weak var cellReviewDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(reviewModel: StudioReviewModel?) {
        cellReviewRating.settings.updateOnTouch = false
        cellReviewRating.settings.fillMode = .precise
        
        setupCell(reviewModel: reviewModel)
    }
    
    private func setupCell(reviewModel: StudioReviewModel?) {
        guard let reviewModel else { return }
        cellTextLabel.text = reviewModel.text
        cellAuthorNameLabel.text = reviewModel.authorName
        cellReviewRating.rating = reviewModel.rating
        
        let date = Date(timeIntervalSince1970: reviewModel.time)
        let format = DateFormatter()
        format.dateFormat = "d MMMM YYYY"
        format.locale = Locale(identifier: "ru_RU")
        let reviewDate = format.string(from: date)
        
        cellReviewDateLabel.text = reviewDate
    }
}
