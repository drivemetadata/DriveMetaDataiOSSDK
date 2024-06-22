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
            let first_name : String
            let last_name : String
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
        
      
        struct Network: Codable {
            let bluetooth: Bool
            let carrier: String
            let cellular: Bool
            let wifi: Bool
        }
        
        let appDetails: AppDetails?
        let attributionData: AttributionData?
        let utmParameter: UTMParameter?
        let device: Device?
        let ip: String?
        let library: Library?
        let locale: String?
        let network: Network?
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
