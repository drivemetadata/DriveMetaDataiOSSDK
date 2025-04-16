//
//  AppDelegate.swift
//  DriveMetaDataDemo
//
//  Created by DriveMetaData on 31/03/24.
//

import UIKit
import AdSupport
import StoreKit
import AdServices



import DriveMetaDataiOSSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
        DriveMetaData.initializeShared(clientId: 1635, clientToken: "4d17d90c78154c9a5569c073b67d8a5a22b2fabfc5c9415b6e7f709d68762054", clientAppId: 2782, workspaceId: 1637)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DriveMetaData.shared?.requestIDFA()
           }
        
      //  let attributionToken = fetchAttributionToken()
      //  print(attributionToken)
        
       // requestAttributionDetails()
        
        return true
    }

    // handle deeplink Data
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("DeepLinkURL:", url)
       
        
        return true
    }
    func fetchAttributionToken() -> String? {
        if #available(iOS 14.3, *) {
            do {
                let token = try AAAttribution.attributionToken()
                return token
            } catch {
                print("Error fetching attribution token: \(error.localizedDescription)")
                return nil
            }
        } else {
            print("AdServices framework is only available on iOS 14.3 and later.")
            return nil
        }
    }
    func sendTokenToServer() {
        guard let token = fetchAttributionToken() else {
            print("Failed to fetch token.")
            return
        }

        let url = URL(string: "https://your-server-endpoint.com/attribution")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["attributionToken": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token to server: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Token successfully sent to server.")
            } else {
                print("Failed to send token to server.")
            }
        }
        task.resume()
    }
    public func requestAttributionDetails() {
           guard #available(iOS 14.3, *) else {
              // completionHandler(nil, nil)
               return
           }
           guard let adAttributionToken = try? AAAttribution.attributionToken() else {
              // completionHandler(nil, AdServiceErrors.invalidToken)
               return
           }
           guard let url = URL(string: "https://api-adservices.apple.com/api/v1/") else {
              // completionHandler(nil, AdServiceErrors.invalidUrl)
               return
           }
           let request = NSMutableURLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
           request.httpBody = adAttributionToken.data(using: .utf8)
           let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { [weak self] data, _, error in
               if let error = error {
                 //  completionHandler(nil, error)
                   return
               }
               do {
                   guard let data = data else {
                      // completionHandler(nil, AdServiceErrors.nilData)
                       return
                   }
                   guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: NSObject] else {
                      // completionHandler(nil, AdServiceErrors.invalidJson)
                       return
                   }
                   print(jsonResponse)
                  // completionHandler(self?.getAttributionData(details: jsonResponse), nil)
               } catch {
                  // completionHandler(nil, error)
               }//
           })
           task.resume()
       }
   
}


  

