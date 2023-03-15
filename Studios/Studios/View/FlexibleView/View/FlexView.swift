//
//  FlexView.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 30.12.22.
//

import UIKit
import SnapKit

class FlexView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    weak var delegate: FlexibleViewDelegate?
    private var timeStampFromDatePicker = 0
    private var currentTimeStamp = 0
    private(set) var type = FlexibleViewTypes.date
    private(set) var isOpen = false {
        didSet {
            animation()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let id = String(describing: FlexView.self)
        Bundle.main.loadNibNamed(id, owner: self)
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
        containerView.isHidden = !self.isOpen
        contentView.layer.cornerRadius = 10
    }
    
    func set(delegate: FlexibleViewDelegate?, type: FlexibleViewTypes) {
        self.delegate = delegate
        self.type = type
        self.setupButton()
        makeConstraints()
        titleLabel.text = type.rawValue
    }
    
    private func makeConstraints() {
//        let picker = type.viewDatePicker
//        containerView.addSubview(picker)
    titleLabel.text = type.rawValue
        //picker.translatesAutoresizingMaskIntoConstraints = false

//        let top = NSLayoutConstraint(item: picker, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0)
//        let bottom = NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)
//        let heigh = NSLayoutConstraint(item: picker, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 216)
//        let center = NSLayoutConstraint(item: picker, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0)
//
//        NSLayoutConstraint.activate([center, top, bottom, heigh])
    }
    
//    private func addView() {
//        switch type {
//            case .date:
//                let picker = type.viewDatePicker
//                containerView.addSubview(picker)
//                picker.addTarget(self, action: #selector(dateDidChange(sender: )), for: .allEvents)
//                picker.minimumDate = Date.now
//                makeConstraints(view: picker)
//            case .time:
//                let picker = type.viewDatePicker
//                containerView.addSubview(picker)
//                picker.addTarget(self, action: #selector(dateDidChange(sender: )), for: .allEvents)
//                picker.minimumDate = Date.now
//                makeConstraints(view: picker)
//        }
//    }
    
    private func getStartTodayTime() {
        let todayStartOfDay = Calendar.current.startOfDay(for: Date.now)
        timeStampFromDatePicker = Int(todayStartOfDay.timeIntervalSince1970)

    }
    
    @IBAction func openButtonDidTap(_ sender: Any) {
        isOpen.toggle()
        animation()
    }
    
  @objc private func dateDidChange(sender: UIDatePicker) {
      let todayStartOfDay = Calendar.current.startOfDay(for: sender.date)
      print(todayStartOfDay)
      timeStampFromDatePicker = Int(todayStartOfDay.timeIntervalSince1970)
//      dateDelegate?.datePickerDidChange(datePickerTimeStamp: sender.date)
    }
    
    private func setupButton() {
        let image = isOpen ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
        toggleButton.setImage(image, for: .normal)
    }
    
    private func animation() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.containerView.isHidden = !self.isOpen
            
            if self.isOpen {
                self.delegate?.viewDidOpen(type: self.type)
            }
            self.setupButton()
        }
    }
    
    func collapse() {
        if isOpen {
            isOpen = false
        }
    }
}
