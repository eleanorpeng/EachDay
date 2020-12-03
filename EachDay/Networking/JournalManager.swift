//
//  JournalManager.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/3.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class JournalManager {
    static let shared = JournalManager()
    
    var db = Firestore.firestore()
    
    func fetchJournalData(userDocID: String, selectedMonth: Int, completion: @escaping (Result<[Journal], Error>) -> Void) {
        db.collection("User").document(userDocID).collection("Journal").addSnapshotListener({ querySnapshot, error in
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
    
    func publishJournalData(journal: inout Journal, completion: @escaping (Result<String, Error>) -> Void) {
        let document = db.collection("user").document().collection("journal").document()
        journal.id = document.documentID
        do {
            try document.setData(from: journal)
            completion(.success("Success!"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteJournalData() {
        
    }
    
    func fetchUser(userID: String, completion: @escaping (Result<[User], Error>) -> Void) {
        db.collection("User").whereField("id", isEqualTo: userID).addSnapshotListener({ querySnapshot, error in
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
        let user = db.collection("User").document(userID)
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
    
    func deleteJournalTags() {
        
    }
    
    func updateTags() {
        
    }
}
