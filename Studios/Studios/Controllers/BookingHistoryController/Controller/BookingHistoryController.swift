//
//  BookingHistoryController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 29.12.22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

class BookingHistoryController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var user = Auth.auth().currentUser
    private var bookingArray: [FirebaseBookingModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBookings()
        registerCell()
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBookings()
        tableView.reloadData()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: BookingCell.id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BookingCell.id)
    }
    
    private func getBookings() {
        guard let user else { return }
        self.spinner.startAnimating()
        FirebaseProvider().getBookings(referenceType: .getBookingForUserRef(userID: user.uid)) { booking in
            self.bookingArray = booking
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }
}

extension BookingHistoryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookingCell.id, for: indexPath)
        (cell as? BookingCell)?.set(booking: bookingArray[indexPath.row])
        return cell
    }
}
