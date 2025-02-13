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
import AppTrackingTransparency


// Define your callback type
@objc public class DriveMetaData: NSObject {
    private var clientId: Int
    private var clientToken: String
    private var clientAppId: Int

    // Singleton instance
    @objc public static var shared: DriveMetaData?

    // Private initializer to restrict instantiation
    private init(clientId: Int, clientToken: String, clientAppId: Int) {
        // Call the superclass initializer first

        // Now it's safe to access self
        self.clientId = clientId
        self.clientToken = clientToken
        self.clientAppId = clientAppId
        super.init() // This must be the first line in the initializer

        // Save client data in storage
        StorageManager.shared.saveClientData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId)

        // Check and handle first-time installation
        if !StorageManager.shared.getInstallFirstTime() {
            // Delay of 2 seconds on a background thread
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                self.firstInstall()
            }
        }
    }


    // Public method to initialize the singleton with required parameters
    @objc public static func initializeShared(clientId: Int, clientToken: String, clientAppId: Int) {
        shared = DriveMetaData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId)
    }


    // Public method to set or configure the singleton instance's properties
    @objc public func configure(clientId: Int, clientToken: String, clientAppId: Int) {
        self.clientId = clientId
        self.clientToken = clientToken
        self.clientAppId = clientAppId
        
        StorageManager.shared.saveClientData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId)
    }
   
    @objc public func sendTags(tags: [String: Any], eventType: String, completion: @escaping (String) -> Void) {
        // Step 1: Retrieve stored data from StorageManager
        let retrievedData = StorageManager.shared.getClientData()

        var metadata: [String: Any] = [
            DMDConstants.DMD_UA: "",
            DMDConstants.DMD_REQUEST_ID: UUID().uuidString,
            DMDConstants.DMD_REQUEST_RECEIVED: StorageManager.shared.getCurrentDate() ?? "",
            DMDConstants.DMD_REQUEST_SENT: StorageManager.shared.getCurrentDate() ?? "",
            DMDConstants.DMD_TIMESTAMP: StorageManager.shared.getCurrentDate() ?? "",
            DMDConstants.DMD_EVENT_TYPE: eventType,
            DMDConstants.DMD_REQUEST_FORM: "1",
            DMDConstants.DMD_TOKEN: retrievedData.clientToken ?? "",
            DMDConstants.DMD_CLIENT_ID: retrievedData.clientId ?? 0,
            DMDConstants.DMD_LOCALE: Locale.current.identifier,
            DMDConstants.DMD_IP: Utils.getIPAddress() ?? "0.0.0.0"
        ]

        // Merge tags safely
        metadata.merge(tags) { (_, new) in new }

        let mainObject: [String: Any] = [
            DMDConstants.DMD_META: metadata
        ]

        do {
            // Step 2: Ensure JSON Serialization is crash-free
            let jsonData = try JSONSerialization.data(withJSONObject: mainObject, options: [])

            // Step 3: Send API request asynchronously
            RestApiManager.shared.sendRequest(jsonData: mainObject, endPoint: "") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let responseString):
                        completion(responseString)  // Pass response via completion handler
                    case .failure(let error):
                        completion(error.localizedDescription)  // Return error description
                    }
                }
            }
        } catch {
            completion(error.localizedDescription)  // Handle JSON conversion error
        }
    }



  
  
    @objc public  func generateToken()
    {
        if #available(iOS 14.3, *) {
            if let token = try? AAAttribution.attributionToken() {
               // sendAttributionTokenToServer(token)
            }
        } else {
            print("Attribution token generation is not available on this device.")
        }
    }
  @objc public func requestIDFA() -> String {
      var result = ""
      

      // Check if the device supports AppTrackingTransparency (iOS 14+)
      if #available(iOS 14, *) {
          // Request permission to track
          ATTrackingManager.requestTrackingAuthorization { status in
              DispatchQueue.main.async {
                  switch status {
                  case .authorized:
                      // Access IDFA directly since uuidString is not optional
                      let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                      print("IDFA: \(idfa)")
                      result = idfa
                      if !UserDefaults.standard.bool(forKey: "received") {
                          // Store the IDFA in UserDefaults
                          UserDefaults.standard.set(idfa, forKey: "idfa")

                          // Set the ad status to true
                          UserDefaults.standard.set(true, forKey: "adstatus")

                          // Call a function to handle first install logic
                          self.firstInstall()

                          // Mark as received to prevent this block from running again
                          UserDefaults.standard.set(true, forKey: "received")
                      }

                  case .denied:
                      print("Tracking authorization was denied.")
                      UserDefaults.standard.set(false, forKey: "adstatus")
                      result = "Tracking authorization was denied."

                  case .restricted:
                      print("Tracking authorization is restricted.")
                      UserDefaults.standard.set(false, forKey: "adstatus")
                      result = "Tracking authorization is restricted."

                  case .notDetermined:
                      print("Tracking authorization has not been determined.")
                      UserDefaults.standard.set(false, forKey: "adstatus")
                      result = "Tracking authorization has not been determined."

                  @unknown default:
                      print("Unknown tracking authorization status.")
                      UserDefaults.standard.set(false, forKey: "adstatus")
                      result = "Unknown tracking authorization status."
                  }
              }
          }
      } else {
          // For iOS versions below 14, directly access IDFA
          if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
              let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
              print("IDFA: \(idfa)")
              UserDefaults.standard.set(idfa, forKey: "idfa")
              UserDefaults.standard.set(true, forKey: "adstatus")
              result = idfa
          } else {
              print("Tracking is restricted.")
              UserDefaults.standard.set(false, forKey: "adstatus")
              result = "Tracking is restricted."
          }
      }

      return result
  }

    
    @objc func sendAttributionTokenToServer(_ token: String) {
        
       
       

     // let response =  RestApiManager.sendRequest(jsonData: jsonData,endPoint : "/ios/token")
     // print("Response",response)


    }
    

    
    func firstInstall() {
        let retrievedData = StorageManager.shared.getClientData()
        
        var metadata: [String: Any] = [
            DMDConstants.DMD_UA: "",
            DMDConstants.DMD_REQUEST_ID: UUID().uuidString,  // Generate unique requestId dynamically
            DMDConstants.DMD_REQUEST_RECEIVED: StorageManager.shared.getCurrentDate() ?? "",
            DMDConstants.DMD_REQUEST_SENT: StorageManager.shared.getCurrentDate() ?? "",
            DMDConstants.DMD_TIMESTAMP: StorageManager.shared.getCurrentDate() ?? "",
            DMDConstants.DMD_EVENT_TYPE: "install",
            DMDConstants.DMD_REQUEST_FORM: "1",
            DMDConstants.DMD_TOKEN: retrievedData.clientToken ?? "",
            DMDConstants.DMD_CLIENT_ID: retrievedData.clientId ?? 0,
            DMDConstants.DMD_LOCALE: Locale.current.identifier,
            DMDConstants.DMD_IP: Utils.getIPAddress() ?? "0.0.0.0"
        ]

        // Add additional metadata safely
        metadata[DMDConstants.DMD_APP_DETAILS] = StorageManager.shared.getAppDetails() ?? [:]
        metadata[DMDConstants.DMD_DEVICE_DETAILS] = StorageManager.shared.getDeviceDetails() ?? [:]
        metadata[DMDConstants.DMD_LIBRARY_DETAILS] = StorageManager.shared.getLibraryDetails() ?? [:]

        // Construct the final payload
        let mainObject: [String: Any] = [DMDConstants.DMD_META: metadata]

        do {
            // Convert dictionary to JSON safely
            let jsonData = try JSONSerialization.data(withJSONObject: mainObject, options: [])
            
            // Send API request
            RestApiManager.shared.sendRequest(jsonData: mainObject, endPoint: "") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let responseString):
                        print("✅ API Response: \(responseString)")
                    case .failure(let error):
                        print("❌ API Error: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print("❌ JSON Serialization Error: \(error.localizedDescription)")
        }
    }

  
  
  // gettting the devcie details
  @objc public func deviceDetails() -> String {
      
      let deviceDetails =  StorageManager.shared.getDeviceDetails()
      if let jsonData = try? JSONSerialization.data(withJSONObject: deviceDetails, options: []),
         let jsonString = String(data: jsonData, encoding: .utf8) {
           return jsonString
      }
      
      return "" // Return empty JSON if encoding fails
  }
  
  
  
  // getting the app details
  @objc public func appDetails() -> String {
      let appData = StorageManager.shared.getAppDetails()
      
      // Assuming you want to serialize appDetails as a JSON string
      if let jsonData = try? JSONSerialization.data(withJSONObject: appData, options: []),
         let jsonString = String(data: jsonData, encoding: .utf8) {
           return "\(jsonString)"
      }
      
      return "{}" // Return empty JSON if encoding fails
  }

    @objc  public func handleDeepLink(url : URL)
    {
        print("DeepLink uRL",url)
    }
    // Function to fetch background data
    @objc public func getBackgroundData(uri: URL?, callback: @escaping (String?, Error?) -> Void) {
        guard let uri = uri else {
            callback(nil, NSError(domain: "Invalid URI", code: 1, userInfo: [NSLocalizedDescriptionKey: "URI is nil"]))
            return
        }

        let clientId = StorageManager.shared.getClientData().clientId ?? 0
        let token = StorageManager.shared.getClientData().clientToken ?? ""
        // Safely encode the path component of the URI
        guard let encodedPath = uri.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              !encodedPath.isEmpty else {
            callback(nil, NSError(domain: "Invalid Path", code: 2, userInfo: [NSLocalizedDescriptionKey: "Path encoding failed or is empty"]))
            return
        }

        let pathVariable = encodedPath.replacingOccurrences(of: "/", with: "").trimmingCharacters(in: .whitespaces)

        guard let identifier = uri.absoluteString.components(separatedBy: "=").last, !identifier.isEmpty else {
            callback(nil, NSError(domain: "Invalid Identifier", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not extract identifier from URL"]))
            return
        }

        fetchDeepLinkData(pathVariable: pathVariable, clientId: clientId, token: token, callback: callback)
    }

    // Function to fetch deep link data
     func fetchDeepLinkData(pathVariable: String, clientId: Int, token: String, callback: @escaping (String?, Error?) -> Void) {
         
        // Ensure that the fetch happens on a background thread to prevent blocking UI
        DispatchQueue.global(qos: .background).async {
            let urlString = "https://p-api.drivemetadata.com/deeplink-tracker=\(pathVariable)"
            guard let url = URL(string: urlString) else {
                let error = NSError(domain: "Invalid URL", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL from the string"])
                DispatchQueue.main.async {
                    callback(nil, error)
                }
                return
            }
            print(urlString)

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            // Include client ID and token in headers if they are valid
            if clientId != 0 {
                request.setValue(String(clientId), forHTTPHeaderField: "client-id")
            }
            request.setValue(token, forHTTPHeaderField: "token")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        callback(nil, error)
                    }
                    return
                }

                guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                    let error = NSError(domain: "No Data", code: 5, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])
                    DispatchQueue.main.async {
                        callback(nil, error)
                    }
                    return
                }

                DispatchQueue.main.async {
                    callback(responseString, nil)
                }
            }

            task.resume()
        }
    }

   
   
  
}

