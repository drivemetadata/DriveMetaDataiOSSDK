//
//  RestApiManager.swift
//  DriveMetaDataiOSSDK
//
//  Created by DriveMetaData on 22/06/24.
//

import Foundation

class RestApiManager {
    
    private init() {} // Prevent instantiation
    
    static let shared = RestApiManager() // Singleton instance
    
    public func sendRequest(jsonData: [String: Any], endPoint: String, completion: @escaping (Result<String, Error>) -> Void) {
        let baseURL = "https://sdk.drivemetadata.com/data-collector"

        
//        // Determine base URL
//#if DEBUG
//        let baseURL = "https://sdk-dev.drivemetadata.com/data-collector"
//#else
//        let baseURL = "https://sdk.drivemetadata.com/data-collector"
//#endif
        
        guard let url = URL(string: baseURL + endPoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Convert dictionary to JSON
        do {
            let jsonDataEncoded = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
            request.httpBody = jsonDataEncoded
            
            if let jsonString = String(data: jsonDataEncoded, encoding: .utf8) {
               // print("📄 Request Body: \(jsonString)")
            }
            
        } catch {
            completion(.failure(error))
            return
        }
        
        // Send request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Handle network error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "No HTTP Response", code: 500, userInfo: nil)))
                return
            }
            
            // Log Response Code
           // print("📩 Response Code: \(httpResponse.statusCode)")
            
            // Handle Non-200 Responses
            if !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            // Handle Response Data
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data Received", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    
                    if let success = jsonObject["success"] as? Bool, success {
                        if !StorageManager.shared.getInstallFirstTime() {
                            StorageManager.shared.isInstallFirstTime(isFirstTime: true)
                        }
                        completion(.success("✅ Success: \(jsonObject)"))
                    } else {
                        completion(.failure(NSError(domain: "Request Failed", code: httpResponse.statusCode, userInfo: jsonObject)))
                    }
                    
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON Format", code: httpResponse.statusCode, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

 

