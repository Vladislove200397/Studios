//
//  ReviewTableController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 27.11.22.
//

import UIKit

final class ReviewTableController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var studioReview: ReviewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regiserCell()
        tableView.dataSource = self
        tableView.reloadData()
    }

    func set(placeID: String) {
        StudioReviewProvider.getReview(
            placeID: placeID
        ) { review in
            self.studioReview = review
        }
    }
    
    private func regiserCell() {
        let reviewNIB = UINib(nibName: ReviewCell.id, bundle: nil)
        tableView.register(reviewNIB, forCellReuseIdentifier: ReviewCell.id)
    }
}

extension ReviewTableController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let studioReview else { return 0}
        return studioReview.reviews.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.id, for: indexPath)
        guard let reviewCell = cell as? ReviewCell else { return cell }
        reviewCell.set(reviewModel: studioReview?.reviews[indexPath.row])
        return reviewCell
    }
}
