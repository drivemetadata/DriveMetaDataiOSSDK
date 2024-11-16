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
        
        
      //  DriveMetaData.updateConversionValue(for: "in_app_purchase")

        let data: [String: Any] = [
            "firstName": "John",
            "lastName": "Doe",
            "eventType": "userLogin"
        ]

        DriveMetaData.shared.sendTags(data: data)
       
        
        
    }
    func skAdNetworkDidReceiveAttribution(_ attribution: [String : Any]) {
           // Handle attribution data here
           print("Received attribution data: \(attribution)")
       }
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }


}


