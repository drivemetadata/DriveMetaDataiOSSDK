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
   public static func sendRequest(jsonData: RequestData, endPoint: String) -> String {
     
     var responseString = ""
     
      #if DEBUG
          let baseURL = "https://sdk-dev.drivemetadata.com/data-collector"
      #else
         let baseURL = "https://sdk-prod.drivemetadata.com/data-collector"
      #endif

    guard let url = URL(string: baseURL + endPoint) else {
          return "Invalid URL"
         }

     
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     
     do {
       let data = try JSONEncoder().encode(jsonData)
       request.httpBody = data
     } catch {
       print("Error encoding JSON: \(error)")
       return "Error encoding JSON: \(error)"
     }
     
     let semaphore = DispatchSemaphore(value: 0)
     
     let task = URLSession.shared.dataTask(with: request) { data, response, error in
       if let error = error {
         print("Error: \(error)")
         responseString = "Error: \(error)"
         semaphore.signal()
         return
       }
       
       if let response = response as? HTTPURLResponse {
         print("Response code: \(response.statusCode)")
         responseString += "Response code: \(response.statusCode)\n"
       }
       
       if let data = data {
         do {
           if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let success = jsonObject["success"] as? Bool,
              let eventCode = jsonObject["eventCode"] as? Int {
             
             if !success {
               responseString += "Failure: \(String(data: data, encoding: .utf8) ?? "")\n"
               print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
             } else {
               if !StorageManager.shared.getInstallFirstTime() {
                 StorageManager.shared.isInstallFirstTime(isFirstTime: true)
               }
               responseString += "Success: \(String(data: data, encoding: .utf8) ?? "")\n"
               print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
             }
           } else {
             responseString += "Failed to retrieve necessary data from JSON.\n"
             print("Failed to retrieve necessary data from JSON.")
           }
         } catch {
           responseString += "Failed to parse JSON data: \(error)\n"
           print("Failed to parse JSON data: \(error)")
         }
       } else {
         responseString += "No data received\n"
         print("No data received")
       }
       semaphore.signal()
     }
     
     task.resume()
     semaphore.wait()
     
     return responseString
   }
 }

