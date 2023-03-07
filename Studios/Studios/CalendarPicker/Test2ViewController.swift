//
//  Test2ViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 7.03.23.
//

import UIKit

class Test2ViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    
    var date = Date()
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func presentCalendar(_ sender: Any) {
        let calendarPicker = CalendarPickerViewController(baseDate: date) {[weak self] date in
            guard let self = self else { return }
            self.date = date
            self.dateLabel.text = self.date.formatted()
        }
        
        present(calendarPicker, animated: true, completion: nil)
    }
}
