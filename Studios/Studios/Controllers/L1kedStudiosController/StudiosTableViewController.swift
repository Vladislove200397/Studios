//
//  MarkerDataTableController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 9.11.22.
//

import UIKit

import GooglePlaces


class StudiosTableViewController: UIViewController {

    var places = RealmManager<SSPlace>().read()
    var studios = [GMSPlace]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
        studios = Service.shared.studios
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(studios.count)
        tableView.reloadData()
    }
    
    
    private func registerCell() {
        let markerCellNib = UINib(nibName: String(describing: MarkerCell.id), bundle: nil)
        tableView.register(markerCellNib, forCellReuseIdentifier: String(describing: MarkerCell.id))
    }
}

extension StudiosTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MarkerCell.id, for: indexPath)
        guard let markerCell = cell as? MarkerCell else { return cell }
        markerCell.set(studio: studios[indexPath.row])
        return markerCell
    }
}

extension StudiosTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

