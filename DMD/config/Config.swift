//
//  Config.swift
//  Pods
//
//  Created by DriveMetaData on 01/03/25.
//
class APIConfig {
    
    
    
    static let shared = APIConfig() // Singleton instance
    let apiURL = "https://api-adservices.apple.com/api/v1/"
    let baseURL = "https://sdk-dev.drivemetadata.com/"
        // skadnetwork/conversion/"
    
    //data-collector/device-exception"
    
            // Determine base URL
    #if DEBUG
            let baseUrl = "https://sdk-dev.drivemetadata.com/"
    #else
            let baseUrl = "https://sdk.drivemetadata.com/"
    #endif
    
    
    
   // let BASE_URL_DEV = "https://sdk-dev.drivemetadata.com/data-collector"
    
    private init() {} // Prevents external instantiation
}
