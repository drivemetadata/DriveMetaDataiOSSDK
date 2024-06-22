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
        

       // DriveMetaData.sendTags(firstName: "Ranjeet Ranjan ", lastName: "Ranjan", eventType: "update")
        
    }
    func skAdNetworkDidReceiveAttribution(_ attribution: [String : Any]) {
           // Handle attribution data here
           print("Received attribution data: \(attribution)")
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        //sendPostRequest()
      // print( getPublicIPAddress())

       
        //DriveMetaData.doSomething()
        // Do any additional setup after loading the view.
    }


}

func sendPostRequest() {
    guard let url = URL(string: "https://sdk.drivemetadata.com/data-collector") else { return }
    
    let jsonData = RequestData(
        metaData: RequestData.MetaData(
            appDetails: RequestData.MetaData.AppDetails(
                app_id: 3020,
                bundle: "com.drivemetadata.DriveMetaDataDemo",
                name: "DrivemetaDataDemo App",
                version: "1",
                build: "1.0.0"
            ),
            attributionData: RequestData.MetaData.AttributionData(
                click_id: "12345",
                install_referrer: "123456",
                sdk_version: "1.0", 
                referrer_click_timestamp_seconds:1719032827 ,
                install_begin_timestamp_seconds: 1719032827,
                referrer_click_timestamp_server_seconds: 1719032827,
                install_begin_timestamp_server_seconds:1719032827,
                install_version: "1.0", 
                google_play_instant: ""
            ),
            utmParameter: RequestData.MetaData.UTMParameter(
                utm_campaign: "dmd",
                utm_term: "dmd",
                utm_source: "apple",
                utm_medium: "ios",
                utm_content: ""
            ),
            device: RequestData.MetaData.Device(
                device_internal_id: "123456789",
                google_advertising_id: "0000000000",
                ad_tracking_enabled: true,
                make: "Apple",
                model: "iPhone13,2",
                platform: "iPhone",
                os_platform_version: "15.7.1",
                name: "",
                device_type: "",
                is_mobile: true,
                is_tablet: false,
                android_uuid: "",
                cpu_architecture: "arm64",
                screen: RequestData.MetaData.Device.Screen(
                    width: 320,
                    height: 568,
                    screen_dpi: 2
                )
            ),
            ip: "123456789",
            library: RequestData.MetaData.Library(
                name: "iosSDK",
                version: "1.0"
            ),
            locale: "en-US",
            location: RequestData.MetaData.Location(
                city: "Noida",
                country: "India",
                iso_country_code: "In",
                region_code: "Dl",
                postal_code: "110096",
                location_source: "lat_long",
                latitude: 0.0,
                longitude: 0.0,
                speed: 0
            ),
            network: RequestData.MetaData.Network(
                bluetooth: false,
                carrier: "Jio",
                cellular: true,
                wifi: false
            ),
            ua: "1234567666555",
            requestId: "12345678",
            requestReceivedAt: "2024-06-22 10:26",
            requestSentAt: "2024-06-22 10:26",
            timestamp: "1719032827",
            eventType: "firstInstall",
            requestFrom: "1",
            token: "4d17d90c78154c9a5569c073b67d8a5a22b2fabfc5c9415b6e7f709d68762054",
            clientId: 1635
        )
    )
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let data = try JSONEncoder().encode(jsonData)
        request.httpBody = data
    } catch {
        print("Error encoding JSON: \(error)")
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        if let response = response as? HTTPURLResponse {
            print("Response code: \(response.statusCode)")
        }
        
        if let data = data {
            print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
        }
    }
    
    task.resume()
}

struct RequestData: Codable {
    struct MetaData: Codable {
        struct AppDetails: Codable {
            let app_id: Int
            let bundle: String
            let name: String
            let version: String
            let build: String
        }
        
        struct AttributionData: Codable {
            let click_id: String
            let install_referrer: String
            let sdk_version: String
            let referrer_click_timestamp_seconds: Int
            let install_begin_timestamp_seconds: Int
            let referrer_click_timestamp_server_seconds: Int
            let install_begin_timestamp_server_seconds: Int
            let install_version: String
            let google_play_instant: String
        }
        
        struct UTMParameter: Codable {
            let utm_campaign: String
            let utm_term: String
            let utm_source: String
            let utm_medium: String
            let utm_content: String
        }
        
        struct Device: Codable {
            struct Screen: Codable {
                let width: Int
                let height: Int
                let screen_dpi: Int
            }
            
            let device_internal_id: String
            let google_advertising_id: String
            let ad_tracking_enabled: Bool
            let make: String
            let model: String
            let platform: String
            let os_platform_version: String
            let name: String
            let device_type: String
            let is_mobile: Bool
            let is_tablet: Bool
            let android_uuid: String
            let cpu_architecture: String
            let screen: Screen
        }
        
        struct Library: Codable {
            let name: String
            let version: String
        }
        
        struct Location: Codable {
            let city: String
            let country: String
            let iso_country_code: String
            let region_code: String
            let postal_code: String
            let location_source: String
            let latitude: Double
            let longitude: Double
            let speed: Int
        }
        
        struct Network: Codable {
            let bluetooth: Bool
            let carrier: String
            let cellular: Bool
            let wifi: Bool
        }
        
        let appDetails: AppDetails
        let attributionData: AttributionData
        let utmParameter: UTMParameter
        let device: Device
        let ip: String
        let library: Library
        let locale: String
        let location: Location
        let network: Network
        let ua: String
        let requestId: String
        let requestReceivedAt: String
        let requestSentAt: String
        let timestamp: String
        let eventType: String
        let requestFrom: String
        let token: String
        let clientId: Int
    }
    
    let metaData: MetaData
}

struct Device {
            struct Screen {
                let width: Int
                let height: Int
                let screenDpi: Int
            }
            let deviceInternalId: String
            let googleAdvertisingId: String
            let adTrackingEnabled: Bool
            let make: String
            let model: String
            let platform: String
            let osPlatformVersion: String
            let name: String
            let deviceType: String
            let isMobile: Bool
            let isTablet: Bool
            let androidUuid: String
            let cpuArchitecture: String
            let screen: Screen
        }
    

