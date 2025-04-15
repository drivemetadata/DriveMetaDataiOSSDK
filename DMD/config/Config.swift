//
//  Config.swift
//  Pods
//
//  Created by DriveMetaData on 01/03/25.
//
class APIConfig {
    static let shared = APIConfig() // Singleton instance
    let apiURL = "https://api-adservices.apple.com/api/v1/"
    let baseURL = "https://sdk-dev.drivemetadata.com/v1/skadnetwork/conversion/"
    let exceptionURL = "https://sdk-dev.drivemetadata.com/data-collector/device-exception"
    
            // Determine base URL
    #if DEBUG
            let baseUrl = "https://sdk-dev.drivemetadata.com/data-collector/ios"
    #else
            let baseUrl = "https://sdk.drivemetadata.com/data-collector/ios"
    #endif
    
    
    
   // let BASE_URL_DEV = "https://sdk-dev.drivemetadata.com/data-collector"
    
    private init() {} // Prevents external instantiation
}
