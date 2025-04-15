//
//  DeviceInfoManager.swift
//  Pods
//
//  Created by DriveMetaData on 13/03/25.
//

import UIKit
import AdSupport
import AppTrackingTransparency

class DeviceInfoManager {
    static let shared = DeviceInfoManager()
    
    private init() {}

    /// Requests App Tracking Transparency permission and retrieves IDFA if granted.
    func requestAdTrackingPermission(completion: @escaping (String?, Bool) -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    let isTrackingEnabled = (status == .authorized)
                    let idfa = isTrackingEnabled ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
                    UserDefaults.standard.set(isTrackingEnabled, forKey: "adstatus")
                    UserDefaults.standard.set(idfa, forKey: "idfa")
                    completion(idfa, isTrackingEnabled)
                }
            }
        } else {
            let isTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            let idfa = isTrackingEnabled ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
            UserDefaults.standard.set(isTrackingEnabled, forKey: "adstatus")
            UserDefaults.standard.set(idfa, forKey: "idfa")
            completion(idfa, isTrackingEnabled)
        }
    }

    /// Retrieves stored ad tracking details (IDFA & tracking status)
    func getAdTrackingDetails() -> (idfa: String?, isTrackingEnabled: Bool) {
        let isTrackingEnabled = UserDefaults.standard.bool(forKey: "adstatus")
        let idfa = UserDefaults.standard.string(forKey: "idfa")
        return (idfa, isTrackingEnabled)
    }

    /// Retrieves device details, including ad tracking info
    func getDeviceDetails() -> [String: Any] {
        let adTrackingDetails = getAdTrackingDetails()
        
        return [
            "device_internal_id": UIDevice.current.identifierForVendor?.uuidString ?? "N/A",
            "ios_advertising_id": adTrackingDetails.idfa ?? "Tracking not allowed",
            "ad_tracking_enabled": adTrackingDetails.isTrackingEnabled,
            "make": "Apple",
            "model": UIDevice.current.model,
            "platform": UIDevice.current.systemName,
            "name": UIDevice.current.name,
            "device_type": UIDevice.current.userInterfaceIdiom == .pad ? "Tablet" : "Mobile",
            "is_mobile": UIDevice.current.userInterfaceIdiom == .phone,
            "screen": getScreenDetails()
        ]
    }
    
   
    //call generateUniqueID
    func generateUniqueID() -> String {
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)

        // Break timestamp into parts for UUIDv7 layout
        let timeHigh = UInt16((timestamp >> 32) & 0xFFFF)
        let timeMid = UInt16((timestamp >> 16) & 0xFFFF)
        let timeLow = UInt16(timestamp & 0xFFFF)

        // Version 7 (binary 0111)
        let version: UInt16 = 0x7000 | (UInt16.random(in: 0...0x0FFF))

        // Variant bits (RFC 4122 compliant)
        let variant: UInt16 = 0x8000 | (UInt16.random(in: 0...0x3FFF))

        // Random node (48 bits)
        let node = (0..<6).map { _ in UInt8.random(in: 0...255) }

        // Format as UUID string
        let uuidv7 = String(format: "%04x%04x-%04x-%04x-%04x-%02x%02x%02x%02x%02x%02x",
                            timeHigh, timeMid, timeLow,
                            version, variant,
                            node[0], node[1], node[2], node[3], node[4], node[5])

        return uuidv7
    }
    func getAnonymousId() -> String {
        let key = "anonymous_id"
        let defaults = UserDefaults.standard

        // Check if already stored
        if let storedID = defaults.string(forKey: key) {
            return storedID
        }

        // Generate, store, and return
        let generateAnonymousId = generateUniqueID()
        defaults.set(generateAnonymousId, forKey: key)
        return generateAnonymousId
    }
    

    /// Retrieves screen details
    private func getScreenDetails() -> [String: Any] {
        return [
            "width": Int(UIScreen.main.bounds.width),
            "height": Int(UIScreen.main.bounds.height),
            "screen_dpi": Int(UIScreen.main.scale)
        ]
    }
}
