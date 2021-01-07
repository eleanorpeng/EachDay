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
    var timeRecordID = UserDefaults.standard.string(forKey: "TimeRecordID")
    var userDocID = UserDefaults.standard.string(forKey: EPUserDefaults.userId.rawValue)
//    var userDocID = "IAMACTUALLYFAKE"
    
    // swiftlint:disable all
    let USER_KEY = "User"
    let TRACKED_TIME_KEY = "TrackedTime"
    let TIME_RECORD_ID_KEY = "TimeRecordID"
    let START_TIME_KEY = "startTime"
    let END_TIME_KEY = "endTime"
    let DURATION_KEY = "duration"
    let PAUSE_INTERVALS_KEY = "pauseIntervals"
    let PAUSE_TIME_KEY = "pauseTime"
    let ID_KEY = "id"
    let DATE_KEY = "date"
    let TASK_NAME_KEY = "taskName"
    let TRACK_TIME_CATEGORIES_KEY = "trackTimeCategories"
    // swiftlint:enable all
    
    func uploadTimeRecord(record: inout TrackedTime, completion: @escaping(Result<String, Error>) -> Void) {
        let document = database.collection(USER_KEY).document(userDocID ?? "").collection(TRACKED_TIME_KEY).document()
        record.id = document.documentID
        UserDefaults.standard.setValue(document.documentID, forKey: TIME_RECORD_ID_KEY)
        timeRecordID = UserDefaults.standard.string(forKey: TIME_RECORD_ID_KEY)
        do {
            try document.setData(from: record)
            completion(.success("Successfully uploaded time tracking data!"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchTimeRecord(completion: @escaping(Result<[TrackedTime], Error>) -> Void) {
        database.collection(USER_KEY).document(userDocID ?? "").collection(TRACKED_TIME_KEY).order(by: START_TIME_KEY, descending: true).addSnapshotListener({ querySnapshot, error in
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
        database.collection(USER_KEY).document(userDocID ?? "").collection(TRACKED_TIME_KEY)
            .whereField(DATE_KEY, isLessThanOrEqualTo: endDate)
            .whereField(DATE_KEY, isGreaterThanOrEqualTo: startDate)
            .order(by: DATE_KEY, descending: true)
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
        database.collection(USER_KEY).document(userDocID ?? "").collection(TRACKED_TIME_KEY).document(timeRecordID ?? "").updateData([
            END_TIME_KEY: endTime,
            DURATION_KEY: duration
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
    
    func updatePauseIntervals(pauseIntervals: [TimeInterval], completion: @escaping (Result<String, Error>) -> Void) {
        database.collection(USER_KEY).document(userDocID ?? "").collection(TRACKED_TIME_KEY).document(timeRecordID ?? "").updateData([
            PAUSE_INTERVALS_KEY: pauseIntervals
        ]) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                let message = "Pause time intervals updated successfully!"
                completion(.success(message))
            }
        }
    }
    
    func deletePauseTime(completion: @escaping(Result<String, Error>) -> Void) {
        database.collection(USER_KEY).document(userDocID ?? "").collection(TRACKED_TIME_KEY).document(timeRecordID ?? "").updateData([
           PAUSE_TIME_KEY: FieldValue.delete()
        ]) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                let message = "Paused time updated successfull!"
            }
        }
    }
    func updatePauseTime(pauseTime: Date, completion: @escaping(Result<String, Error>) -> Void) {
        database.collection(USER_KEY).document(userDocID ?? "").collection(TRACKED_TIME_KEY).document(timeRecordID ?? "").updateData([
            PAUSE_TIME_KEY: pauseTime
        ]) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                let message = "Paused time updated successfull!"
            }
        }
    }
    func updateTrackTimeCategories(categories: [String]) {
        database.collection(USER_KEY).document(userDocID ?? "").updateData([
            TRACK_TIME_CATEGORIES_KEY: categories
        ]) { err in
            if let err = err {
                print("Error in updating track time categories.")
            } else {
                print("Track time categories updated successfully!")
            }
        }
    }
    
    func fetchTimeCategory(category: String, completion: @escaping(Result<[TrackedTime], Error>) -> Void) {
        database.collection(USER_KEY).document(userDocID ?? "").collection(TRACKED_TIME_KEY)
            .whereField(TASK_NAME_KEY, isEqualTo: category)
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
