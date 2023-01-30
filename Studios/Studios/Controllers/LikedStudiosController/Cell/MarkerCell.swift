//
//  MarkerCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 9.11.22.
//

import UIKit
import GooglePlaces
class MarkerCell: UITableViewCell {
    static let id = String(describing: MarkerCell.self)
    

    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(studio: GMSPlace) {
        guard let name = studio.name,
              let address = studio.formattedAddress
        else { return }
        nameLabel.text = name
        addressLabel.text = address
        
    }
}
