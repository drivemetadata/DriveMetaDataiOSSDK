import Foundation

 struct RequestData: Codable {
    struct MetaData: Codable {
        struct AppDetails: Codable {
            let app_id: Int
            let bundle: String
            let name: String
            let version: String
            let build: String
        }
       
        struct UserDetails : Codable
        {
            let first_name : String?
            let last_name : String?
            let mobile : String?
            let gender : String?
            let age : String?
            let dob : String?
            let country : String?
            let zip: String?
            let city : String?
            let state : String?
            let address : String?
            
            
        }
    
        struct Device: Codable {
            struct Screen: Codable {
                let width: Int
                let height: Int
                let screen_dpi: Int
            }
            
            let device_internal_id: String
            let ios_advertising_id: String
            let ad_tracking_enabled: Bool
            let make: String
            let model: String
            let platform: String
            let os_platform_version: String
            let name: String
            let device_type: String
            let is_mobile: Bool
            let screen: Screen
        }
        
        struct Library: Codable {
            let name: String
            let version: String
        }
        
        struct adData: Codable
        {
            let token : String
        }
        let appDetails: AppDetails?
        let device: Device?
        let ip: String?
        let library: Library?
        let locale: String?
        let adData : adData?
        let ua: String // mandatory
        let requestId: String  // mandatory
        let requestReceivedAt: String  // mandatory
        let requestSentAt: String // mandatory
        let timestamp: String  //// mandatory
        let eventType: String // mandatory
        let requestFrom: String // mandatory
        let token: String // mandatory
        let clientId: Int // mandatory
        let userDetails : UserDetails?
    }
    
    let metaData: MetaData
}
