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
    public static func sendRequest(jsonData: RequestData) {
            guard let url = URL(string: "https://sdk.drivemetadata.com/data-collector") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
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
                    if(!StorageManager.shared.getInstallFirstTime()){
                        StorageManager.shared.isInstallFirstTime(isFirstTime: true)
                    }
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                }
            }
            
            task.resume()
        }
    }


