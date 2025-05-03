//
//  ViewController.swift
//  DriveMetaDataDemo
//
//  Created by DriveMetaData on 31/03/24.
//

import UIKit
import DriveMetaDataiOSSDK

class ViewController: UIViewController {

    @IBAction func shareDetails(_ sender: Any) {
        
        
      //  DriveMetaData.updateConversionValue(for: "in_app_purchase")
//        let userDetails: [String: Any] = [
//            "userDetails":[
//               "first_name": "Amit",
//               "last_name":"Gupta",
//               "mobile":"7905717240",
//               "address":"dsdsdsd"
//               ]
//           ]
        let userDetails: [String: Any] = [
            "eCommerce": [
                "items": [
                    [
                        "id": "7798417490142",
                        "sku": "TJ-MK-207-35-S",
                        "name": "The Humble Beige Kota Doria Kali Overlay",
                        "brand": "Tjoritreasures",
                        "price": 999
                    ]
                ]
            ]
        ]
        
        
        
        
        
        
        
        
        //////
        ///
        ///
        ///
           
          
        DriveMetaData.shared?.sendTags(tags: userDetails, eventType: "product_viewed") { response in
            print("Received response: \(response)")
        }

      
       // print("Device Details", DriveMetaData.shared?.deviceDetails())
       
        
       // print("App Details", DriveMetaData.shared?.appDetails())

       
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

    }


}


