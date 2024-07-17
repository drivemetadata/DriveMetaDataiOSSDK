//
//  DriveMetaData.swift
//  DMD
//
//  Created by DriveMetaData on 18/02/24.
//

import Foundation
import Network
import AdSupport
import StoreKit
import AdServices



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
        generateToken()


    }
    public  func generateToken()
    {
        if #available(iOS 14.3, *) {
            if let token = try? AAAttribution.attributionToken() {
                // Send the token to your server
                sendAttributionTokenToServer(token)
                print("token",token)
            }
        } else {
            print("Attribution token generation is not available on this device.")
        }
    }
    
    func sendAttributionTokenToServer(_ token: String) {
        let url = URL(string: "https://yourserver.com/attribution")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["token": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send token: \(error)")
                return
            }
            print("Token sent successfully")
        }

        task.resume()
    }
    func getCampaignData(attributionToken: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = URL(string: "https://api-adservices.apple.com/api/v1/")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(attributionToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusError = NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)
                completion(.failure(statusError))
                return
            }
            
            guard let data = data else {
                let dataError = NSError(domain: "DataError", code: -1, userInfo: nil)
                completion(.failure(dataError))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    let parsingError = NSError(domain: "ParsingError", code: -1, userInfo: nil)
                    completion(.failure(parsingError))
                }
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }
        
        task.resume()
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
    
    // Method to update conversion value
   public static func updateConversionValue(for event: String) {
        let conversionValue = determineConversionValue(for: event)
        guard conversionValue >= 0 && conversionValue <= 63 else {
            print("Invalid conversion value: \(conversionValue)")
            return
        }
        
        if #available(iOS 14.0, *) {
            if #available(iOS 15.4, *) {
                SKAdNetwork.updatePostbackConversionValue(conversionValue) { error in
                    if let error = error {
                        print("Failed to update conversion value: \(error.localizedDescription)")
                    } else {
                        print("Successfully updated conversion value to \(conversionValue)")
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            print("SKAdNetwork is not available on this device.")
        }
    }

    // Algorithm to determine conversion value
   static func determineConversionValue(for event: String) -> Int {
        switch event {
        case "in_app_purchase":
            return 10
        case "level_completed":
            return 20
        case "high_score":
            return 30
        default:
            return 0
        }
    }
   
  
}

