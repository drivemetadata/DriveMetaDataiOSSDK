//
//  RestApiManager.swift
//  DriveMetaDataiOSSDK
//
//  Created by DriveMetaData on 22/06/24.
//

import Foundation

class RestApiManager

{
    static let shared = RestApiManager()
    private init() {}
    public static func sendRequest(jsonData: RequestData,endPoint: String) {
           
            guard let url = URL(string: "https://sdk-dev.drivemetadata.com/data-collector"+endPoint) else { return }
            
        
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print(jsonData)
            do {
                let data = try JSONEncoder().encode(jsonData)
                request.httpBody = data
            } catch {
                print("Error encoding JSON: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("Response code: \(response.statusCode)")
                }

                if let data = data {
                    do {
                        // Parse JSON data
                        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let success = jsonObject["success"] as? Bool,
                           let eventCode = jsonObject["eventCode"] as? Int {
                            
                            // Check if success is false and eventCode is 403
                            if !success {
                                print("Response data: \(String(data: data, encoding: .utf8) ?? "")")

                                print("Unauthorized access: eventCode is 403, success is false")
                            } else {
                                if(!StorageManager.shared.getInstallFirstTime()){
                                                      StorageManager.shared.isInstallFirstTime(isFirstTime: true)
                                                 
                                }
                                print("Response data: \(String(data: data, encoding: .utf8) ?? "")")

                            }
                        } else {
                            print("Failed to retrieve necessary data from JSON.")
                        }
                    } catch {
                        print("Failed to parse JSON data: \(error)")
                    }
                } else {
                    print("No data received")
                }
            }
            
            task.resume()
        }
    }


