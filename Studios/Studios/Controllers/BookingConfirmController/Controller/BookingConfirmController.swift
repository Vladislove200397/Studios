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

class BookingConfirmController: UIViewController {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userPhoneNumberTF: UITextField!
    @IBOutlet weak var userEmailTF: UITextField!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var studioImageView: UIImageView!
    @IBOutlet weak var studioNameLabel: UILabel!
    @IBOutlet weak var bookingTimeLabel: UILabel!
    @IBOutlet weak var bookingButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var bookingModel = FirebaseBookingModel()
    private var bookingType: SelectionType = .singleSelection
    private var controllerType: BookingStudioControllerType = .booking
    private var updateBlock: FirebaseBookingModelBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupTextFields()
        hideKeyboardWhenTappedAround()
    }
    
    deinit {
        print("DEINIT CONFIRMATION CONTROLLER")
    }
    
    func set(bookingModel: FirebaseBookingModel, bookingType: SelectionType, controllerType: BookingStudioControllerType, updateBlock: FirebaseBookingModelBlock? = nil) {
        self.bookingModel = bookingModel
        self.bookingType = bookingType
        self.title = "Запись"
        self.controllerType = controllerType
        self.updateBlock = updateBlock
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
        
        if controllerType == .editBooking {
            commentTF.text = bookingModel.comment
            userPhoneNumberTF.text = bookingModel.userPhone
        }
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
        let results = [userNameTF.isValid(type: .name), userPhoneNumberTF.isValid(type:.phone), userEmailTF.isValid(type: .email)]
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
    
    private func postBookingStudioRequest(_ bookingModel: FirebaseBookingModel, _ userID: String, _ studioID: String, complition: @escaping RequestBlock, failure: @escaping RequestBlock) {
        var error: Error?
        let group = DispatchGroup()
        let concurrentCurrency = DispatchQueue(
            label: "concurrentCurrency-postBooking",
            attributes: .concurrent
        )
        
        let postStudioBookingModelWorkItem = DispatchWorkItem {
            FirebaseProvider().postBookingModel(
                bookingModel: bookingModel,
                referenceType: .postUserBookingRef(userID: userID)
            ) {
                print("ЗАБРОНИРОВАНО")
                group.leave()
            } failure: { requestError in
                error = requestError
            }
        }
        
        let postUserBookingModel = DispatchWorkItem {
            FirebaseProvider().postBookingModel(
                bookingModel: bookingModel,
                referenceType: .postStudioBookingRef(studioID: studioID)
            ) {
                group.leave()
            } failure: { requestError in
                error = requestError
            }
        }
        
        group.enter()
        concurrentCurrency.async(execute: postStudioBookingModelWorkItem)
        
        group.enter()
        concurrentCurrency.async(execute: postUserBookingModel)
        
        group.notify(queue: .main) {
            [weak self] in
            guard let self else { return }
            guard let error else {
                self.spinner.stopAnimating()
                complition()
                return
            }
            failure()
        }
    }
    
    private func updateBookingStudioRequest(_ bookingModel: FirebaseBookingModel, _ userID: String, _ studioID: String, complition: @escaping RequestBlock, failure: @escaping RequestBlock) {
        var error: Error?
        let group = DispatchGroup()
        let concurrentCurrency = DispatchQueue(
            label: "concurrentCurrency-updateBooking",
            attributes: .concurrent
        )
        
        let updateStudioBookingWorkItem = DispatchWorkItem {
            FirebaseProvider().updateStudioBooking(bookingModel, .postStudioBookingRef(studioID: studioID)) {
                group.leave()
            } failure: { requestError in
                error = requestError
            }
        }
        
        let updateUserBookingWorkItem = DispatchWorkItem {
            FirebaseProvider().updateStudioBooking(bookingModel, .postUserBookingRef(userID: userID)) {
                group.leave()
            } failure: { requestError in
                error = requestError
            }
        }
        
        group.enter()
        concurrentCurrency.async(execute: updateStudioBookingWorkItem)
        
        group.enter()
        concurrentCurrency.async(execute: updateUserBookingWorkItem)
        
        group.notify(queue: .main) {[weak self] in
            guard let self else { return }
            guard error != nil else {
                self.spinner.stopAnimating()
                complition()
                return
            }
            failure()
        }
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
                updateBookingStudioRequest(
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



