//
//  CalendarHeaderView.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.03.23.
//

import UIKit

final class CalendarHeaderView: UIView {
    private var containerView: UIView!
    private var datePicker: UIDatePicker!
    private var imageViewHeight = NSLayoutConstraint()
    private var imageViewBottom = NSLayoutConstraint()
    private var containerViewHeight = NSLayoutConstraint()
    private var timeStampBlock: IntBlock?
    
    init(frame: CGRect, timeStampBlock: IntBlock?) {
        self.timeStampBlock = timeStampBlock
        super.init(frame: frame)
        createViews()
        setViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        // Container View
        containerView = UIView()
        self.addSubview(containerView)
       
        datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(didChangeDate(sender: )), for: .valueChanged)
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.clipsToBounds = true
        datePicker.backgroundColor = .clear
        datePicker.contentMode = .scaleAspectFill
        addBackgroundView(datePicker: datePicker)
        containerView.addSubview(datePicker)
    }
    
    private func addBackgroundView(datePicker: UIDatePicker) {
        let backgroundView = UIView()
        backgroundView.addBlurredBackground(style: .dark, alpha: 0.2, blurColor: .black)
        backgroundView.layer.cornerRadius = 10
        datePicker.addSubview(backgroundView)
        datePicker.sendSubviewToBack(backgroundView)
        backgroundView.snp.makeConstraints { make in
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            make.top.bottom.left.right.equalToSuperview().inset(insets)
        }
    }
    
    func setViewConstraints() {
        // UIView Constraints
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        // Container View Constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalTo: datePicker.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        
        // ImageView Constraints
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        imageViewBottom = datePicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        imageViewBottom.isActive = true
        imageViewHeight = datePicker.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        imageViewHeight.isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerViewHeight.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        containerView.clipsToBounds = offsetY <= 0
        imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
    
    @objc private func didChangeDate(sender: UIDatePicker) {
        let date = sender.date
        let todayStartOfDay = Calendar.current.startOfDay(for: date)
        let timeOfStartDay = Int(todayStartOfDay.timeIntervalSince1970)
        timeStampBlock?(timeOfStartDay)
    }
}
