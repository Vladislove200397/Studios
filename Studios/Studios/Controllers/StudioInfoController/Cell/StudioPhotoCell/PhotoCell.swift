//
//  PhotoCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 21.11.22.
//

import UIKit
import GooglePlaces

class PhotoCell: UICollectionViewCell {
    static let id = String(describing: PhotoCell.self)
    
    @IBOutlet weak var stdioImage: UIImageView!

    private var studio: GMSPlace?
    private var indexPath = Int()
    private var photo: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.stdioImage.image = photo
    }

    func set(_ indexPath: Int, _ studio: GMSPlace?) {
        guard let studio else { return }
        self.studio = studio
        self.indexPath = indexPath
        //getPhoto(studio: studio)
    }
    
    private func getPhoto(studio: GMSPlace) {
        let placesClient = GMSPlacesClient()
        
        let photoMetadata = studio.photos![self.indexPath]
        // Call loadPlacePhoto to display the bitmap and attribution.
        placesClient.loadPlacePhoto(photoMetadata) { photo, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                self.photo = photo
                self.stdioImage.image = photo
            }
        }
    }
}

