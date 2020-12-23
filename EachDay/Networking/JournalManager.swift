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
//    var userDocID = UserDefaults.standard.string(forKey: EPUserDefaults.userId.rawValue)
    
    var userDocID = "IAMACTUALLYFAKE"
    var database = Firestore.firestore()
    
    func fetchJournalData(selectedMonth: Int, completion: @escaping (Result<[Journal], Error>) -> Void) {
        database.collection("User").document(userDocID ?? "").collection("Journal").order(by: "date", descending: true).addSnapshotListener({ querySnapshot, error in
            print("HERE: \(self.userDocID)")
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let allJournalData = documents.compactMap({ queryDocumentSnapshot -> Journal? in
                    return try? queryDocumentSnapshot.data(as: Journal.self)
                })
                let journalData = allJournalData.filter({
                    let month = $0.date.dateValue().month()
                    return month == selectedMonth
                })
                completion(.success(journalData))
            }
        })
    }
    
    func fetchTimeCapsuleData(currentDate: Date, completion: @escaping (Result<[Journal], Error>) -> Void) {
        database.collection("User").document(userDocID ?? "").collection("Journal").whereField("date", isLessThan: currentDate).addSnapshotListener({ querySnapchot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapchot?.documents else { return }
                let allJournalData = documents.compactMap({ queryDocumentSnapshot -> Journal? in
                    return try? queryDocumentSnapshot.data(as: Journal.self)
                })
                let timeCapsule = allJournalData.filter({
                    $0.isTimeCapsule
                })
                completion(.success(timeCapsule))
            }
            
        })
    }
    
    func fetchFilteredJournalData(selectedMonth: Int, selectedYear: Int, completion: @escaping (Result<[Journal], Error>) -> Void) {
        database.collection("User").document(userDocID ?? "").collection("Journal")
            .order(by: "date", descending: true).addSnapshotListener({ querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let allJournalData = documents.compactMap({ queryDocumentSnapshot -> Journal? in
                    return try? queryDocumentSnapshot.data(as: Journal.self)
                })
                let journalData = allJournalData.filter({
                    let month = $0.date.dateValue().month()
                    let year = $0.date.dateValue().year()
                    return month == selectedMonth && year == selectedYear
                })
                completion(.success(journalData))
            }
        })
    }
    
    func changeTimeCapsuleStatus(journalID: String) {
        database.collection("User").document(userDocID ?? "").collection("Journal").document(journalID).updateData([
            "isTimeCapsule": false
        ]) { err in
            if let err = err {
                print("Error in updating time capsule status")
            } else {
                print("Successfully updated time capsule status!")
            }
        }
    }
    
    func publishJournalData(journal: inout Journal, completion: @escaping (Result<String, Error>) -> Void) {
        let document = database.collection("User").document(userDocID ?? "").collection("Journal").document()
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
    
    func fetchUser(completion: @escaping (Result<[User], Error>) -> Void) {
        database.collection("User").whereField("id", isEqualTo: userDocID ?? "").addSnapshotListener({ querySnapshot, error in
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
    
    func updateJournalTags(tags: [String]) {
        let user = database.collection("User").document(userDocID ?? "")
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
    
    func updateJournal(journalID: String, title: String, content: String, tags: [String], image: String, completion: @escaping (Result<String, Error>) -> Void) {
        database.collection("User").document(userDocID ?? "").collection("Journal").document(journalID).updateData([
            "title" : title,
            "content" : content,
            "tags": tags,
            "image": image
        ]) { err in
            if let err = err {
                print("Error in updating journal data")
                completion(.failure(err))
            } else {
                let message = "Journal data updated successfully!"
                completion(.success(message))
            }
        }
    }
    
    func deleteJournal(journalID: String) {
        database.collection("User").document(userDocID ?? "").collection("Journal").document(journalID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let timeStamp = Date().timeIntervalSince1970
        let storageRef = Storage.storage().reference().child("\(userDocID ?? "")\(timeStamp).png")
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
