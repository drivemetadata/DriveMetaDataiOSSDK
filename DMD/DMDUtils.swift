//
//  DMDUtils.swift
//  DriveMetaDataiOSSDK
//
//  Created by DriveMetaData on 31/03/24.
//

import Foundation

class Utils
{
    public static func getDeviceNameAndOSVersion() -> (deviceName: String, osVersion: String) {
        let device = UIDevice.current
        let deviceName = device.name
        let osVersion = device.systemVersion
        return (deviceName, osVersion)
    }
    public static func getAppVersion()-> String
    {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        } else {
           return ""
        }
    }
    
}
