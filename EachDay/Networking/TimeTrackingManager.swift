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
    var timeRecordID: String?
    
    func uploadTimeRecord(userDocID: String, record: inout TrackedTime, completion: @escaping(Result<String, Error>) -> Void) {
        let document = database.collection("User").document(userDocID).collection("TrackedTime").document()
        record.id = document.documentID
        timeRecordID = document.documentID
        do {
            try document.setData(from: record)
            completion(.success("Successfully uploaded time tracking data!"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchTimeRecord(userDocID: String, completion: @escaping(Result<[TrackedTime], Error>) -> Void) {
        database.collection("User").document(userDocID).collection("TrackedTime").order(by: "endTime", descending: true).addSnapshotListener({ querySnapshot, error in
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
    
    func fetchFilteredTimeRecord(userDocID: String, startDate: Timestamp, endDate: Timestamp, completion: @escaping(Result<[TrackedTime], Error>) -> Void) {
        database.collection("User").document(userDocID).collection("TrackedTime")
            .whereField("date", isLessThan: endDate).whereField("date", isGreaterThan: startDate)
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
    
    func updateFields(userDocID: String, endTime: Timestamp, duration: Double) {
        database.collection("User").document(userDocID).collection("TrackedTime").document(timeRecordID ?? "").updateData([
            "endTime": endTime,
            "duration": duration
        ]) { err in
            if let err = err {
                print("Error in updating time record date")
            } else {
                print("Time record data updated successfully!")
            }
        }
    }
}
