//
//  MetaDataManager.swift
//  Pods
//
//  Created by DriveMetaData on 08/02/25.
//

import Foundation

class MetadataManager {
    static let shared = MetadataManager()
    
    private init() {} // Private initializer to enforce singleton pattern
    
    var metadata: [String: Any] = [
        "ua": "",
        "requestId": "5cf174b2-b1d5-418f-9796-e4bc71f94182",
        "requestReceivedAt": "2025-01-16 16:21:33",
        "requestSentAt": "2025-01-16 16:21:33",
        "timestamp": "2025-01-16 16:21:33",
        "eventType": "deviceToken",
        "requestFrom": "1",
        "token": "4d17d90c78154c9a5569c073b67d8a5a22b2fabfc5c9415b6e7f709d68762054",
        "clientId": 1635
    ]
    
    func updateMetadata(with data: [String: Any]) {
        metadata.merge(data) { (_, new) in new } // Merge new data into metadata
    }
}

// Function to Send Events
func sendEvents(jsonData: [String: Any], eventName: String) {
    print("Start")
    
    // Retrieve and update metadata
    MetadataManager.shared.updateMetadata(with: jsonData)
    
    let mainObject: [String: Any] = [
        "metadata": MetadataManager.shared.metadata,
        "eventName": eventName
    ]
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: mainObject, options: .prettyPrinted)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Updated JSON Data: \(jsonString)")
        }
    } catch {
        print("Error parsing JSON: \(error)")
    }
}

//// Example Usage
//let additionalData: [String: Any] = ["deviceName": "iPhone 14", "osVersion": "iOS 17"]
//sendEvents(jsonData: additionalData, eventName: "AppLaunch")
