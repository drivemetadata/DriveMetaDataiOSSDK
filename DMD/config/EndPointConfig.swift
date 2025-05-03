//
//  EndPointConfig.swift
//  Pods
//
//  Created by DriveMetaData on 03/05/25.
//


final class EndPointConfig {

    // MARK: - Shared Instance
    static let shared = EndPointConfig()
    
    // MARK: - Endpoints
    let apiException = "data-collector/device-exception"
    let apiEvents = "data-collector/ios"
    let conversionValueMappingApi = "v1/skadnetwork/conversion-value-mapping"
    let updateConversionApi = "/v1/skadnetwork/conversion/"
    
    
    
    
    // Add more endpoints as needed
    // let user_login = "auth/login"
    // let fetch_profile = "user/profile"
    
    // MARK: - Private Initializer
    private init() {}
}
