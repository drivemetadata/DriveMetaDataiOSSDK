//
//  ViewController.swift
//  DriveMetaDataDemo
//
//  Created by DriveMetaData on 31/03/24.
//

import UIKit
import DriveMetaDataiOSSDK

class ViewController: UIViewController {

    @IBAction func addPurchase(_ sender: Any) {
        let userDetails: [String: Any] = [
            "eCommerce": [
                "value":8.0,
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

        DriveMetaData.shared?.sendTags(tags: userDetails, eventType: "purchase") { response in
            print("Purchase response: \(response)")
        }
    }
    @IBAction func addToCart(_ sender: Any) {
        
        let userDetails: [String: Any] = [
            "eCommerce": [
                "value":999,
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

        DriveMetaData.shared?.sendTags(tags: userDetails, eventType: "add_to_cart") { response in
            print("Add to Cart response: \(response)")
        }
        
        
        
    }
    @IBAction func shareDetails(_ sender: Any) {
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

        DriveMetaData.shared?.sendTags(tags: userDetails, eventType: "product_viewed") { response in
            print("Product View response: \(response)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

    }


}


