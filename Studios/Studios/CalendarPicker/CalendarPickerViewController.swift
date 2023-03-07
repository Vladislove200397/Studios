/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import SnapKit


class CalendarPickerViewController: UIViewController {
  // MARK: Views
  private lazy var dimmedBackgroundView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    return view
  }()
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = collectionView.backgroundColor
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionViewLayout = UICollectionViewFlowLayout()
    collectionViewLayout.minimumLineSpacing = 0
    collectionViewLayout.minimumInteritemSpacing = 0

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.isScrollEnabled = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
  
  private lazy var headerView = CalendarPickerHeaderView { [weak self] in
    guard let self = self else { return }

    self.dismiss(animated: true)
  }

  private lazy var footerView = CalendarPickerFooterView(
    didTapLastMonthCompletionHandler: { [weak self] in
      guard let self = self else { return }
      self.collectionView.layer.add(self.swipeTransitionToLeftSide(leftSide: false), forKey: nil)
      self.collectionView.collectionViewLayout.invalidateLayout()
      self.collectionView.layoutSubviews()
      
      self.baseDate = self.calendar.date(
        byAdding: .month,
        value: -1,
        to: self.baseDate
      ) ?? self.baseDate
    },
    didTapNextMonthCompletionHandler: { [weak self] in
      guard let self = self else { return }
      self.collectionView.layer.add(self.swipeTransitionToLeftSide(leftSide: true), forKey: nil)
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.layoutSubviews()
    
      self.baseDate = self.calendar.date(
        byAdding: .month,
        value: 1,
        to: self.baseDate
      ) ?? self.baseDate
    })

  // MARK: Calendar Data Values

  private let selectedDate: Date
  
  private var baseDate: Date {
    didSet {
      days = generateDaysInMonth(for: baseDate)
      collectionView.reloadData()
      headerView.baseDate = baseDate
    }
  }

  private lazy var days = generateDaysInMonth(for: baseDate)

  private var numberOfWeeksInBaseDate: Int {
    calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
  }
  
  private let selectedDateChanged: ((Date) -> Void)
  private let calendar = Calendar(identifier: .gregorian)
  private lazy var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d"
    return dateFormatter
  }()

  // MARK: Initializers

  init(baseDate: Date, selectedDateChanged: @escaping ((Date) -> Void)) {
    self.selectedDate = baseDate
    self.selectedDateChanged = selectedDateChanged
    self.baseDate = baseDate
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .overCurrentContext
    modalTransitionStyle = .crossDissolve
    definesPresentationContext = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
    makeConstraints()
    setupVC()
    preformGesture()
    headerView.baseDate = baseDate
  }
  
  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)
    collectionView.reloadData()
  }
  
  private func setupVC() {
    collectionView.register(
      CalendarDateCollectionViewCell.self,
      forCellWithReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier
    )
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  private func setupLayout() {
    view.addSubview(dimmedBackgroundView)
    view.addSubview(containerView)
    view.addSubview(headerView)
    containerView.addSubview(collectionView)
    view.addSubview(footerView)
  }
  
  private func makeConstraints() {
    dimmedBackgroundView.snp.makeConstraints { make in
      make.left.right.top.bottom.equalToSuperview()
    }
    
    headerView.snp.makeConstraints { make in
      make.height.equalTo(85)
      make.bottom.equalTo(collectionView.snp.top)
      make.leading.equalTo(collectionView.snp.leading)
      make.trailing.equalTo(collectionView.snp.trailing)
    }
    
    containerView.snp.makeConstraints { make in
      make.centerY.equalTo(view.snp.centerY).offset(-100)
      make.leading.equalTo(view.snp.leading).offset(25)
      make.trailing.equalTo(view.snp.trailing).offset(-25)
      make.height.equalTo(view.snp.height).multipliedBy(0.3)
    }
    
    collectionView.snp.makeConstraints { make in
      make.centerY.equalTo(containerView.snp.centerY)
      make.leading.equalTo(containerView.snp.leading)
      make.trailing.equalTo(containerView.snp.trailing)
      make.height.equalTo(containerView.snp.height).multipliedBy(1)
    }
    
    footerView.snp.makeConstraints { make in
      make.height.equalTo(60)
      make.top.equalTo(collectionView.snp.bottom)
      make.leading.equalTo(collectionView.snp.leading)
      make.trailing.equalTo(collectionView.snp.trailing)
    }
  }
  
  func swipeTransitionToLeftSide(leftSide: Bool) -> CATransition {
    let transition = CATransition()
//    transition.startProgress = 0.0
//    transition.endProgress = 1.0
    transition.type = CATransitionType.push
    transition.subtype = leftSide ? CATransitionSubtype.fromRight : CATransitionSubtype.fromLeft
    transition.duration = 0.5
    return transition
  }

  func preformGesture(){
      let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
      let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))

      leftGesture.direction = .left
      rightGesture.direction = .right

      self.collectionView.addGestureRecognizer(leftGesture)
      self.collectionView.addGestureRecognizer(rightGesture)
  }

  @objc func handleSwipes (sender: UISwipeGestureRecognizer) {
    switch sender.direction {
      case .left:
        footerView.didTapNextMonthCompletionHandler()
      case .right:
        footerView.didTapLastMonthCompletionHandler()
      default:
        break
    }
  }
}

extension CalendarPickerViewController: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    days.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let day = days[indexPath.row]

    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier,
      for: indexPath) as! CalendarDateCollectionViewCell

    cell.day = day
    return cell
  }
}

extension CalendarPickerViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    let day = days[indexPath.row]
    selectedDateChanged(day.date)
    dismiss(animated: true, completion: nil)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = Int(collectionView.frame.width / 7)
    let height = Int(collectionView.frame.height) / numberOfWeeksInBaseDate
    return CGSize(width: width, height: height)
  }
}

private extension CalendarPickerViewController {
  // 1
  func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
    // 2
    guard
      let numberOfDaysInMonth = calendar.range(
        of: .day,
        in: .month,
        for: baseDate)?.count,
      let firstDayOfMonth = calendar.date(
        from: calendar.dateComponents([.year, .month], from: baseDate))
      else {
        // 3
        throw CalendarDataError.metadataGeneration
    }

    // 4
    let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)

    // 5
    return MonthMetadata(
      numberOfDays: numberOfDaysInMonth,
      firstDay: firstDayOfMonth,
      firstDayWeekday: firstDayWeekday)
  }
  
  func generateDaysInMonth(for baseDate: Date) -> [Day] {
    guard let metadata = try? monthMetadata(for: baseDate) else {
      fatalError("An error occurred when generating the metadata for \(baseDate)")
    }

    let numberOfDaysInMonth = metadata.numberOfDays
    let offsetInInitialRow = metadata.firstDayWeekday
    let firstDayOfMonth = metadata.firstDay

    var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
      .map { day in
        let isWithinDisplayedMonth = day >= offsetInInitialRow
        let dayOffset =
          isWithinDisplayedMonth ?
          day - offsetInInitialRow :
          -(offsetInInitialRow - day)
        
        return generateDay(
          offsetBy: dayOffset,
          for: firstDayOfMonth,
          isWithinDisplayedMonth: isWithinDisplayedMonth)
      }
    
    days += generateStartOfNextMonth(using: firstDayOfMonth)
    return days
  }

  func generateDay(
    offsetBy dayOffset: Int,
    for baseDate: Date,
    isWithinDisplayedMonth: Bool
  ) -> Day {
    let date = calendar.date(
      byAdding: .day,
      value: dayOffset,
      to: baseDate)
      ?? baseDate

    return Day(
      date: date,
      number: dateFormatter.string(from: date),
      isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
      isWithinDisplayedMonth: isWithinDisplayedMonth
    )
  }
  
  func generateStartOfNextMonth(
    using firstDayOfDisplayedMonth: Date
  ) -> [Day] {
    // 2
    guard
      let lastDayInMonth = calendar.date(
        byAdding: DateComponents(month: 1, day: -1),
        to: firstDayOfDisplayedMonth)
      else {
        return []
    }

    // 3
    let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
    guard additionalDays > 0 else {
      return []
    }
    
    // 4
    let days: [Day] = (1...additionalDays)
      .map {
        generateDay(
        offsetBy: $0,
        for: lastDayInMonth,
        isWithinDisplayedMonth: false)
      }

    return days
  }

  enum CalendarDataError: Error {
    case metadataGeneration
  }
}

