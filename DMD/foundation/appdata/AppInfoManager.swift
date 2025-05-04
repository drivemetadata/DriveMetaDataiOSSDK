

//
//  AppInfoManager.swift
//  Pods
//
//  Created by DriveMetaData on 03/03/25.
//

import Foundation

class AppInfoManager {
    static let shared = AppInfoManager()
    
    private init() {}
    
    /// Retrieves application details
    func getAppDetails() -> [String: Any] {
        let retrievedData = StorageManager.shared.getClientData()

        return [
            "app_id": retrievedData.clientAppId ?? 0,
            "bundle": Bundle.main.bundleIdentifier ?? "N/A",
            "name": Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "N/A",
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A",
            "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        ]
    }
    
    /// Retrieves library details
    func getLibraryDetails() -> [String: Any] {
        return [
            "sdk_version": "1.0.4"
        ]
    }
}
