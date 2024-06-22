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
        DriveMetaData.initialise(clientId: 1635, token: "4d17d90c78154c9a5569c073b67d8a5a22b2fabfc5c9415b6e7f709d68762054", appId: 3020)
        
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

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

