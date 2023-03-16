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
    private var startDayTimeStamp: Int? {
        didSet {
            
        }
    }
    private var hoursArray = Array(0...23)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStartDayTimeStamp()
        
        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
        let headerView = CalendarHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: self.view.bounds.width,
                height: 300
            )) { startDayTimeStampBlock in
                self.startDayTimeStamp = startDayTimeStampBlock
            }
        
        self.tableView.tableHeaderView = headerView
    }
    
    override func viewWillLayoutSubviews() {
        setBackgroundGradient()
    }
    
    private func setBackgroundGradient() {
        let topColor = UIColor(
            hue: 0.8,
            saturation: 0.65,
            brightness: 0.29,
            alpha: 1.0).cgColor // #401a4a
        self.view.setGradientBackground(
            topColor: topColor,
            bottomColor: UIColor.black.cgColor
        )
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: PrivacyPhotographyCalendarCell.id, bundle: nil), forCellReuseIdentifier: PrivacyPhotographyCalendarCell.id)
    }
    
    private func getStartDayTimeStamp() {
        let date = Date.now
        let todayStartOfDay = Calendar.current.startOfDay(for: date)
        let timeOfStartDay = Int(todayStartOfDay.timeIntervalSince1970)
        self.startDayTimeStamp = timeOfStartDay
    }

}

extension PrivacyPhotographyViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        hoursArray.count
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
        
        cell.timeLabel.text = "\(hoursArray[indexPath.row]):00"
        return cell
    }
}

extension PrivacyPhotographyViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let headerView = self.tableView.tableHeaderView as! CalendarHeaderView
            headerView.scrollViewDidScroll(scrollView: scrollView)
        }
}
