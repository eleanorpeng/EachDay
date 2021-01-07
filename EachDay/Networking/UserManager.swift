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
    
    // swiftlint:disable all
    let USER_KEY = "User"
    let ROUTINE_TIME_KEY = "routineTime"
    let PASSCODE_KEY = "passcode"
    let ID_KEY = "id"
    let NAME_KEY = "name"
    let IMAGE_KEY = "image"
    let CALENDAR_COLORS_KEY = "calendarColors"
    // swiftlint:enable all
    
    var userDocID = UserDefaults.standard.string(forKey: EPUserDefaults.userId.rawValue)
//    var userDocID = "IAMACTUALLYFAKE"
    func uploadUserData(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            print(user.id)
            try database.collection(USER_KEY).document(user.id).setData(from: user)
            completion(.success("Successfully updated user data!"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateRoutineTime(routineTime: Timestamp, completion: @escaping(Result<String, Error>) -> Void) {
        database.collection(USER_KEY).document(userDocID ?? "").updateData([
            ROUTINE_TIME_KEY: routineTime
        ]) { err in
            if let err = err {
                completion(.failure(err))
                print("Failed to update routine time.")
            } else {
                let message = "Routine time updated successfully!"
                completion(.success(message))
            }
        }
    }
    
    func deleteRoutineTime(completion: @escaping(Result<String, Error>) -> Void) {
        database.collection(USER_KEY).document(userDocID ?? "").updateData([
            ROUTINE_TIME_KEY: FieldValue.delete()
        ]) { err in
            if let err = err {
                completion(.failure(err))
                print("Failed to delete routine time.")
            } else {
                let message = "Routine time deleted successfully!"
                completion(.success(message))
            }
        }
    }
    
    func updatePasscode(passcode: String) {
        database.collection(USER_KEY).document(userDocID ?? "").updateData([
            PASSCODE_KEY : passcode
        ]) { err in
            if let err = err {
                print("Failed to update passcode!")
            } else {
                print("Passcode has been updated successfully!")
            }
        }
    }
    
    func fetchUser(completion: @escaping (Result<[User], Error>) -> Void) {
        database.collection(USER_KEY).whereField(ID_KEY, isEqualTo: userDocID ?? "").addSnapshotListener({ querySnapshot, error in
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
    
    func updateUserName(name: String) {
        database.collection(USER_KEY).document(userDocID ?? "").updateData([
            NAME_KEY: name
        ]) { err in
            if let err = err {
                print("Failed to update user name")
            } else {
                print("User name has been updated!")
            }
        }
    }
    
    func updateImage(image: String) {
        database.collection(USER_KEY).document(userDocID ?? "").updateData([
            IMAGE_KEY: image
        ]) { err in
            if let err = err {
                print("Failed to update user profile image")
            } else {
                print("User profile image has been updated!")
            }
        }
    }
    
    func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let timeStamp = Date().timeIntervalSince1970
        let storageRef = Storage.storage().reference().child("\(userDocID ?? "")profileImage.png")
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
                    self.updateImage(image: downloadURL.absoluteString)
                    completion(.success(downloadURL.absoluteString))
                })
            }
        }
    }
    
    func updateCalendarColor(color: [String], completion: @escaping (Result<String, Error>) -> Void) {
        database.collection(USER_KEY).document(userDocID ?? "").updateData([
            CALENDAR_COLORS_KEY : color
        ]) { err in
            if let err = err {
                print("Failed to update color.")
                completion(.failure(err))
            } else {
                completion(.success("Successfully updated color!"))
            }
        }
    }
    
}
