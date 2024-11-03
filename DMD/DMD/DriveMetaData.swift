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


// Define your callback type
public typealias DeepLinkCallback = (Result<String, Error>) -> Void
public class DriveMetaData {
    private var clientId: Int
    private var clientToken: String
    private var clientAppId: Int

    // Singleton instance
    public static let shared = DriveMetaData(clientId: 0, clientToken: "", clientAppId: 0)

    // Private initializer to restrict instantiation
    private init(clientId: Int, clientToken: String, clientAppId: Int) {
        self.clientId = clientId
        self.clientToken = clientToken
        self.clientAppId = clientAppId
        
        // Save client data in storage
        StorageManager.shared.saveClientData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId)
        
        // Check and handle first-time installation
        if !StorageManager.shared.getInstallFirstTime() {
            firstInstall()
        }
        
        // Generate token
        generateToken()
    }

  

    // Public method to set or configure the singleton instance's properties
    public func configure(clientId: Int, clientToken: String, clientAppId: Int) {
        self.clientId = clientId
        self.clientToken = clientToken
        self.clientAppId = clientAppId
        
        StorageManager.shared.saveClientData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId)
    }
    public  func generateToken()
    {
        if #available(iOS 14.3, *) {
            if let token = try? AAAttribution.attributionToken() {
                sendAttributionTokenToServer(token)
            }
        } else {
            print("Attribution token generation is not available on this device.")
        }
    }
    
    func sendAttributionTokenToServer(_ token: String) {
        
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
                attributionData: nil,
                utmParameter: nil,
                device: StorageManager.shared.getDeviceDetails(),
                ip: Utils.getIPAddress(),
                library: StorageManager.shared.getLibraryDetails(),
                locale: "en-US",
                network: StorageManager.shared.getNetworkDetails(),
                adData: RequestData.MetaData.adData(token: "\(token)"),
                ua: "",
                requestId: StorageManager.shared.getCurrentDate(),
                requestReceivedAt: StorageManager.shared.getCurrentDate(),
                requestSentAt: StorageManager.shared.getCurrentDate(),
                timestamp: StorageManager.shared.getTimeStamp() ?? "N/A",
                eventType: "ios-ad-token",
                requestFrom: "1",
                token: retrievedData.clientToken ?? "N/A",
                clientId: retrievedData.clientId ?? 0,
                userDetails: nil
            )
        )
        

       // RestApiManager.sendRequest(jsonData: jsonData,endPoint : "/ios/token")
        

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
                click_id: "",
                install_referrer: "",
                sdk_version: retrievedData.sdkVersion ?? "0.00.00",
                referrer_click_timestamp_seconds: 0,
                install_begin_timestamp_seconds: 0,
                referrer_click_timestamp_server_seconds: 0,
                install_begin_timestamp_server_seconds: 0,
                install_version: ""
                ),
                utmParameter: RequestData.MetaData.UTMParameter(
                    utm_campaign: "",
                    utm_term: "",
                    utm_source: "",
                    utm_medium: "",
                    utm_content: ""
                ),
                device: StorageManager.shared.getDeviceDetails(),
                ip: Utils.getIPAddress(),
                library: StorageManager.shared.getLibraryDetails(),
                locale: "en-US",
                network: StorageManager.shared.getNetworkDetails(), 
                adData: nil,
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

        RestApiManager.sendRequest(jsonData: jsonData, endPoint: "")


      
    }
    public func handleDeepLink(url : URL)
    {
        print("DeepLink uRL",url)
    }
    // Function to fetch background data
   public func getBackgroundData(uri: URL?, callback: @escaping DeepLinkCallback) {
        let clientId = UserDefaults.standard.integer(forKey: "KEY_CLIENT_ID")
        let token = UserDefaults.standard.string(forKey: "KEY_CLIENT_TOKEN") ?? ""

        guard let uri = uri else {
            print("URI variable is empty")
            return
        }

        do {
            if let path = uri.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), !path.isEmpty {
                let pathVariable = path.replacingOccurrences(of: "/", with: "").trimmingCharacters(in: .whitespaces)
                if let identifier = uri.absoluteString.components(separatedBy: "=").last{
                    
                    if !identifier.isEmpty {
                        
                        fetchDeepLinkData(pathVariable: identifier, clientId: clientId, token: token, callback: callback)
                    } else {
                        print("DMD: path variable is empty")
                    }
                }
            }
        } catch {
            print("DMD: path variable is empty: \(error)")
        }
    }

    // Function to fetch deep link data
     func fetchDeepLinkData( pathVariable: String, clientId: Int, token: String, callback: @escaping DeepLinkCallback) {
        
        DispatchQueue.global().async {
            let urlData = "https://p-api.drivemetadata.com/deeplink-tracker=bympy"
            guard let url = URL(string: urlData) else {
                callback(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")

           // if clientId != 0 {
                request.setValue(String(1635), forHTTPHeaderField: "client-id")
           // }
            request.setValue("4d17d90c78154c9a5569c073b67d8a5a22b2fabfc5c9415b6e7f709d68762054", forHTTPHeaderField: "token")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    callback(.failure(error))
                    return
                }

                guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                    callback(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                    return
                }

              //  storeDeepLinkData(context: context, pathVariable: pathVariable, data: responseString)
                callback(.success(responseString))
            }

            task.resume()
        }
    }
    public func sendTags(firstName : String , lastName : String , eventType : String)
    {
       
        let retrievedData = StorageManager.shared.getClientData()
        let userDetails = RequestData.MetaData.UserDetails(first_name: firstName, last_name: lastName)

        let jsonData = RequestData(
            metaData: RequestData.MetaData(
                appDetails: nil,
                attributionData: nil,
                utmParameter:nil,
                device: nil,
                ip: Utils.getIPAddress(),
                library: nil,
                locale: "en-US",
                network: nil, adData: nil,
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

            RestApiManager.sendRequest(jsonData: jsonData, endPoint: "")

    }
    
   
   
  
}

