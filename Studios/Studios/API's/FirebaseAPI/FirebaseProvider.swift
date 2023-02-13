//
//  FirebaseProvider.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 29.12.22.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import GooglePlaces

public class FirebaseProvider {
    
    private func getStartDayTime(timeStamp: Int) -> Int {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let todayStartOfDay = Calendar.current.startOfDay(for: date)
        let timeOfStartDay = Int(todayStartOfDay.timeIntervalSince1970)
        return timeOfStartDay
    }
    
    func postBookingModel(bookingModel: FirebaseBookingModel, referenceType: FirebaseReferenses, success: @escaping () -> Void, failure: @escaping () -> Void) {
        
        //get the uniqID path for save data to booking list
        let bookingID = Int(NSDate.timeIntervalSinceReferenceDate)
        
        guard let userID = bookingModel.userID,
              let userName = bookingModel.userName,
              let userEmail = bookingModel.userEmail,
              let userPhone = bookingModel.userPhone,
              let bookingTime = bookingModel.bookingTime,
              let studioID = bookingModel.studioID,
              let studioName = bookingModel.studioName,
              let comment = bookingModel.comment else { return }
        
        let timeOfStartDay = getStartDayTime(timeStamp: bookingTime.first ?? 0)
        let booking = ["user_id": userID,
                       "user": userName,
                       "user_email": userEmail,
                       "user_phone": userPhone,
                       "booking_time": bookingTime,
                       "studio_id": studioID,
                       "studio_name": studioName,
                       "booking_id": bookingID,
                       "comment": comment,
                       "booking_day": timeOfStartDay
        ] as [String : Any]
        
        let ref: DatabaseReference = referenceType.references
        
        ref.child("\(bookingID)").setValue(booking) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                failure()
                print(error.localizedDescription)
            } else {
                success()
            }
        }
    }
    
    func getBookingTimes(referenceType: FirebaseReferenses, success: @escaping ([Int]) -> Void, failure: ((Error) -> Void)? = nil) {
        let ref: DatabaseReference = referenceType.references
        
        var timesArray: [Int] = []
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for booking in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let bookingObject = booking.value as? [String: Any] else { return }
                    let times = bookingObject["booking_time"] as! [Int]
                    times.forEach { time in
                        timesArray.append(time)
                    }
                }
            }
            success(timesArray)
            ref.removeAllObservers()
        }) { error in
            failure!(error)
            print(error.localizedDescription)
        }
    }
    
    func getBookings(referenceType: FirebaseReferenses, success: @escaping ([FirebaseBookingModel]) -> Void, failure: ((Error) -> Void)? = nil) {
        let ref = referenceType.references
        var bookingArr: [FirebaseBookingModel] = []
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for booking in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let bookingObject = booking.value as? [String: Any] else { return }
                    let time = bookingObject["booking_time"] as! [Int]
                    let studioName = bookingObject ["studio_name"] as! String
                    let bookingID = bookingObject ["booking_id"] as! Int
                    let studioID = bookingObject["studio_id"] as! String
                    let bookingDay = bookingObject["booking_day"] as! Int
                    let comment = bookingObject["comment"] as! String
                    let userPhone = bookingObject["user_phone"] as! String
                    
                    let firebaseBooking = FirebaseBookingModel(bookingTime: time, bookingID: bookingID, userPhone: userPhone, studioID: studioID, studioName: studioName, comment: comment, bookingDay: bookingDay)
                    
                    bookingArr.append(firebaseBooking)
                }
            }
            success(bookingArr)
            ref.removeAllObservers()
        }) { error in
            
            failure!(error)
            print(error.localizedDescription)
        }
    }
    
    func getLike(referenceType: FirebaseReferenses, success: @escaping (Bool) -> Void, failure: ((Error) -> Void)? = nil) {
        let ref = referenceType.references
        
        ref.getData(completion: { error, snapshot in
            if let error {
                print(error.localizedDescription)
            } else {
                guard let snapshot else { return }
                let value = snapshot.value as? NSDictionary
                let like = value?["like"] as? Bool ?? false
                success(like)
            }
        })
        ref.removeAllObservers()
    }
    
    func postLikedStudio(studio: GMSPlace, referenceType: FirebaseReferenses, success: @escaping () -> Void, failure: ((Error) -> Void)? = nil) {
        let ref = referenceType.references
        
        guard let stdioID = studio.placeID,
              let studioName = studio.name else { return }
        let rating = studio.rating
        
        let likedStudio = ["studio_id": stdioID,
                           "studio_name": studioName,
                           "studio_rating": rating,
        ] as [String : Any]
        
        ref.setValue(likedStudio) { error, result in
            if let error = error {
                failure!(error)
                print(error.localizedDescription)
            } else {
                success()
            }
        }
    }
    
    func getLikedStudios(referenceType: FirebaseReferenses, success: @escaping([FirebaseLikedStudioModel]) -> Void, failure: ((Error?) -> Void)? = nil) {
        let ref = referenceType.references
        
        var likedStudiosArr: [FirebaseLikedStudioModel] = []
        
        ref.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                for likedStudios in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let likedObject = likedStudios.value as? [String: Any] else { return }
                    let studioID = likedObject["studio_id"] as! String
                    let studioName = likedObject["studio_name"] as! String
                    let studioRating = likedObject["studio_rating"] as! Float
                    
                    let likedStudio = FirebaseLikedStudioModel(studioID: studioID, studioName: studioName, studioRating: studioRating)
                    
                    likedStudiosArr.append(likedStudio)
                }
            }
            success(likedStudiosArr)
            ref.removeAllObservers()
        } withCancel: { error in
            failure!(error)
            print(error.localizedDescription)
        }
    }
    
    func removeStudioFromLiked(referenceType: FirebaseReferenses, success: @escaping () -> Void, failure: ((Error) -> Void)? = nil ) {
        let reference = referenceType.references
        reference.removeValue(completionBlock: { error, _ in
            if let error {
                print(error.localizedDescription)
            } else {
                success()
            }
        })
    }
    
    func setLikeValue(_ likeFromFir: Bool, referenceType: FirebaseReferenses, success: @escaping () -> Void, failure: ((Error) -> Void)? = nil) {
        let ref = referenceType.references
        let sendLike = ["like": likeFromFir ? false : true ] as [String : Any]
        ref.setValue(sendLike) { error,_  in
            if let error {
                failure!(error)
            } else {
                success()
            }
        }
    }
    
    func updateStudioBooking(_ bookingModel: FirebaseBookingModel, _ referenceType: FirebaseReferenses, success: @escaping (() -> Void), failure: @escaping (() -> Void)) {
        
        guard let userID = bookingModel.userID,
              let userName = bookingModel.userName,
              let userEmail = bookingModel.userEmail,
              let userPhone = bookingModel.userPhone,
              let bookingTime = bookingModel.bookingTime,
              let studioID = bookingModel.studioID,
              let studioName = bookingModel.studioName,
              let comment = bookingModel.comment else { return }
        
        let ref = referenceType.references
        
        let timeOfStartDay = getStartDayTime(timeStamp: bookingTime.first ?? 0)
        let booking = ["user_id": userID,
                       "user": userName,
                       "user_email": userEmail,
                       "user_phone": userPhone,
                       "booking_time": bookingTime,
                       "studio_id": studioID,
                       "studio_name": studioName,
                       "booking_id": bookingModel.bookingID!,
                       "comment": comment,
                       "booking_day": timeOfStartDay
        ] as [String : Any]
        
        ref.child("\(bookingModel.bookingID!)").setValue(booking) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                failure()
                print(error.localizedDescription)
            } else {
                success()
            }
        }
    }
    
    func createUser(viewController: UIViewController, email: String, password: String, displayName: String, success: @escaping ((String) -> Void), failure: @escaping (() -> Void)) {
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if let user  {
                let uid = user.user.uid
                let changeRequest = user.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges(completion: { error in
                    if let error {
                        failure()
                        print(error.localizedDescription)
                    } else {
                        print("Успешно дабвлено имя пользователя")
                    }
                })
                Auth.auth().currentUser?.sendEmailVerification()
                success(uid)
            } else if let error {
                failure()
                print(error.localizedDescription)
            }
        }
    }
    
    func signInWithUser(email: String, password: String, success: @escaping (() -> Void), failureWithEmailOrPassword: @escaping (() -> Void), failureWithEmailAuthentification: @escaping (() -> Void)) {
        let userD = UserDefaults.standard
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let user {
                let uid = user.user.uid
                if user.user.isEmailVerified {
                    success()
                    userD.set(uid, forKey: "uid")
                } else {
                    failureWithEmailAuthentification()
                }
            } else if let error {
                failureWithEmailOrPassword()
                print(error.localizedDescription)
            }
        }
    }
    
    func saveUser(referenceType: FirebaseReferenses, _ email: String, _ password: String, _ displayName: String,_ surname: String, _ phoneNumber: String, _ userID: String) {
        let ref = referenceType.references
        
        let user = ["user_id": userID,
                    "display_name": displayName,
                    "surname": surname,
                    "phone_number": phoneNumber,
                    "user_email": email,
                    "password": password,
                    "profile_photo": "",
        ] as [String : Any]
        
        ref.setValue(user) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("succesfully added userInfo to FIRA")
            }
        }
    }
    
    func getUserInfo(referenceType: FirebaseReferenses, _ userID: String, success: @escaping ((FirebaseUser) -> Void), failure: @escaping (() -> Void)) {
        let ref = referenceType.references

        ref.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                guard let userObject = snapshot.childSnapshot(forPath: "\(userID)").value as? [String: Any] else { return }
                    let userId = userObject["user_id"] as! String
                    let userDisplaName = userObject["display_name"] as! String
                    let userSurname = userObject["surname"] as! String
                    let userEmail = userObject["user_email"] as! String
                    let userProfilePhoto = userObject["profile_photo"] as! String
                    let userPhoneNumber = userObject["phone_number"] as! String
                    let user = FirebaseUser(userName: userDisplaName, userSurname: userSurname, userEmail: userEmail, userPhone: userPhoneNumber, uid: userId, photoURL: userProfilePhoto)
                success(user)
            }
            ref.removeAllObservers()
        } withCancel: { error in
            failure()
            print(error.localizedDescription)
        }
    }
}



