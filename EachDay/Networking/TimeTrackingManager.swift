//
//  TimeTrackingManager.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/3.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TimeTrackingManager {
    static let shared = TimeTrackingManager()
    var database = Firestore.firestore()
//    var timeRecordID: String?
    var timeRecordID = UserDefaults.standard.string(forKey: "TimeRecordID")
//    var userDocID = UserDefaults.standard.string(forKey: EPUserDefaults.userId.rawValue)
    var userDocID = "IAMACTUALLYFAKE"
    
    func uploadTimeRecord(record: inout TrackedTime, completion: @escaping(Result<String, Error>) -> Void) {
        let document = database.collection("User").document(userDocID ?? "").collection("TrackedTime").document()
        record.id = document.documentID
        timeRecordID = document.documentID
        UserDefaults.standard.setValue(document.documentID, forKey: "TimeRecordID")
        do {
            try document.setData(from: record)
            completion(.success("Successfully uploaded time tracking data!"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchTimeRecord(completion: @escaping(Result<[TrackedTime], Error>) -> Void) {
        database.collection("User").document(userDocID ?? "").collection("TrackedTime").order(by: "startTime", descending: true).addSnapshotListener({ querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let timeRecord = documents.compactMap({ queryDocument -> TrackedTime? in
                    return try? queryDocument.data(as: TrackedTime.self)
                })
                completion(.success(timeRecord))
            }
        })
    }
    
    func fetchFilteredTimeRecord(startDate: Timestamp, endDate: Timestamp, completion: @escaping(Result<[TrackedTime], Error>) -> Void) {
        database.collection("User").document(userDocID ?? "").collection("TrackedTime")
            .whereField("date", isLessThanOrEqualTo: endDate)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .order(by: "date", descending: true)
            .addSnapshotListener({ querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let timeRecord = documents.compactMap({ queryDocument -> TrackedTime? in
                    return try? queryDocument.data(as: TrackedTime.self)
                })
                completion(.success(timeRecord))
            }
        })
    }
    
    func updateFields(endTime: Timestamp, duration: Double, completion: @escaping(Result<String, Error>) -> Void) {
        database.collection("User").document(userDocID ?? "").collection("TrackedTime").document(timeRecordID ?? "").updateData([
            "endTime": endTime,
            "duration": duration
        ]) { err in
            if let err = err {
                print("Error in updating time record date.")
                completion(.failure(err))
            } else {
                let message = "Time record data updated successfully!"
                completion(.success(message))
            }
        }
    }
    
    func updateTrackTimeCategories(categories: [String]) {
        database.collection("User").document(userDocID ?? "").updateData([
            "trackTimeCategories": categories
        ]) { err in
            if let err = err {
                print("Error in updating track time categories.")
            } else {
                print("Track time categories updated successfully!")
            }
        }
    }
    
    func fetchTimeCategory(category: String, completion: @escaping(Result<[TrackedTime], Error>) -> Void) {
        database.collection("User").document(userDocID ?? "").collection("TrackedTime")
            .whereField("taskName", isEqualTo: category)
            .addSnapshotListener({ querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    let timeRecords = documents.compactMap({ queryDocument -> TrackedTime? in
                        return try? queryDocument.data(as: TrackedTime.self)
                    })
                    completion(.success(timeRecords))
                }
        })
    }
}
