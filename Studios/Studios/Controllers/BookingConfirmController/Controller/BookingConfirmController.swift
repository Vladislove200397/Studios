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
    private var timer: Timer?
    private var type: ValidationType = .name
    private var bookingType: SelectionType = .singleSelection
    private var controllerType: BookingStudioControllerType = .booking
    private var editBookingModel = FirebaseBookingModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
        self.userEmailTF.delegate = self
        self.userPhoneNumberTF.delegate = self
        self.commentTF.delegate = self
        self.userNameTF.delegate = self
        validateTextFields()
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
        
        self.userPhoneNumberTF.setupForRegEx()
        self.userNameTF.setupForRegEx()
        self.userEmailTF.setupForRegEx()
        self.commentTF.setupForRegEx()
        
        self.userNameTF.text = bookingModel.userName
        self.userEmailTF.text = bookingModel.userEmail
        self.studioNameLabel.text = bookingModel.studioName
        self.bookingTimeLabel.text = message(bookingTime)
                                    
                                    
        let studioImage = UIImage().imageWith(bookingModel.studioName!)
        self.studioImageView.image = studioImage
        self.studioImageView.clipsToBounds = true
        self.studioImageView.layer.cornerRadius = studioImageView.frame.width / 2
        
        self.bookingButton.isEnabled = false
        self.bookingButton.setTitle("Заполните поля", for: .normal)
        
        if controllerType == .editBooking {
            self.commentTF.text = bookingModel.comment
            self.userPhoneNumberTF.text = bookingModel.userPhone
        }
    }
    
    private func validateTextFields() {
        self.userNameTF.validateRegEx(type: .name)
        self.userPhoneNumberTF.validateRegEx(type: .phone)
        self.userEmailTF.validateRegEx(type: .email)
    }

    private func isValidTextField() {
        let results = [self.userNameTF.isValid(type: .name), self.userPhoneNumberTF.isValid(type:.phone), self.userEmailTF.isValid(type: .email)]
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
        self.spinner.startAnimating()
        
        switch controllerType {
            case .booking:
                FirebaseProvider().postBookingModel(bookingModel: bookingModel, referenceType: .postUserBookingRef(userID: userID)) {
                    print("ЗАБРОНИРОВАНО")
                    self.spinner.stopAnimating()
                } failure: {
                    self.spinner.stopAnimating()
                    print("ERROR")
                }
                
                FirebaseProvider().postBookingModel(bookingModel: bookingModel, referenceType: .postStudioBookingRef(studioID: studioID)) {
                    Service().alert.showAlert(controller: self, title: "Успешно", message: self.message(bookingTime)) {
                        self.spinner.stopAnimating()
                        self.dismiss(animated: true)
                    }
                } failure: {
                    Service().alert.showAlert(controller: self, title: "Упс.. Произошла ошибка", message: "Не удалось забронировать студию, попробуйте позже.") {
                        self.spinner.stopAnimating()
                        self.dismiss(animated: true)
                    }
                }
                
            case .editBooking:
                FirebaseProvider().updateStudioBooking(bookingModel, .postStudioBookingRef(studioID: studioID)) {
                    print("SUCCED")
                    self.spinner.stopAnimating()
                } failure: {
                    print("ZALUPA")
                    self.spinner.stopAnimating()
                }
                
                FirebaseProvider().updateStudioBooking(bookingModel, .postUserBookingRef(userID: userID)) {
                    print("SUCCED")
                    self.spinner.stopAnimating()
                } failure: {
                    print("ZALUPA")
                    self.spinner.stopAnimating()
                }
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



