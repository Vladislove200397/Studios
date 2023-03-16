//
//  PrivacyPhotographyViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 10.03.23.
//

import UIKit

//НЕ Сделан

final class PrivacyPhotographyViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var cellCalendar: UIDatePicker?
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
        let headerView = CalendarHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: self.view.bounds.width,
                height: 285
            )
        )
        
        self.tableView.tableHeaderView = headerView
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: PrivacyPhotographyCalendarCell.id, bundle: nil), forCellReuseIdentifier: PrivacyPhotographyCalendarCell.id)
    }

}

extension PrivacyPhotographyViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PrivacyPhotographyCalendarCell.id,
            for: indexPath
        ) as? PrivacyPhotographyCalendarCell else {
            return UITableViewCell()
        }
        
        cellCalendar = cell.calendarDatePicker
        return cell
    }
}

extension PrivacyPhotographyViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let headerView = self.tableView.tableHeaderView as! CalendarHeaderView
            headerView.scrollViewDidScroll(scrollView: scrollView)
        }
}
