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
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var dateDelegate: PushButtonDelegate?
    weak var delegate: FlexibleViewDelegate?
    private var hoursArr: [Int] = []
    private var timesArray: [Int] = []
    private var timeStampFromDatePicker = 0
    private var currentTimeStamp = 0
    private var bookingTime = 0
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
        collectionView.dataSource = self
        register()
    }
    
    func set(delegate: FlexibleViewDelegate?, type: FlexibleViewTypes, dateDelegate: PushButtonDelegate, hoursArray: [Int], timesArray: [Int]) {
        self.delegate = delegate
        self.type = type
        self.addView()
        self.setupButton()
        titleLabel.text = type.rawValue
        self.dateDelegate = dateDelegate
        self.hoursArr = hoursArray
        self.timesArray = timesArray
    }
    
    func setTimes(_ timesArray: [Int]) {
        self.timesArray = timesArray
    }
    
    private func register() {
        let nib = UINib(nibName: HoursCell.id, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: HoursCell.id)
    }
    
    private func makeConstraints(view: UIView, superView: UIView) {
        view.snp.makeConstraints { make in
            make.top.equalTo(superView).offset(0)
            make.bottom.equalTo(superView).offset(0)
            make.height.equalTo(view.frame.height)
            make.center.equalToSuperview()
        }
    }
    
    private func addView() {
        switch type {
            case .date:
                collectionView.isHidden = true
                let picker = type.viewDatePicker
                containerView.addSubview(picker)
                picker.addTarget(self, action: #selector(dateDidChange(sender: )), for: .allEvents)
                picker.minimumDate = Date.now
                picker.translatesAutoresizingMaskIntoConstraints = false
                makeConstraints(view: picker, superView: containerView)
                
            case .startTime:
                let picker = collectionView!

                self.containerView.addSubview(picker)
                picker.translatesAutoresizingMaskIntoConstraints = false

                makeConstraints(view: picker, superView: containerView)
                
            case .endTime:
                break
                
        }
    }
    
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
      self.collectionView.reloadData()
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

extension FlexView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hoursArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HoursCell.id, for: indexPath)
        guard let hoursCell = cell as? HoursCell else { return cell }
        
        let compareTime = (hoursArr[indexPath.row]*3600) + timeStampFromDatePicker
        
        let isEnabled = timesArray.first(where: {$0 == compareTime}) == compareTime
        print(compareTime)
        
        
//        hoursCell.set(bookingTime: compareTime,
//                      buttonLabel: "\(hoursArr[indexPath.row])",
//                      delegate: dateDelegate, indexPath: 0,
//                      buttonEnabled: !isEnabled,
//                      buttonHidden: false)
        return hoursCell
    }
}
