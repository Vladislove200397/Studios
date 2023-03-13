//
//  FullSizeCalendar.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 10.03.23.
//

import UIKit

class FullSizeCalendar: UIView {
    private var color: UIColor
    lazy var calendarCollectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    required init(color: UIColor) {
        self.color = color
        super .init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
