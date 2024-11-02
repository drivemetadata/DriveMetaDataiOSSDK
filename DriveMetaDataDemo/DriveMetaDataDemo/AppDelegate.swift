//
//  AppDelegate.swift
//  DriveMetaDataDemo
//
//  Created by DriveMetaData on 31/03/24.
//

import UIKit
import DriveMetaDataiOSSDK
import AdSupport
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DriveMetaData.initialise(clientId: 1635, token: "4d17d90c78154c9a5569c073b67d8a5a22b2fabfc5c9415b6e7f709d68762054", appId: 2659)
        
              SKAdNetwork.registerAppForAdNetworkAttribution()
              SKAdNetwork.updateConversionValue(1) // Set initial conversion value
              
//              SKAdNetwork.registerAppForAdNetworkAttribution {
//                  (appID, attribution) in
//                  print("App ID: \(appID)")
//                  // Handle attribution data
//                  // You can access the attribution dictionary to get campaign information
//                  if let attribution = attribution {
//                      print("Attribution: \(attribution)")
//                  }
//              }
        
        return true
    }
    func skAdNetworkDidReceiveAttribution(_ attribution: [String : Any]) {
            // Handle attribution data here
            print("Received attribution data: \(attribution)")
        }
    
    
    // handle deeplink Data
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("DeepLinkURL:", url)
       
        
        return true
    }
}


  

