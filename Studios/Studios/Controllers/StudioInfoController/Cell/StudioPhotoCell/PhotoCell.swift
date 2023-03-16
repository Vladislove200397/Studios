//
//  PhotoCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 21.11.22.
//

import UIKit
import GooglePlaces

final class PhotoCell: UICollectionViewCell {
    static let id = String(describing: PhotoCell.self)
    
    @IBOutlet weak var studioImage: UIImageView!

    private var studio: GMSPlace?
    private var indexPath = Int()
    private var photo: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.studioImage.image = photo
    }

    func set(_ indexPath: Int, _ studio: GMSPlace?) {
        guard let studio else { return }
        self.studio = studio
        self.indexPath = indexPath
    }
}

