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
        let userDetails: [String: Any] = [
               "first_name": "Amit",
               "last_name":"Gupta",
               "mobile_number":"7905717240",
               "middile_name":"kumar",
               "address":""
           ]
           
           let userObject: [String: Any] = [
               "userDetails": userDetails
           ]
        

        let response = DriveMetaData.shared?.sendTags(userDetails: userObject,eventType: "update")
        print(response)
       
        
        
    }
    func skAdNetworkDidReceiveAttribution(_ attribution: [String : Any]) {
           // Handle attribution data here
           print("Received attribution data: \(attribution)")
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the current locale
        let currentLocale = Locale.current

        // Get the identifier of the locale (e.g., "en_US", "fr_FR")
        print("Locale Identifier: \(currentLocale.identifier)")

        // Get the language code (e.g., "en" for English, "fr" for French)
        if let languageCode = currentLocale.languageCode {
            print("Language Code: \(languageCode)")
        }

        // Get the region code (e.g., "US" for United States, "FR" for France)
        if let regionCode = currentLocale.regionCode {
            print("Region Code: \(regionCode)")
        }

        // Get the currency code (e.g., "USD" for US Dollar, "EUR" for Euro)
        if let currencyCode = currentLocale.currencyCode {
            print("Currency Code: \(currencyCode)")
        }

        // Get the currency symbol (e.g., "$" for USD, "€" for Euro)
        if let currencySymbol = currentLocale.currencySymbol {
            print("Currency Symbol: \(currencySymbol)")
        }

    }


}


