//
//  ProfileEditHeaderView.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 1.03.23.
//

import UIKit
import SnapKit

final class ProfileEditHeaderView: UITableViewHeaderFooterView {
    private let id = String(describing: ProfileEditHeaderView.self)
    
    private var labelText: String?
    
    private lazy var headerFooterLabel: UILabel = {
        let label = UILabel()
        label.text = labelText
        label.font = .systemFont(ofSize: 11, weight: .thin)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .lightGray
        return label
    }()
    
    init(labelText: String){
        self.labelText = labelText
        super.init(reuseIdentifier: id)
        setupLayout()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.contentView.addSubview(headerFooterLabel)
    }
    
    private func makeConstraints() {
        let labelInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        headerFooterLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(labelInset)
        }
    }
}
