//
//  AppDelegate.swift
//  DriveMetaDataDemo
//
//  Created by DriveMetaData on 31/03/24.
//

import UIKit
import AdSupport
import StoreKit


import DriveMetaDataiOSSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
        DriveMetaData.initializeShared(clientId: 1635, clientToken: "4d17d90c78154c9a5569c073b67d8a5a22b2fabfc5c9415b6e7f709d68762054", clientAppId: 2782)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DriveMetaData.shared?.requestIDFA()
           }
        

        
        return true
    }

    // handle deeplink Data
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("DeepLinkURL:", url)
       
        
        return true
    }
}


  

