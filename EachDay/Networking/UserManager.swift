//
//  UserManager.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/9.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseStorage

class UserManager {
    static let shared = UserManager()
    let database = Firestore.firestore()
    
    func uploadUserData(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        let document = database.collection("User").document(user.id)
        do {
            try document.setData(from: user)
            completion(.success("Successfully updated user data!"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func updatePasscode(userDocID: String, passcode: String) {
        database.collection("User").document(userDocID).updateData([
            "passcode" : passcode
        ]) { err in
            if let err = err {
                print("Failed to update passcode!")
            } else {
                print("Passcode has been updated successfully!")
            }
        }
    }
    
    func fetchUser(userID: String, completion: @escaping (Result<[User], Error>) -> Void) {
        database.collection("User").whereField("id", isEqualTo: userID).addSnapshotListener({ querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let user = documents.compactMap({ queryDocumentSnapshot -> User? in
                    return try? queryDocumentSnapshot.data(as: User.self)
                })
                completion(.success(user))
            }
        })
    }
    
    func updateUserName(userDocID: String, name: String) {
        database.collection("User").document(userDocID).updateData([
            "name": name
        ]) { err in
            if let err = err {
                print("Failed to update user name")
            } else {
                print("User name has been updated!")
            }
        }
    }
    
    func updateImage(userDocID: String, image: String) {
        database.collection("User").document(userDocID).updateData([
            "image": image
        ]) { err in
            if let err = err {
                print("Failed to update user profile image")
            } else {
                print("User profile image has been updated!")
            }
        }
    }
    
    func uploadImage(userDocID: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let timeStamp = Date().timeIntervalSince1970
        let storageRef = Storage.storage().reference().child("\(userDocID)profileImage.png")
        guard let imageData = image.pngData() else {
            print("Can't convert to png data.")
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Failed to upload image to Firebase.")
                completion(.failure(error))
            } else {
                let url = storageRef.downloadURL(completion: { url, error in
                    guard let downloadURL = url else {
                        print("Can't convert to url")
                        return
                    }
                    self.updateImage(userDocID: userDocID, image: downloadURL.absoluteString)
                    completion(.success(downloadURL.absoluteString))
                })
            }
        }
    }
    
}
