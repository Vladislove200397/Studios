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
import FirebaseStorage
import GooglePlaces

public class FirebaseProvider {
    
    private func getStartDayTime(timeStamp: Int) -> Int {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let todayStartOfDay = Calendar.current.startOfDay(for: date)
        let timeOfStartDay = Int(todayStartOfDay.timeIntervalSince1970)
        return timeOfStartDay
    }
    
    func postBookingModel(bookingModel: FirebaseBookingModel, referenceType: FirebaseReferenses, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        
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
                failure(error)
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
                    guard let bookingObject = booking.value as? [String: Any],
                          let bookingModel = try? FirebaseBookingModel(dict: bookingObject) else { return }

                    bookingArr.append(bookingModel)
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
                    guard let likedObject = likedStudios.value as? [String: Any],
                          let likedStudio = try? FirebaseLikedStudioModel(dict: likedObject)
                    else { return }
                   
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
    
    func updateStudioBooking(_ bookingModel: FirebaseBookingModel, _ referenceType: FirebaseReferenses, success: @escaping (() -> Void), failure: @escaping (Error) -> Void) {
        
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
                failure(error)
                print(error.localizedDescription)
            } else {
                success()
            }
        }
    }
    
    func createUser(viewController: UIViewController, email: String, password: String, displayName: String, success: @escaping ((String) -> Void), failure: @escaping ErrorBlock) {
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if let user  {
                let uid = user.user.uid
                let changeRequest = user.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges(completion: { error in
                    if let error {
                        failure(error)
                        print(error.localizedDescription)
                    } else {
                        print("Успешно дабвлено имя пользователя")
                    }
                })
                Auth.auth().currentUser?.sendEmailVerification()
                success(uid)
            } else if let error {
                failure(error)
                print(error.localizedDescription)
            }
        }
    }
    
    func signInWithUser(email: String, password: String, success: @escaping (() -> Void), failureWithEmailOrPassword: @escaping ((String) -> Void), failureWithEmailAuthentification: @escaping ((String) -> Void)) {
        let userD = UserDefaults.standard
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let user {
                let uid = user.user.uid
                if user.user.isEmailVerified {
                    success()
                    userD.set(uid, forKey: "uid")
                } else {
                    failureWithEmailAuthentification(user.user.isEmailVerifiedMessage)
                }
            } else if let error {
                failureWithEmailOrPassword(error.castToFirebaseError())
            }
        }
    }
    
    func saveUser(referenceType: FirebaseReferenses,displayName: String,surname: String, phoneNumber: String, succes: @escaping RequestBlock, failure: @escaping ErrorBlock) {
        let ref = referenceType.references

        let user = ["display_name": displayName,
                   "surname": surname,
                   "phone_number": phoneNumber,
        ] as? [String: Any]
        
        ref.setValue(user) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                failure(error)
            } else {
                succes()
                print("succesfully added userInfo to FIRA")
            }
        }
    }
    
    func getUserInfo(referenceType: FirebaseReferenses, _ userID: String, success: @escaping ((FirebaseUser) -> Void), failure: @escaping (() -> Void)) {
        let ref = referenceType.references
        
        ref.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                guard let userObject = snapshot.childSnapshot(forPath: "\(userID)").value as? [String: Any],
                        let user = try? FirebaseUser(dict: userObject)
                else { return }
                success(user)
            }
            ref.removeAllObservers()
        } withCancel: { error in
            failure()
            print(error.localizedDescription)
        }
    }
    
    func uploadPhoto(userID: String, photo: UIImage, complition: @escaping(URL) -> Void, failure: @escaping ErrorBlock) {
        let ref = Storage.storage().reference().child("12").child(userID)
        
        guard let imageData = photo.jpegData(compressionQuality: 0.4) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        ref.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error {
                print(error.localizedDescription)
            }
            if metadata != nil {
                ref.downloadURL { url, error in
                    if let error {
                        failure(error)
                    } else if let url {
                        complition(url)
                    }
                }
            }
        }
    }
    
    func downloadData(complition: @escaping (UIImage) -> Void) {
        guard let url = Auth.auth().currentUser?.photoURL else {
            complition(UIImage(systemName: "person")!)
            return
        }
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megabyte = Int64(1 * 1024 * 1024)
        ref.getData(maxSize: megabyte) { imageData, error in
            if let error {
                print(error.localizedDescription)
                complition(UIImage(systemName: "person")!)
            } else {
                guard let imageData,
                      let image = UIImage(data: imageData) else { return }
                complition(image)
            }
        }
    }
    
    func saveAuthuserInfo(photoURL: URL, displaName: String, complition: @escaping RequestBlock, failure: @escaping ErrorBlock) {
        guard let user = Auth.auth().currentUser else { return }
        
        let changeRequest = user.createProfileChangeRequest()
        
        changeRequest.displayName = displaName
        changeRequest.photoURL = photoURL
        changeRequest.commitChanges { error in
            guard let error else {
                complition()
                return
            }
            failure(error)
            print(error.localizedDescription)
        }
    }
    
    static func removeBooking(bookingModel: FirebaseBookingModel, referenceType: FirebaseReferenses, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        
        let ref = referenceType.references
        guard let bookingID = bookingModel.bookingID else { return }
        ref.child("\(bookingID)").removeValue { error, _ in
            if let error {
                print(error.localizedDescription)
                failure(error)
            } else {
                success()
            }
        }
    }
}



