//
//  SessionManager.swift
//  Pods
//
//  Created by DriveMetaData on 05/04/25.
//

import Foundation

class SessionManager {
    static let shared = SessionManager()
    
    private let sessionIDKey = "session_id"
    private let lastActivityKey = "last_activity_timestamp"
    private let sessionTimeout: TimeInterval = 30 * 60 // 30 minutes

    private init() {}

    func getSessionID() -> String {
        let now = Date()
        let defaults = UserDefaults.standard

        if let lastActivity = defaults.object(forKey: lastActivityKey) as? Date,
           let existingSession = defaults.string(forKey: sessionIDKey),
           now.timeIntervalSince(lastActivity) < sessionTimeout {
            // Return existing session if within 30 mins
            updateLastActivity()
            return existingSession
        }

        // Create new session
        let newSession = DeviceInfoManager.shared.generateUniqueID()
        defaults.set(newSession, forKey: sessionIDKey)
        defaults.set(now, forKey: lastActivityKey)
        return newSession
    }

    func updateLastActivity() {
        UserDefaults.standard.set(Date(), forKey: lastActivityKey)
    }

    func resetSession() {
        UserDefaults.standard.removeObject(forKey: sessionIDKey)
        UserDefaults.standard.removeObject(forKey: lastActivityKey)
    }
}
