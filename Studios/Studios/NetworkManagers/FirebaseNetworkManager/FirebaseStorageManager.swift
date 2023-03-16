//
//  FirebaseStorageManager.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 16.03.23.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import GooglePlaces

final class FirebaseStorageManager {
    static func uploadPhoto(
        userID: String,
        photo: UIImage,
        complition: @escaping URLBlock,
        failure: @escaping ErrorBlock
    ) {
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
    
    static func downloadData(
        complition: @escaping ImageBlock
    ) {
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
}
