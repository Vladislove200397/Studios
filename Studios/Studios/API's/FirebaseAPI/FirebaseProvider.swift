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
    
    func postBookingModel(bookingModel: FirebaseBookingModel, referenceType: FirebaseReferenses, succed: @escaping () -> Void, failure: @escaping () -> Void) {
        
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
                succed()
            }
        }
    }
    
    func getBookingTimes(referenceType: FirebaseReferenses, succed: @escaping ([Int]) -> Void, failure: ((Error) -> Void)? = nil) {
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
            succed(timesArray)
            ref.removeAllObservers()
        }) { error in
            failure!(error)
            print(error.localizedDescription)
        }
    }
    
    func getBookings(referenceType: FirebaseReferenses, succed: @escaping ([FirebaseBookingModel]) -> Void, failure: ((Error) -> Void)? = nil) {
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
            succed(bookingArr)
            ref.removeAllObservers()
        }) { error in
            
            failure!(error)
            print(error.localizedDescription)
        }
    }
    
    func getLike(referenceType: FirebaseReferenses, succed: @escaping (Bool) -> Void, failure: ((Error) -> Void)? = nil) {
        let ref = referenceType.references
        
        ref.getData(completion: { error, snapshot in
            if let error {
                print(error.localizedDescription)
            } else {
                guard let snapshot else { return }
                let value = snapshot.value as? NSDictionary
                let like = value?["like"] as? Bool ?? false
                succed(like)
            }
        })
        ref.removeAllObservers()
    }
    
    func postLikedStudio(studio: GMSPlace, referenceType: FirebaseReferenses, succed: @escaping () -> Void, failure: ((Error) -> Void)? = nil) {
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
                succed()
            }
        }
    }
    
    func getLikedStudios(referenceType: FirebaseReferenses, succed: @escaping([FirebaseLikedStudioModel]) -> Void, failure: ((Error?) -> Void)? = nil) {
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
            succed(likedStudiosArr)
            ref.removeAllObservers()
        } withCancel: { error in
            failure!(error)
            print(error.localizedDescription)
        }
    }
    
    func removeStudioFromLiked(referenceType: FirebaseReferenses, succed: @escaping () -> Void, failure: ((Error) -> Void)? = nil ) {
        let reference = referenceType.references
        reference.removeValue(completionBlock: { error, _ in
            if let error {
                print(error.localizedDescription)
            } else {
                succed()
            }
        })
    }
    
    func setLikeValue(_ likeFromFir: Bool, referenceType: FirebaseReferenses, succed: @escaping () -> Void, failure: ((Error) -> Void)? = nil) {
        let ref = referenceType.references
        let sendLike = ["like": likeFromFir ? false : true ] as [String : Any]
        ref.setValue(sendLike) { error,_  in
            if let error {
                failure!(error)
            } else {
                succed()
            }
        }
    }
    
    func updateStudioBooking(_ bookingModel: FirebaseBookingModel, _ referenceType: FirebaseReferenses, succed: @escaping (() -> Void), failure: @escaping (() -> Void)) {
       
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
                succed()
            }
        }
    }
    
    func createUser(email: String, password: String, displayName: String, succed: @escaping ((String) -> Void), failure: @escaping (() -> Void)) {
        
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
             succed(uid)
            } else if let error {
                failure()
                print(error.localizedDescription)
            }
        }
    }
    
    func signInWithUser(email: String, password: String, succed: @escaping (() -> Void), failure: @escaping (() -> Void)) {
        let userD = UserDefaults.standard
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let user {
                let uid = user.user.uid
                userD.set(uid, forKey: "uid")
                succed()
            } else if let error {
                failure()
                print(error.localizedDescription)
            }
        }
    }
    
    func saveUser(referenceType: FirebaseReferenses, _ email: String, _ password: String, _ displayName: String,_ surname: String, _ phoneNumber: String, _ userID: String) {
        let ref = referenceType.references
        
        let user = ["user_id": userID,
                    "display_name": displayName,
                    "surname": surname,
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
}



