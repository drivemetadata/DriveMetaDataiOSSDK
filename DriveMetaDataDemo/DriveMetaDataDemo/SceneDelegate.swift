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


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
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
                   print("Amit KumarReceived data: \(jsonString)")
               }
           }
        // Confirm the received URL is correct
        print("Amit Kumar Received Universal Link: \(url.absoluteString)")
        // Add your URL handling logic here
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        
        
        if let scheme = url.scheme,
           scheme.localizedCaseInsensitiveCompare("com.drivemetadata.DriveMetaDataDemo") == .orderedSame,
           let host = url.host {
            
            var parameters: [String: String] = [:]
            
            // Extract query parameters from the URL
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems {
                for item in queryItems {
                    parameters[item.name] = item.value
                }
            }
            
            // Now, `parameters` contains all query items as key-value pairs.
            // Use `scheme`, `host`, and `parameters` as needed in your logic.
            print("Scheme: \(scheme)")
            print("Host: \(host)")
            print("Parameters: \(parameters)")
        }
    }
    
    
    


}

