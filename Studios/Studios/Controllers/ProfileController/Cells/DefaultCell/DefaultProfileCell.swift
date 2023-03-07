//
//  DefaultProfileCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 26.02.23.
//

import UIKit

class DefaultProfileCell: UITableViewCell {
    static let id = String(describing: DefaultProfileCell.self)
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    private(set) public var type: TableViewCellTypes?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func set(type: TableViewCellTypes) {
        cellLabel.text = type.title
        cellImage.image = type.cellImage
    }
}
