//
//  LikedStudioCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.01.23.
//

import UIKit

class LikedStudioCell: UITableViewCell {
    static let id = String(describing: LikedStudioCell.self)
    
    @IBOutlet weak var cellStudioNameLabel: UILabel!
    @IBOutlet weak var cellStudioRatingLabel: UILabel!
    
    private var likedStudio: FirebaseLikedStudioModel?
    weak var buttonDelegate: PushButtonDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func set(likedStudio: FirebaseLikedStudioModel, delegate: PushButtonDelegate) {
        self.likedStudio = likedStudio
        self.buttonDelegate = delegate
        setupCell()
    }
    
    private func setupCell() {
        if let likedStudio = likedStudio {
            let rating = String(format: "%.01f", likedStudio.studioRating)
            cellStudioNameLabel.text = likedStudio.studioName
            cellStudioRatingLabel.text = rating
        }
    }
    
    @IBAction func aboutButtonDidTap(_ sender: Any) {
        if let likedStudio {
            buttonDelegate?.pushButton(studioID: likedStudio.studioID)
        }
    }
}
