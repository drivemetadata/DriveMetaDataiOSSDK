//
//  SceneDelegate.swift
//  DriveMetaDataDemo
//
//  Created by DriveMetaData on 31/03/24.
//

import UIKit
import DriveMetaDataiOSSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


   
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }
       
        DriveMetaData.shared?.getBackgroundData(uri: url) { (jsonString, error) in
               if let error = error {
                   // Handle error
                   print("Error: \(error.localizedDescription)")
               } else if let jsonString = jsonString {
                   // Handle success, use jsonString
                   print("DMD Received data: \(jsonString)")
               }
           }
        // Confirm the received URL is correct
        print("DMD  Received Universal Link: \(url.absoluteString)")
        // Add your URL handling logic here
    }

}

