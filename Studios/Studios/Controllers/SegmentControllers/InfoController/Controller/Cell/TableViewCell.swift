//
//  TableViewCell.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 13.03.23.
//

import UIKit

class TableViewCell: UITableViewCell {
    static let id = String(describing: TableViewCell.self)
    
    @IBOutlet weak var flexView: FlexView!
    weak var flexDelegate: FlexibleViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        flexView.set(delegate: flexDelegate, type: .date)
    }
    
}
