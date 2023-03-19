//
//  BookingConfirmController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 18.01.23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

final class BookingConfirmController: UIViewController {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userPhoneNumberTF: UITextField!
    @IBOutlet weak var userEmailTF: UITextField!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var studioImageView: UIImageView!
    @IBOutlet weak var studioNameLabel: UILabel!
    @IBOutlet weak var bookingTimeLabel: UILabel!
    @IBOutlet weak var bookingButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var notificationButton: UIButton!
    
    private var bookingModel = FirebaseBookingModel()
    private var firebaseUserModel: FirebaseUser?
    private var bookingType: SelectionType = .singleSelection
    private var controllerType: BookingStudioControllerType = .booking
    private var updateBlock: FirebaseBookingBlock?
    private var choseNotificationTimeActionMenu = UIMenu()
    private var notificationTime: [Double] = []
    private var menuActionState: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupTextFields()
        hideKeyboardWhenTappedAround()
        isValidTextField()
        notificationButton.menu = generatePullDownMenu()
        notificationButton.showsMenuAsPrimaryAction = true
    }
    
    deinit {
        print("DEINIT CONFIRMATION CONTROLLER")
    }
    
    func set(
        bookingModel: FirebaseBookingModel,
        bookingType: SelectionType,
        controllerType: BookingStudioControllerType,
        userModel: FirebaseUser? = nil,
        updateBlock: FirebaseBookingBlock? = nil
    ) {
        self.bookingModel = bookingModel
        self.bookingType = bookingType
        self.title = "Запись"
        self.controllerType = controllerType
        self.updateBlock = updateBlock
        self.firebaseUserModel = userModel
    }
    
    private func setupVC() {
        guard let bookingTime = bookingModel.bookingTime else { return }
        userNameTF.text = bookingModel.userName
        userEmailTF.text = bookingModel.userEmail
        studioNameLabel.text = bookingModel.studioName
        bookingTimeLabel.text = message(bookingTime)
        
        let studioImage = UIImage().imageWith(bookingModel.studioName!)
        studioImageView.image = studioImage
        studioImageView.clipsToBounds = true
        studioImageView.layer.cornerRadius = studioImageView.frame.width / 2
        
        bookingButton.isEnabled = false
        bookingButton.setTitle("Заполните поля", for: .normal)
        
        switch controllerType {
            case .booking:
                guard let phonenNumber = firebaseUserModel?.userPhone else { return }
                userPhoneNumberTF.text = phonenNumber
            case .editBooking:
                commentTF.text = bookingModel.comment
                userPhoneNumberTF.text = bookingModel.userPhone
        }
    }
    
    private func menuHandlerBlock(for time: Double, index: Int) {
        if !notificationTime.contains(where: {$0 == time}) {
           notificationTime.append(time)
           menuActionState[index] = true
           notificationButton.menu = self.generatePullDownMenu()
        } else {
            notificationTime.removeAll(where: {$0 == time})
            menuActionState[index] = false
            notificationButton.menu = self.generatePullDownMenu()
        }
        print(notificationTime)
    }
    
    private func generatePullDownMenu() -> UIMenu {
        var time = 0.0
        var actionIndex = 0
        
        for _ in  0...3 {
            menuActionState.append(false)
        }
        
        let actions = [
            UIAction(
                title: "Напомнить за 24 часа",
                attributes: .keepsMenuPresented,
                state: menuActionState[0] ? .on : .off,
                handler: { (_) in
                    time = 60 * (60 * 24)
                    actionIndex = 0
                    self.menuHandlerBlock(for: time, index: actionIndex)
                }),
            UIAction(
                title: "Напомнить за 12 часов",
                attributes: .keepsMenuPresented,
                state: menuActionState[1] ? .on : .off,
                handler: { (_) in
                    time = 60 * (60 * 12)
                    actionIndex = 1
                    self.menuHandlerBlock(for: time, index: actionIndex)
                }),
            UIAction(
                title: "Напомнить за 5 часов",
                attributes: .keepsMenuPresented,
                state: menuActionState[2] ? .on : .off,
                handler: { (_) in
                    time = 60 * (60 * 5)
                    actionIndex = 2
                    self.menuHandlerBlock(for: time, index: actionIndex)
                }),
            UIAction(
                title: "Напомнить за 1 час",
                attributes: .keepsMenuPresented,
                state: menuActionState[3] ? .on : .off,
                handler: { (_) in
                    time = 60 * 60
                    actionIndex = 3
                    self.menuHandlerBlock(for: time, index: actionIndex)
                })]

        let menu = UIMenu(
            title: "Время напоминания",
            children: actions
        )

        return menu
    }

    private func setupTextFields() {
        userEmailTF.delegate = self
        userPhoneNumberTF.delegate = self
        commentTF.delegate = self
        userNameTF.delegate = self
        
        userPhoneNumberTF.setupTextField()
        userNameTF.setupTextField()
        userEmailTF.setupTextField()
        commentTF.setupTextField()
        
        userNameTF.validateRegEx(type: .name)
        userPhoneNumberTF.validateRegEx(type: .phone)
        userEmailTF.validateRegEx(type: .email)
    }
    
    private func isValidTextField() {
        let results = [
            userNameTF.isValid(type: .name),
            userPhoneNumberTF.isValid(type:.phone),
            userEmailTF.isValid(type: .email)
        ]
        let positive = results.filter( {$0 }).count == results.count
        
        if positive {
            self.bookingButton.isEnabled = true
            self.bookingButton.setTitle("Записаться", for: .normal)
        }
    }
    
    private func message(_ bookingArray: [Int]) -> String {
        switch bookingType {
            case .singleSelection:
                let message = "\(bookingArray.first?.formatData(formatType: .dMMMHHmm) ?? "")"
                return message
            case .multipleSelection:
                let message = "\(bookingArray.first?.formatData(formatType: .dMMMHHmm) ?? "") - \((bookingArray.last! + 3600).formatData(formatType: .HHmm))"
                return message
        }
    }
    
    @IBAction func nameTextFieldDidEditing(_ sender: UITextField) {
        sender.validateRegEx(type: .name)
        isValidTextField()
    }
    
    @IBAction func userPhoneTextFieldDidEditing(_ sender: UITextField) {
        sender.validateRegEx(type: .phone)
        isValidTextField()
    }
    
    @IBAction func userEmailTextFieldDidEditing(_ sender: UITextField) {
        sender.validateRegEx(type: .email)
        isValidTextField()
    }
    
    private func postBookingStudioRequest(
        _ bookingModel: FirebaseBookingModel,
        _ userID: String,
        _ studioID: String,
        complition: @escaping RequestBlock,
        failure: @escaping RequestBlock
    ) {
        var error: Error?
        let group = DispatchGroup()
        let concurrentCurrency = DispatchQueue(
            label: "concurrentCurrency-postBooking",
            attributes: .concurrent
        )
        
        let postStudioBookingModelWorkItem = DispatchWorkItem {
            FirebaseStudioManager.postBookingModel(
                type: self.controllerType,
                bookingModel: bookingModel,
                referenceType: .postUserBookingRef(userID: userID)
            ) {
                print("ЗАБРОНИРОВАНО")
                group.leave()
            } failure: { requestError in
                error = requestError
                group.leave()
            }
        }
        
        let postUserBookingModel = DispatchWorkItem {
            FirebaseStudioManager.postBookingModel(
                type: self.controllerType,
                bookingModel: bookingModel,
                referenceType: .postStudioBookingRef(studioID: studioID)
            ) {
                group.leave()
            } failure: { requestError in
                error = requestError
                group.leave()
            }
        }
        
        group.enter()
        concurrentCurrency.async(execute: postStudioBookingModelWorkItem)
        
        group.enter()
        concurrentCurrency.async(execute: postUserBookingModel)
        
        group.notify(queue: .main) {
            [weak self] in
            guard let self else { return }
            guard error != nil else {
                self.spinner.stopAnimating()
                self.createNotificationObject(notificationObject: bookingModel)
                complition()
                return
            }
            failure()
        }
    }
    
    private func createNotificationObject(notificationObject bookingModel: FirebaseBookingModel) {
        
        NotificationsManager().createPushFor(bookingModel, time: notificationTime)
    }
    
    @IBAction func bookingButtonDidTap(_ sender: UIButton) {
        guard let name = userNameTF.text,
              let userPhone = userPhoneNumberTF.text,
              let userEmail = userEmailTF.text,
              let comment = commentTF.text,
              let studioID = bookingModel.studioID,
              let userID = bookingModel.userID,
              let bookingTime = bookingModel.bookingTime else { return }
        
        let bookingModel = self.bookingModel
        bookingModel.userPhone = userPhone
        bookingModel.comment = comment
        bookingModel.userName = name
        bookingModel.userEmail = userEmail
        
        var popUpConfiguration = PopUpConfiguration(
            confirmButtonTitle: "Ok",
            style: .error,
            imageTintColor: .red
        )
        
        self.spinner.startAnimating()
        
        switch controllerType {
            case .booking:
                postBookingStudioRequest(
                    bookingModel,
                    userID,
                    studioID) {[weak self] in
                        guard let self else { return }
                        
                        popUpConfiguration.image = UIImage(systemName: "checkmark.circle")
                        popUpConfiguration.imageTintColor = .systemGreen
                        popUpConfiguration.title = "Успешно"
                        popUpConfiguration.description = "Забронировано на дату \(self.message(bookingTime))"
                        
                        PopUpController.show(
                            on: self,
                            configure: popUpConfiguration) {
                                self.updateBlock?(bookingModel)
                                self.dismiss(animated: true)
                            } discard: {
                            }
                    } failure: { [weak self] in
                        guard let self else { return }
                        
                        popUpConfiguration.image = UIImage(systemName: "nosign")
                        popUpConfiguration.imageTintColor = .red
                        popUpConfiguration.title = "Oшибка"
                        popUpConfiguration.description = "Что-то пошло не так, попробуйте позже"
                        
                        PopUpController.show(
                            on: self,
                            configure: popUpConfiguration) {
                                self.dismiss(animated: true)
                            } discard: {
                            }
                    }
            case .editBooking:
                postBookingStudioRequest(
                    bookingModel,
                    userID,
                    studioID) {[weak self] in
                        guard let self else { return }
                        
                        popUpConfiguration.image = UIImage(systemName: "checkmark.circle")
                        popUpConfiguration.imageTintColor = .systemGreen
                        popUpConfiguration.title = "Успешно"
                        popUpConfiguration.description = "Бронирование изменено на дату \(self.message(bookingTime))"
                        
                        PopUpController.show(
                            on: self,
                            configure: popUpConfiguration) {
                                self.updateBlock?(bookingModel)
                                self.navigationController?.popToRootViewController(animated: true)
                            } discard: {
                            }
                    } failure: {
                        [weak self] in
                        guard let self else { return }
                        
                        popUpConfiguration.image = UIImage(systemName: "nosign")
                        popUpConfiguration.imageTintColor = .red
                        popUpConfiguration.title = "Oшибка"
                        popUpConfiguration.description = "Что-то пошло не так, попробуйте позже"
                        
                        PopUpController.show(
                            on: self,
                            configure: popUpConfiguration) {
                                self.navigationController?.popToRootViewController(animated: true)
                            } discard: {
                            }
                    }
        }
    }
    
    
}

extension BookingConfirmController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



