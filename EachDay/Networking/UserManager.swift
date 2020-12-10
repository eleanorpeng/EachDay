//
//  UserManager.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/9.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class UserManager {
    static let shared = UserManager()
    let database = Firestore.firestore()
    
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
    
}
