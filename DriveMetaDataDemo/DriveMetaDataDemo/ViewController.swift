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

        DriveMetaData.sendTags(firstName: "Ranjeet Ranjan ", lastName: "Ranjan", eventType: "update")
        
    }
    func skAdNetworkDidReceiveAttribution(_ attribution: [String : Any]) {
           // Handle attribution data here
           print("Received attribution data: \(attribution)")
       }
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }


}


