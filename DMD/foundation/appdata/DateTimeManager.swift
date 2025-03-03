//
//  DateTimeManager.swift
//  Pods
//
//  Created by DriveMetaData on 03/03/25.
//

import Foundation

class DateTimeManager {
    static let shared = DateTimeManager()
    
    private init() {}
    
    /// Retrieves the current timestamp
    func getTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    /// Retrieves the current date in formatted string
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
