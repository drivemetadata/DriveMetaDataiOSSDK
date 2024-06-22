//
//  DriveMetaData.swift
//  DMD
//
//  Created by DriveMetaData on 18/02/24.
//

import Foundation
import Network

public class DriveMetaData {
    private var clientId: Int
    private var clientToken: String
    private var clientAppId: Int
    
    private init(clientId: Int, clientToken: String, clientAppId: Int) {
        self.clientId = clientId
        self.clientToken = clientToken
        self.clientAppId = clientAppId
        StorageManager.shared.saveClientData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId)
        if(!StorageManager.shared.getInstallFirstTime()){
            firstInstall()
        }


    }
    
   
    
    public static func initialise(clientId: Int, token: String, appId: Int) -> DriveMetaData {
        return DriveMetaData(clientId: clientId, clientToken: token, clientAppId: appId)
    }
    func firstInstall()
    {
       
        let retrievedData = StorageManager.shared.getClientData()
        let appDetails = RequestData.MetaData.AppDetails(
            app_id: retrievedData.clientAppId ?? 0,
            bundle: retrievedData.bundleIdentifier ?? "N/A",
            name: retrievedData.appName ?? "N/A",
            version: retrievedData.appVersion ?? "N/A",
            build: retrievedData.appBuild ?? "N/A"
        )

        let jsonData = RequestData(
            metaData: RequestData.MetaData(
                appDetails: appDetails,
                attributionData: RequestData.MetaData.AttributionData(
                click_id: "1719032827",
                install_referrer: "12345678",
                sdk_version: retrievedData.sdkVersion ?? "0.00.00",
                referrer_click_timestamp_seconds: 123456789,
                install_begin_timestamp_seconds: 123456789,
                referrer_click_timestamp_server_seconds: 123456789,
                install_begin_timestamp_server_seconds: 123456789,
                install_version: "1.0",
                google_play_instant: ""
                ),
                utmParameter: RequestData.MetaData.UTMParameter(
                    utm_campaign: "",
                    utm_term: "",
                    utm_source: "",
                    utm_medium: "",
                    utm_content: ""
                ),
                device: StorageManager.shared.getDeviceDetails(),
                ip: "1234566",
                library: StorageManager.shared.getLibraryDetails(),
                locale: "en-US",
                network: StorageManager.shared.getNetworkDetails(),
                ua: "",
                requestId: StorageManager.shared.getCurrentDate(),
                requestReceivedAt: StorageManager.shared.getCurrentDate(),
                requestSentAt: StorageManager.shared.getCurrentDate(),
                timestamp: StorageManager.shared.getTimeStamp() ?? "N/A",
                eventType: "install",
                requestFrom: "1",
                token: retrievedData.clientToken ?? "N/A",
                clientId: retrievedData.clientId ?? 0, 
                userDetails: nil
            )
        )

        RestApiManager.sendRequest(jsonData: jsonData)


      
    }
    
    public static func sendTags(firstName : String , lastName : String , eventType : String)
    {
       
        let retrievedData = StorageManager.shared.getClientData()
        let userDetails = RequestData.MetaData.UserDetails(first_name: firstName, last_name: lastName)

        let jsonData = RequestData(
            metaData: RequestData.MetaData(
                appDetails: nil,
                attributionData: nil,
                utmParameter:nil,
                device: nil,
                ip: "122.177.97.49",
                library: nil,
                locale: "en-US",
                network: nil,
                ua: StorageManager.shared.getCurrentDate(),
                requestId: StorageManager.shared.getCurrentDate(),
                requestReceivedAt: StorageManager.shared.getCurrentDate(),
                requestSentAt: StorageManager.shared.getCurrentDate(),
                timestamp: StorageManager.shared.getTimeStamp() ?? "N/A",
                eventType: eventType,
                requestFrom: "3",
                token: retrievedData.clientToken ?? "N/A",
                clientId: retrievedData.clientId ?? 0, 
                userDetails: userDetails
            )
        )

        RestApiManager.sendRequest(jsonData: jsonData)

    }
   
  
}

