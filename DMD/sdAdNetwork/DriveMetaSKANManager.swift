//
//  DriveMetaSKANManager.swift
//  Pods
//
//  Created by DriveMetaData on 20/04/25.
//

import Foundation
import StoreKit

class DriveMetaSKANManager {

    static let shared = DriveMetaSKANManager()

    // MARK: - Constants (UserDefaults Keys)
    private let installTimeKey = "skan_install_time"
    private let fineValueKey = "skan_fine_value"
    private let coarseValueKey = "skan_coarse_value"
    private let hasInitializedKey = "skan_initialized"
    private let conversionMappingKey = "skan_conversion_mapping"

    private var conversionMappings: [String: Any] = [:]
    private var revenueTotal: Double = 0.0

    private init() {}

    // MARK: - Public Methods

    /// Initializes the SDK and registers for SKAdNetwork attribution.
    /// Also fetches conversion mappings, limited to 1 API call per 24 hours and only for 35 days post-install.
    func initializeSDK() {
        let defaults = UserDefaults.standard
        let now = Date()

        // First time setup: register for SKAdNetwork and store install time and default values
        if !defaults.bool(forKey: hasInitializedKey) {
            if #available(iOS 14.0, *) {
                SKAdNetwork.registerAppForAdNetworkAttribution()
                SKAdNetwork.updateConversionValue(0)
                print("Successfully registered with SKAdNetwork with 0")
            }

            defaults.set(now, forKey: installTimeKey)
            defaults.set(0, forKey: fineValueKey)
            defaults.set("low", forKey: coarseValueKey)
            defaults.set(true, forKey: hasInitializedKey)
         
        }
        
    }
    
    
    func checkConversionApi()
    {
        let defaults = UserDefaults.standard
        let now = Date()
     //   fetchConversionConfig()

        if shouldCallAPI(now: now, defaults: defaults) {
            fetchConversionConfig()
            defaults.set(now, forKey: "lastApiCallKey") // Store last API call time
        } else {
            print("API call skipped due to 24-hour or 35-day rule")
        }
    }
    
    
    
    

    /// Checks whether the conversion config API can be called (once every 24 hours, for up to 35 days after install)
    func shouldCallAPI(now: Date, defaults: UserDefaults) -> Bool {
        // Check if 35 days have passed since install
        if let installDate = defaults.object(forKey: installTimeKey) as? Date {
            if Calendar.current.dateComponents([.day], from: installDate, to: now).day ?? 0 > 35 {
                return false
            }
        } else {
            // If no install date, set now to avoid nil issues
            defaults.set(now, forKey: installTimeKey)
        }

        // Check if last API call was within 24 hours
        if let lastApiCall = defaults.object(forKey: "lastApiCallKey") as? Date {
            if Calendar.current.dateComponents([.hour], from: lastApiCall, to: now).hour ?? 0 < 24 {
                return false
            }
        }

        return true
    }

    /// Tracks an in-app event with optional revenue, updates conversion value if eligible
    func trackEvent(eventName: String, revenue: Double) {
        let timestamp = Date()
        let window = getCurrentWindow()
        print(window)
        let result = matchEventToMapping(name: eventName, revenue: revenue)
        if let result = result {
            print("🎯 fineValue: \(result.fineValue), coarseValue: \(result.coarseValue), lockWindow: \(result.lockWindow)")
            let currentFine = UserDefaults.standard.integer(forKey: fineValueKey)
            updateConversionValue(eventName:eventName,fine: result.fineValue, coarse: result.coarseValue, lock: true)

            // Safely unwrap and compare if the new fine value is greater than current fine value
            if result.fineValue > currentFine {
                
                updateConversionValue(eventName:eventName,fine: result.fineValue, coarse: result.coarseValue, lock: true)
            }

        } else {
            print("❌ No matching conversion mapping found.")
        }

       
    }

    /// Returns current conversion window (1 to 3), based on days since install
    func getCurrentWindow() -> Int {
        guard let installTime = UserDefaults.standard.object(forKey: installTimeKey) as? Date else { return 1 }
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: installTime, to: Date()).day ?? 0

        if daysSinceInstall <= 2 {
            return 1
        } else if daysSinceInstall <= 7 {
            return 2
        } else if daysSinceInstall <= 35 {
            return 3
        }
        return 0 // Beyond valid conversion window
    }
    
    // if not saving the

    // MARK: - Private Methods

    /// Fetches the conversion mapping configuration from server
    private func fetchConversionConfig() {
        

        guard let url = URL(string: APIConfig.shared.baseURL+EndPointConfig.shared.conversionValueMappingApi) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let retrievedData = StorageManager.shared.getClientData()
        
        
        if let clientId = retrievedData.clientId,
        let workspaceId = retrievedData.workspaceId,
        let clientAppId = retrievedData.clientAppId,
        let clientToken = retrievedData.clientToken {
        request.addValue(String(clientId), forHTTPHeaderField: DMDConstants.CLIENT_ID)
        request.addValue(String(workspaceId), forHTTPHeaderField: DMDConstants.WORKSPACE_ID)
        request.addValue(String(clientAppId), forHTTPHeaderField: DMDConstants.APP_ID)
        request.addValue(clientToken, forHTTPHeaderField: DMDConstants.TOKEN)
        } else {
        debugPrint("❌ Missing required header value(s) in retrievedData")
        }
        


        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                self.loadCachedConfig()
                return
            }

            do {
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    self.conversionMappings = json
                    print(self.conversionMappings)
                    
                    //store
                    
                    UserDefaults.standard.setValue(json, forKey: self.conversionMappingKey)
                    
                    
                    //get
                  
                    
                } else {
                    self.loadCachedConfig()
                }
            } catch {
                
                print("JSON decoding error: \(error)")
                self.loadCachedConfig()
            }
        }
        task.resume()
    }

    /// Loads conversion config from cache (UserDefaults) if API fails
    private func loadCachedConfig() {
        if let cached = UserDefaults.standard.dictionary(forKey: conversionMappingKey) {
            conversionMappings = cached
        }
    }

    /// Matches the event (and optionally revenue) to a config mapping
    private func matchEventToMapping(name: String, revenue: Double) -> ConversionMappingResult? {
        // Retrieve stored conversion mappings
        if let savedValue = UserDefaults.standard.value(forKey: conversionMappingKey) as? [String: Any] {

            // If revenue is 0.0, set it to nil
            let revenueToPass: Double? = (revenue == 0.0) ? nil : revenue
            
            // Call the conversion mapping function with revenue set to nil if it was 0.0
            let result = getConversionMapping(from: savedValue, eventType: name, revenue: revenueToPass)
            
            if let result = result {
                print("🎯 fineValue: \(result.fineValue), coarseValue: \(result.coarseValue), lockWindow: \(result.lockWindow)")
                return ConversionMappingResult(fineValue: result.fineValue, coarseValue: result.coarseValue, lockWindow: result.lockWindow)
            } else {
                print("❌ No matching conversion mapping found.")
                return nil
            }
        } else {
            print("⚠️ No stored mapping found for key: \(conversionMappingKey)")
            return nil
        }
    }
    
    struct ConversionMappingResult {
        let fineValue: Int
        let coarseValue: String
        let lockWindow: Bool
    }

    func getConversionMapping(from json: [String: Any], eventType: String, revenue: Double?) -> ConversionMappingResult? {
        guard
            let data = json["data"] as? [String: Any],
            let mappings = data["mappings"] as? [[String: Any]]
        else {
            return nil
        }
   
        

        for mapping in mappings {
            guard let type = mapping["eventType"] as? String, type == eventType else { continue }
            if eventType == type, let revenue = revenue{
                if let ranges = mapping["revenueRanges"] as? [[String: Any]] {
                    for range in ranges {
                        let minStr = range["min"] as? String ?? "\(range["min"] ?? "0")"
                        let maxStr = range["max"] as? String ?? "\(range["max"] ?? "0")"
                        let min = Double(minStr) ?? 0
                        let max = Double(maxStr) ?? 0
                        let isMaxZero = max == 0

                        if revenue >= min && (revenue <= max || isMaxZero) {
                            let fineValue = (range["fineValue"] as? NSNumber)?.intValue ?? 0
                            let coarseValue = range["coarseValue"] as? String ?? ""
                            let lockWindow = (range["lockWindow"] as? NSNumber)?.boolValue ?? false
                            return ConversionMappingResult(fineValue: fineValue, coarseValue: coarseValue, lockWindow: lockWindow)
                        }
                    }
                }
            }

            if revenue == nil {
                let fineValue = (mapping["fineValue"] as? NSNumber)?.intValue ?? 0
                let coarseValue = mapping["coarseValue"] as? String ?? ""
                let lockWindow = (mapping["lockWindow"] as? NSNumber)?.boolValue ?? false
                return ConversionMappingResult(fineValue: fineValue, coarseValue: coarseValue, lockWindow: lockWindow)
            }
        }

        return nil
    }
    /// Updates the SKAdNetwork conversion value (fine/coarse/lock)
    private func updateConversionValue(eventName : String,fine: Int, coarse: String, lock: Bool) {
        let now = Date()
        let defaults = UserDefaults.standard
        
        // Retrieve install date from UserDefaults
        guard let installDate = defaults.object(forKey: "lastConversionTimes") as? Date else {
            print("Install date is missing.")
            return
        }
        
        
        
        // Calculate the number of days since installation
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: now).day ?? 0
        
        print(daysSinceInstall)

        // Determine the window state based on days since installation
        switch daysSinceInstall {
        case 0...2: // Window 1: First 48 hours
            // Update both fine and coarse value
            if #available(iOS 16.1, *) {
                let coarseEnum: SKAdNetwork.CoarseConversionValue = SKAdNetwork.CoarseConversionValue(rawValue: coarse.capitalized) ?? .low
                //  SKAdNetwork.updatePostbackConversionValue(fine, coarseValue: coarseEnum, lockWindow: lock)
                SKAdNetwork.updatePostbackConversionValue(fine, coarseValue: coarseEnum) { error in
                    if let error = error {
                        // Handle the error
                        print("Error updating conversion value: \(error.localizedDescription)")
                    } else {
                        // Successfully updated the conversion value
                        print("Successfully updated conversion value to \(fine) with coarse value: \(coarseEnum)")
                    }
                }
            }
            
        case 3...7: // Window 2: 3-7 days
            // Update only coarse value
            if #available(iOS 16.1, *) {
                let coarseEnum: SKAdNetwork.CoarseConversionValue = SKAdNetwork.CoarseConversionValue(rawValue: coarse.capitalized) ?? .low
              //  SKAdNetwork.updatePostbackConversionValue(fine, coarseValue: coarseEnum, lockWindow: lock)
                SKAdNetwork.updatePostbackConversionValue(fine, coarseValue: coarseEnum) { error in
                      if let error = error {
                          // Handle the error
                          print("Error updating conversion value: \(error.localizedDescription)")
                      } else {
                          // Successfully updated the conversion value
                          print("Successfully updated conversion value to \(fine) with coarse value: \(coarseEnum)")
                      }
                  }
                
                
                
                
                
                
            } else if #available(iOS 14.0, *) {
                SKAdNetwork.updateConversionValue(fine)
            }
            print("Window 2: 3-7 days - Updated coarse value only")
            
        case 8...35: // Window 3: 8-35 days
            // Update only coarse value
            if #available(iOS 16.1, *) {
                let coarseEnum: SKAdNetwork.CoarseConversionValue = SKAdNetwork.CoarseConversionValue(rawValue: coarse.capitalized) ?? .low
                SKAdNetwork.updatePostbackConversionValue(fine, coarseValue: coarseEnum, lockWindow: lock)
            } else if #available(iOS 14.0, *) {
                SKAdNetwork.updateConversionValue(fine)
            }
            print("Window 3: 8-35 days - Updated coarse value only")
            
        default:
            // Beyond valid window
            print("No valid window for conversion value update.")
            return
        }

        // Persist updated values
        defaults.set(fine, forKey: fineValueKey) // Persist the fine value
        defaults.set(now, forKey: "lastConversionTimes") // Store the timestamp of this conversion value update
        defaults.set(lock, forKey: "lockStatus")
        defaults.set(coarse.lowercased(), forKey: coarseValueKey) // Persist the coarse value
        sendEventToBackend(name: eventName, timestamp: now, fineValue: fine , coarseValue: coarse, window: getCurrentWindow())

    }


    /// Sends the event payload to your backend
    private func sendEventToBackend(name: String, timestamp: Date, fineValue: Int, coarseValue: String, window: Int) {

        guard let url = URL(string: APIConfig.shared.baseURL+EndPointConfig.shared.updateConversionApi+DeviceInfoManager.shared.getAnonymousId()+"?value=\(fineValue)") else {
            print("Invalid URL")
            return
        }
        print(url)

        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // or "POST" if needed
        let retrievedData = StorageManager.shared.getClientData()
        if let clientId = retrievedData.clientId,
        let workspaceId = retrievedData.workspaceId,
        let clientAppId = retrievedData.clientAppId,
        let clientToken = retrievedData.clientToken {
        request.addValue(String(clientId), forHTTPHeaderField: DMDConstants.CLIENT_ID)
        request.addValue(String(workspaceId), forHTTPHeaderField: DMDConstants.WORKSPACE_ID)
        request.addValue(String(clientAppId), forHTTPHeaderField: DMDConstants.APP_ID)
        request.addValue(clientToken, forHTTPHeaderField: DMDConstants.TOKEN)
        } else {
        debugPrint("❌ Missing required header value(s) in retrievedData")
        }
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error:", error)
                return
            }
            
            
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            print("Status code:", httpResponse.statusCode)

            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data:\n", jsonString)
                }
            }
        }

        task.resume()
        
    }
}

