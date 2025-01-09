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
   
    @objc public func sendTags(userDetails: [String: Any], eventType: String) -> String {
        // Step 1: Retrieve the stored data from StorageManager
        let retrievedData = StorageManager.shared.getClientData()

        // Step 2: Try to convert the userDetails dictionary to a UserDetails object, making fields optional
        let userDetailsObject: RequestData.MetaData.UserDetails? = {
            // Extract values from the dictionary, making each field optional
            let firstName = userDetails["first_name"] as? String
            let lastName = userDetails["last_name"] as? String
            let middleName = userDetails["middle_name"] as? String
            let mobileNumber = userDetails["mobile_number"] as? String
            
            // Return a UserDetails object with the fields (some of them can be nil)
            return RequestData.MetaData.UserDetails(first_name: firstName,
                                                    last_name: lastName,
                                                    middile_name: middleName,
                                                    mobile_number: mobileNumber)
        }()
        
        // If the userDetailsObject is nil (if essential data is missing), return an error message
        guard let userDetailsObject = userDetailsObject else {
            print("Error: Missing essential user details")
            return "Error: Missing essential user details"
        }

        // Step 3: Build the RequestData with the userDetailsObject
        let jsonData = RequestData(
            metaData: RequestData.MetaData(
                appDetails: nil,
                device: nil,
                ip: Utils.getIPAddress(),
                library: nil,
                locale: Locale.current.identifier,
                adData: nil,
                ua: StorageManager.shared.getCurrentDate(),
                requestId: StorageManager.shared.getCurrentDate(),
                requestReceivedAt: StorageManager.shared.getCurrentDate(),
                requestSentAt: StorageManager.shared.getCurrentDate(),
                timestamp: StorageManager.shared.getTimeStamp() ?? "N/A",
                eventType: eventType,
                requestFrom: "1",
                token: retrievedData.clientToken ?? "N/A", // Fallback to "N/A" if nil
                clientId: retrievedData.clientId ?? 0,    // Fallback to 0 if nil
                userDetails: userDetailsObject            // Pass the UserDetails object
            )
        )
        
        // Step 4: Send the request and return the response
        return RestApiManager.sendRequest(jsonData: jsonData, endPoint: "")
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
                device: StorageManager.shared.getDeviceDetails(),
                ip: Utils.getIPAddress(),
                library: StorageManager.shared.getLibraryDetails(),
                locale: Locale.current.identifier,
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
        

      let response =  RestApiManager.sendRequest(jsonData: jsonData,endPoint : "/ios/token")
      print("Response",response)


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
               
               
                device: StorageManager.shared.getDeviceDetails(),
                ip: Utils.getIPAddress(),
                library: StorageManager.shared.getLibraryDetails(),
                locale: Locale.current.identifier,
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

      let response =  RestApiManager.sendRequest(jsonData: jsonData, endPoint: "")
      print(response)

      
    }
  
  
  // gettting the devcie details
  @objc public func deviceDetails() -> String {
      
  let deviceDetails =  StorageManager.shared.getDeviceDetails()
      
      // Assuming you want to serialize appDetails as a JSON string
      if let jsonData = try? JSONEncoder().encode(deviceDetails),
         let jsonString = String(data: jsonData, encoding: .utf8) {
          return jsonString
      }
      
      return "{}" // Return empty JSON if encoding fails
  }
  
  
  
  // getting the app details
  @objc public func appDetails() -> String {
      let retrievedData = StorageManager.shared.getClientData()
      
      let appDetails = RequestData.MetaData.AppDetails(
          app_id: retrievedData.clientAppId ?? 0,
          bundle: retrievedData.bundleIdentifier ?? "N/A",
          name: retrievedData.appName ?? "N/A",
          version: retrievedData.appVersion ?? "N/A",
          build: retrievedData.appBuild ?? "N/A"
      )
      
      // Assuming you want to serialize appDetails as a JSON string
      if let jsonData = try? JSONEncoder().encode(appDetails),
         let jsonString = String(data: jsonData, encoding: .utf8) {
          return jsonString
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

