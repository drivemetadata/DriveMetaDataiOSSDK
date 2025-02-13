//
//  StogrageManager.swift
//  DriveMetaDataiOSSDK
//
//  Created by DriveMetaData on 22/06/24.
//

import Foundation
import CoreTelephony
import Network
import AppTrackingTransparency
import CoreLocation


 class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let clientIdKey = "clientId"
    private let clientTokenKey = "clientToken"
    private let clientAppIdKey = "clientAppId"
    private let bundleIdentifierKey = "bundleIdentifier"
    private let appNameKey = "appName"
    private let appVersionKey = "appVersion"
    private let appBuildKey = "appBuild"
    private let sdkVersion = "sdkVersion"
    private let deviceInternalIdKey = "deviceInternalId"
    private let isFirstTimeInstall = "isFirstTime"


    
    func saveClientData(clientId: Int, clientToken: String, clientAppId: Int) {
        UserDefaults.standard.set(clientId, forKey: clientIdKey)
        UserDefaults.standard.set(clientToken, forKey: clientTokenKey)
        UserDefaults.standard.set(clientAppId, forKey: clientAppIdKey)
        UserDefaults.standard.set("0.0.6",forKey: sdkVersion)
    
        
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
                   UserDefaults.standard.set(bundleIdentifier, forKey: bundleIdentifierKey)
               }
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                   UserDefaults.standard.set(appName, forKey: appNameKey)
               }
               
               if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                   UserDefaults.standard.set(appVersion, forKey: appVersionKey)
               }
               
               if let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                   UserDefaults.standard.set(appBuild, forKey: appBuildKey)
               }
        if let deviceInternalId = UIDevice.current.identifierForVendor?.uuidString {
                   UserDefaults.standard.set(deviceInternalId, forKey: deviceInternalIdKey)
               }
    }
    
    
    func getClientData() -> (clientId: Int?, clientToken: String?, clientAppId: Int?, bundleIdentifier: String?, appName: String?, appVersion: String?, appBuild: String?,sdkVersion :String?, deviceInternalId: String?) {
           let clientId = UserDefaults.standard.integer(forKey: clientIdKey)
           let clientToken = UserDefaults.standard.string(forKey: clientTokenKey)
           let clientAppId = UserDefaults.standard.integer(forKey: clientAppIdKey)
           let bundleIdentifier = UserDefaults.standard.string(forKey: bundleIdentifierKey)
           let appName = UserDefaults.standard.string(forKey: appNameKey)
           let appVersion = UserDefaults.standard.string(forKey: appVersionKey)
           let appBuild = UserDefaults.standard.string(forKey: appBuildKey)
           let sdkVersion = UserDefaults.standard.string(forKey: sdkVersion)
           let deviceInternalId = UserDefaults.standard.string(forKey: deviceInternalIdKey)
           
           return (clientId == 0 ? nil : clientId, clientToken, clientAppId == 0 ? nil : clientAppId, bundleIdentifier, appName, appVersion, appBuild,sdkVersion, deviceInternalId)
       }
    func getDeviceInternalID() -> String
    {
        guard let deviceInternalId =  UserDefaults.standard.string(forKey: deviceInternalIdKey) else { return "device ID is not found" }
        return deviceInternalId
        
    }
     
     func getDeviceDetails() -> [String:Any]{
         let adTrackingEnabled = UserDefaults.standard.object(forKey: "adstatus") as? Bool ?? false
         let width = Int(UIScreen.main.bounds.width)
         let height = Int(UIScreen.main.bounds.height)
         let screenDpi = Int(UIScreen.main.scale)

         var deviceDetails: [String: Any] = [
             "device_internal_id": UIDevice.current.identifierForVendor?.uuidString ?? "N/A",
             "ios_advertising_id": UserDefaults.standard.object(forKey: "idfa") as? String ?? "",
             "ad_tracking_enabled": adTrackingEnabled,
             "make": "Apple",
             "model": UIDevice.current.model,
             "platform":UIDevice.current.systemName,
             "name":UIDevice.current.name,
             "device_type":UIDevice.current.userInterfaceIdiom == .pad ? "Tablet" : "Mobile",
             "is_mobile":UIDevice.current.userInterfaceIdiom == .phone,
             "screen":[
                "width": width,
                "height":height,
                "screen_dpi":screenDpi
             ]
             
         ]
         return deviceDetails
 
       }
     
    private func getScreenDetails() -> RequestData.MetaData.Device.Screen {
            let width = Int(UIScreen.main.bounds.width)
            let height = Int(UIScreen.main.bounds.height)
            let screenDpi = Int(UIScreen.main.scale)
            
            return RequestData.MetaData.Device.Screen(
                width: width,
                height: height,
                screen_dpi: screenDpi
            )
        }
    
     func getLibraryDetails() -> [String:Any]
     
    {
    
        
        let sdkName = "DriveMetaDataiOSSDK"
        let sdkVersion = "1.0.1"
        var library: [String: Any] = [
            
            "name":sdkName,
            "version":sdkVersion,
            
        ]
        return library
        
       
    }
     
     func getAppDetails() -> [String:Any]
     {
         let retrievedData = StorageManager.shared.getClientData()

         var appDetails: [String: Any] = [
             "app_id": retrievedData.clientAppId ?? 0,
             "bundle": retrievedData.bundleIdentifier ?? "N/A",
             "name": retrievedData.appName ?? "N/A",
             "version": retrievedData.appVersion ?? "N/A",
             "build": retrievedData.appBuild ?? "N/A"
         ]
         return appDetails
     }
     
     
  
  func getTimeStamp() -> String?
    {
        let currentTimeStamp = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: currentTimeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    func getCurrentDate() -> String
    {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }
    func isInstallFirstTime(isFirstTime : Bool)
    {
        UserDefaults.standard.setValue(isFirstTime, forKey: isFirstTimeInstall)
    }
    func getInstallFirstTime() -> Bool
    {
        return UserDefaults.standard.bool(forKey: isFirstTimeInstall)
    }
  
    
}
