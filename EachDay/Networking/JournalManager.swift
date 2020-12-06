//
//  JournalManager.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/3.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class JournalManager {
    static let shared = JournalManager()
    
    var database = Firestore.firestore()
    
    func fetchJournalData(userDocID: String, selectedMonth: Int, completion: @escaping (Result<[Journal], Error>) -> Void) {
        database.collection("User").document(userDocID).collection("Journal").addSnapshotListener({ querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let allJournalData = documents.compactMap({ queryDocumentSnapshot -> Journal? in
                    return try? queryDocumentSnapshot.data(as: Journal.self)
                })
                let journalData = allJournalData.filter({
                    let month = Date(timeIntervalSince1970: $0.date).month()
                    return month == selectedMonth
                })
                completion(.success(journalData))
            }
        })
    }
    
    func fetchFilteredJournalData(userDocID: String, selectedMonth: Int, currentDate: Double, completion: @escaping (Result<[Journal], Error>) -> Void) {
        database.collection("User").document(userDocID).collection("Journal").whereField("date", isLessThan: currentDate).addSnapshotListener({ querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let allJournalData = documents.compactMap({ queryDocumentSnapshot -> Journal? in
                    return try? queryDocumentSnapshot.data(as: Journal.self)
                })
                let journalData = allJournalData.filter({
                    let month = Date(timeIntervalSince1970: $0.date).month()
                    return month == selectedMonth
                })
                completion(.success(journalData))
            }
        })
    }
    
    func publishJournalData(journal: inout Journal, userID: String, completion: @escaping (Result<String, Error>) -> Void) {
        let document = database.collection("User").document(userID).collection("Journal").document()
        journal.id = document.documentID
        do {
            try document.setData(from: journal)
            completion(.success("Successfully uploaded journal data!"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteJournalData() {
        
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
    
    func updateJournalTags(userID: String, tags: [String]) {
        let user = database.collection("User").document(userID)
        user.updateData([
            "journalTags": tags
        ]) { err in
            if let err = err {
                print("Error in updating user data")
            } else {
                print("User data updated successfully!")
            }
        }
    }
    
    func uploadImage(userID: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let timeStamp = Date().timeIntervalSince1970
        let storageRef = Storage.storage().reference().child("\(userID)\(timeStamp).png")
        guard let imageData = image.pngData() else {
            print("Can't convert to png data.")
            return
        }
        
        storageRef.putData(imageData, metadata: nil, completion: { metadata, error in
            if let error = error {
                print("Failed to upload image to Firebase.")
                completion(.failure(error))
            } else {
                let url = storageRef.downloadURL(completion: { url, error in
                    guard let downloadURL = url else {
                        print("Can't convert to url")
                        return
                    }
                    print(downloadURL)
                    completion(.success(downloadURL.absoluteString))
                })
            }
            
        })
    }
}
