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
    private var workspaceId : Int

    // Singleton instance
    @objc public static var shared: DriveMetaData?

    // Private initializer to restrict instantiation
    private init(clientId: Int, clientToken: String, clientAppId: Int,workspaceId: Int) {
        // Call the superclass initializer first

        // Now it's safe to access self
        self.clientId = clientId
        self.clientToken = clientToken
        self.clientAppId = clientAppId
        self.workspaceId = workspaceId
        super.init() // This must be the first line in the initializer

        // Save client data in storage
        StorageManager.shared.saveClientData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId, workspaceId: workspaceId)
        // Check and handle first-time installation
        if !StorageManager.shared.isFirstTimeInstall() {
            // Delay of 2 seconds on a background thread
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                self.firstInstall()
                DMDLogger.shared.log("SDK initialized", level: .info)
               
            }
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DriveMetaData.shared?.requestIDFA()
           }
    }


    // Public method to initialize the singleton with required parameters
    @objc public static func initializeShared(clientId: Int, clientToken: String, clientAppId: Int,workspaceId: Int) {
        shared = DriveMetaData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId,workspaceId:workspaceId)
    }


    // Public method to set or configure the singleton instance's properties
    @objc public func configure(clientId: Int, clientToken: String, clientAppId: Int) {
        self.clientId = clientId
        self.clientToken = clientToken
        self.clientAppId = clientAppId
        StorageManager.shared.saveClientData(clientId: clientId, clientToken: clientToken, clientAppId: clientAppId,workspaceId: workspaceId)
    }
    
   
    @objc public func sendTags(tags: [String: Any], eventType: String, completion: @escaping (String) -> Void) {
        if(tags.isEmpty || eventType.isEmpty){
            ExceptionLogger.shared.sendException(message: "sendTags",stacktrace: "tags  \(tags)  or events type \( eventType) is empty")
            }
        else{
            MetadataBuilder.sendEvent(
                eventType: eventType,
                tags: tags,
                includeExtraDetails: true,
                onSuccess: { response in
                    completion(response)
                    
                },
                onFailure: { error in
                    completion(error.debugDescription)
                    ExceptionLogger.shared.sendException(message: "sendTags",stacktrace: error.debugDescription)
                    
                    
                }
            )
        }

    }

    @objc public  func generateToken()
    {
        // self.updateConversionValuesData()
        // self.updateConversionValue(conversionValue: "45")
        let adClient = DMDHTTPAdClient()
        adClient.requestAttributionDetails { tags, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                ExceptionLogger.shared.sendException(message: "generateToken",stacktrace: " Error: \(error.localizedDescription)")
                return
            }
            if var tags = tags {
                DriveMetaData.shared?.sendTags(tags: tags, eventType: "attribution") { response in
                    print("✅ Received response: \(response)")
                }
                
            }
            
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
                     // self.generateToken()
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
    @objc func updateConversionValue(conversionValue: String) {
        // Convert to Int and validate range
            guard let newValue = Int(conversionValue), (0...63).contains(newValue) else {
                print("Invalid conversion value: must be between 0 and 63")
                ExceptionLogger.shared.sendException(message: "requestAttributionDetails",stacktrace: "Invalid conversion value: must be between 0 and 63\(conversionValue)")

                return
            }

            // Retrieve stored value
            let storedValue = UserDefaults.standard.integer(forKey: "stored_conversion_value")

            // Check if newValue is greater than stored value
            guard newValue > storedValue else {
                print("New value (\(newValue)) is not greater than stored value (\(storedValue)). Skipping update.")
                ExceptionLogger.shared.sendException(message: "updateConversionValue",stacktrace: "New value (\(newValue)) is not greater than stored value (\(storedValue)). Skipping update.")
                return
            }

            // Save the new higher value
            UserDefaults.standard.set(newValue, forKey: "stored_conversion_value")

            // Send API request
            ConversionAPIManager.shared.sendConversionRequest(includeValue: true, value: "\(newValue)") { _ in
                self.getConversionVlaues()
            }
    }

    func getConversionVlaues() {
        ConversionAPIManager.shared.sendConversionRequest(includeValue: false) { response in
            print("Finished fetching conversion values")
        }
    }



  
    

    
    func firstInstall() {
            DeviceInfoManager.shared.requestAdTrackingPermission { idfa, isTrackingEnabled in
                print("IDFA: \(idfa ?? "Not Available")")
                print("Ad Tracking Enabled: \(isTrackingEnabled)")

                MetadataBuilder.sendEvent(
                    eventType: DMDConstants.DMD_REQUEST_INSTALL_NAME,
                    includeExtraDetails: true,
                    onSuccess: { response in
                        StorageManager.shared.setFirstTimeInstall(true)
                        print("Install Event Success: \(response)")
                    },
                    onFailure: { error in
                        print("Install Event Error: \(error)")
                        ExceptionLogger.shared.sendException(message: "firstInstall",stacktrace: "Install Event Error: \(error)")
                    }
                )
            }
        }
        
        


  
  
  // gettting the devcie details
  @objc public func deviceDetails() -> String {
      
      let deviceDetails = DeviceInfoManager.shared.getDeviceDetails()
      if let jsonData = try? JSONSerialization.data(withJSONObject: deviceDetails, options: []),
         let jsonString = String(data: jsonData, encoding: .utf8) {
           return jsonString
      }
      
      return "" // Return empty JSON if encoding fails
  }
  
  
  
  // getting the app details
  @objc public func appDetails() -> String {
      let appData = AppInfoManager.shared.getAppDetails()
      
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
                        ExceptionLogger.shared.sendException(message: "fetchDeepLinkData",stacktrace: "DeepLink Event Error: \(url)")

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
extension DMDAttributionDataa {
    var asDictionary: [String: Any] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self)
            let dict = try JSONSerialization.jsonObject(with: data, options: [])
            return dict as? [String: Any] ?? [:]
        } catch {
            print("❗️Failed to convert DMDAttributionDataa to dictionary: \(error)")
            return [:]
        }
    }
}

