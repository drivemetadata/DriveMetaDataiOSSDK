//
//  ViewController.swift
//  DriveMetaDataDemo
//
//  Created by DriveMetaData on 31/03/24.
//

import UIKit
import DriveMetaDataiOSSDK
import AdSupport
//import AdAttributionKit
import StoreKit

class ViewController: UIViewController {

    @IBAction func shareDetails(_ sender: Any) {
        
        print("clicked")
        
      //  DriveMetaData.updateConversionValue(for: "in_app_purchase")

       // DriveMetaData.sendTags(firstName: "Ranjeet Ranjan ", lastName: "Ranjan", eventType: "update")
        let customURL = URL(string: "https://p-api.drivemetadata.com/deeplink-tracker=phz7m")!

        
        // Call getBackgroundData
        DriveMetaData.getBackgroundData(uri: customURL) { result in
            switch result {
            case .success(let data):
                print("Data received: \(data)")
                // Handle the received data here (e.g., navigate to a specific view controller)

            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Handle the error here (e.g., show an error message)
            }
        }
        
    }
    func skAdNetworkDidReceiveAttribution(_ attribution: [String : Any]) {
           // Handle attribution data here
           print("Received attribution data: \(attribution)")
       }
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }


}


