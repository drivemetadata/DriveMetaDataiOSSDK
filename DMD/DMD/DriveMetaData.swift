//
//  DriveMetaData.swift
//  DMD
//
//  Created by DriveMetaData on 18/02/24.
//

import Foundation

public class DriveMetaData {
    private var clientId: Int
    private var clientToken: String
    private var clientAppId: Int
    
    private init(clientId: Int, clientToken: String, clientAppId: Int) {
        self.clientId = clientId
        self.clientToken = clientToken
        self.clientAppId = clientAppId
        print("clientId\(clientId)")
        print("clientToken\(clientToken)")
        print("clientAppId\(clientAppId)")
        let deviceInfo = Utils.getDeviceNameAndOSVersion()
        print(deviceInfo.deviceName)
        print(deviceInfo.osVersion)


    }
    
    public static func doSomething() -> String {
        return "First Project"
    }
    
    public static func initialise(clientId: Int, token: String, appId: Int) -> DriveMetaData {
        return DriveMetaData(clientId: clientId, clientToken: token, clientAppId: appId)
    }
    
}
