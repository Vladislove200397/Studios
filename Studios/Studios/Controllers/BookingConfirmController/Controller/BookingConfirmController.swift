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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        userEmailTF.delegate = self
        userPhoneNumberTF.delegate = self
        commentTF.delegate = self
        userNameTF.delegate = self
        setupTextFields()
    }
    
    deinit {
        print("DEINIT CONFIRMATION CONTROLLER")
    }
    
    func set(bookingModel: FirebaseBookingModel, bookingType: SelectionType, controllerType: BookingStudioControllerType) {
        self.bookingModel = bookingModel
        self.bookingType = bookingType
        self.title = "Запись"
        self.controllerType = controllerType
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
    
    private func postBookingStudio(_ bookingModel: FirebaseBookingModel, _ userID: String, _ studioID: String) {
        FirebaseProvider().postBookingModel(bookingModel: bookingModel, referenceType: .postUserBookingRef(userID: userID)) {[weak self] in
            guard let self else { return }
            print("ЗАБРОНИРОВАНО")
            self.spinner.stopAnimating()
        } failure: {[weak self] in
            guard let self else { return }
            self.spinner.stopAnimating()
            print("ERROR")
        }
        
        FirebaseProvider().postBookingModel(bookingModel: bookingModel, referenceType: .postStudioBookingRef(studioID: studioID)) {[weak self] in
            guard let self else { return }
            Alerts().showAlert(controller: self, title: "Успешно", message: self.message(bookingModel.bookingTime!)) {
                self.spinner.stopAnimating()
                self.dismiss(animated: true)
            }
        } failure: {[weak self] in
            guard let self else { return }
            Alerts().showAlert(controller: self, title: "Упс.. ", message: "Произошла ошибка, попробуйте позже.") {
                self.spinner.stopAnimating()
                self.dismiss(animated: true)
            }
        }
    }
    
    private func updateBookingStudio(_ bookingModel: FirebaseBookingModel, _ userID: String, _ studioID: String) {
        FirebaseProvider().updateStudioBooking(bookingModel, .postStudioBookingRef(studioID: studioID)) {[weak self] in
            guard let self else { return }
            self.spinner.stopAnimating()
            Alerts().showAlert(controller: self, title: "Успешно", message: "Бронирование изменено на \(self.message(bookingModel.bookingTime!))") {
                self.spinner.stopAnimating()
                self.navigationController?.popToRootViewController(animated: true)
            }
        } failure: {[weak self] in
            guard let self else { return }
            Alerts().showAlert(controller: self, title: "Упс.. ", message: "Произошла ошибка, попробуйте позже.") {
                self.spinner.stopAnimating()
            }
        }
        
        FirebaseProvider().updateStudioBooking(bookingModel, .postUserBookingRef(userID: userID)) {[weak self] in
            guard let self else { return }
            print("SUCCED")
            self.spinner.stopAnimating()
        } failure: {[weak self] in
            guard let self else { return }
            print("ZALUPA")
            self.spinner.stopAnimating()
        }
    }
    
    @IBAction func bookingButtonDidTap(_ sender: UIButton) {
        guard let name = userNameTF.text,
              let userPhone = userPhoneNumberTF.text,
              let userEmail = userEmailTF.text,
              let comment = commentTF.text,
              let studioID = bookingModel.studioID,
              let userID = bookingModel.userID,
              let _ = bookingModel.bookingTime else { return }
        
        let bookingModel = self.bookingModel
        bookingModel.userPhone = userPhone
        bookingModel.comment = comment
        bookingModel.userName = name
        bookingModel.userEmail = userEmail
        
        self.spinner.startAnimating()
        
        switch controllerType {
            case .booking:
                postBookingStudio(bookingModel, userID, studioID)
            case .editBooking:
                updateBookingStudio(bookingModel, userID, studioID)
        }
    }
}

extension BookingConfirmController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



