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
        UserDefaults.standard.set("1.0.0",forKey: sdkVersion)
    
        
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
    func getNetworkDetails() -> RequestData.MetaData.Network {
           let bluetoothEnabled = false // Bluetooth is not accessible in iOS without user interaction
           let carrier = getCarrierName()
           let cellularEnabled = isCellularEnabled()
           let wifiEnabled = isWiFiEnabled()
           
           return RequestData.MetaData.Network(
               bluetooth: bluetoothEnabled,
               carrier: carrier,
               cellular: cellularEnabled,
               wifi: wifiEnabled
           )
       }
       
       private func getCarrierName() -> String {
           let networkInfo = CTTelephonyNetworkInfo()
           if let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value {
               return carrier.carrierName ?? "Unknown"
           }
           return "Unknown"
       }
       
       private func isCellularEnabled() -> Bool {
           let networkInfo = CTTelephonyNetworkInfo()
           if #available(iOS 12.0, *) {
               return networkInfo.serviceCurrentRadioAccessTechnology != nil
           } else {
               return networkInfo.currentRadioAccessTechnology != nil
           }
       }
       
       private func isWiFiEnabled() -> Bool {
           let monitor = NWPathMonitor()
           let queue = DispatchQueue(label: "NetworkMonitor")
           var wifiEnabled = false
           
           monitor.pathUpdateHandler = { path in
               if path.usesInterfaceType(.wifi) {
                   wifiEnabled = path.status == .satisfied
               }
           }
           
           monitor.start(queue: queue)
           return wifiEnabled
       }
    func getDeviceDetails() -> RequestData.MetaData.Device {
           let deviceInternalId = UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
           let adTrackingEnabled = false
           let make = "Apple"
           let model = UIDevice.current.model
           let platform = UIDevice.current.systemName
           let os_platform_version = UIDevice.current.systemVersion
           let name = UIDevice.current.name
           let deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "Tablet" : "Mobile"
           let isMobile = UIDevice.current.userInterfaceIdiom == .phone
           let screen = getScreenDetails()
           
           return RequestData.MetaData.Device(
            device_internal_id: deviceInternalId,
            idfa: "00.00.00.00.00",
            ad_tracking_enabled: adTrackingEnabled,
            make: make,
            model: model,
            platform: platform,
            os_platform_version: os_platform_version,
            name: name,
            device_type: deviceType,
            is_mobile: isMobile,
            screen: screen
           )
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
    
    func getLibraryDetails() -> RequestData.MetaData.Library
    {
        let sdkName = "DriveMetaDataiOSSDK"
        let sdkVersion = "1.0.0"
        return RequestData.MetaData.Library(
        name: sdkName,
        version: sdkVersion
        )
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
