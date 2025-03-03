import UIKit
import AdSupport
import AppTrackingTransparency

class DeviceInfoManager {
    static let shared = DeviceInfoManager()
    
    private init() {}

    /// Requests App Tracking Transparency permission and retrieves IDFA if granted.
    func requestAdTrackingPermission(completion: @escaping (String?, Bool) -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    let isTrackingEnabled = (status == .authorized)
                    let idfa = isTrackingEnabled ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
                    UserDefaults.standard.set(isTrackingEnabled, forKey: "adstatus")
                    UserDefaults.standard.set(idfa, forKey: "idfa")
                    completion(idfa, isTrackingEnabled)
                }
            }
        } else {
            let isTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            let idfa = isTrackingEnabled ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
            UserDefaults.standard.set(isTrackingEnabled, forKey: "adstatus")
            UserDefaults.standard.set(idfa, forKey: "idfa")
            completion(idfa, isTrackingEnabled)
        }
    }

    /// Retrieves stored ad tracking details (IDFA & tracking status)
    func getAdTrackingDetails() -> (idfa: String?, isTrackingEnabled: Bool) {
        let isTrackingEnabled = UserDefaults.standard.bool(forKey: "adstatus")
        let idfa = UserDefaults.standard.string(forKey: "idfa")
        return (idfa, isTrackingEnabled)
    }

    /// Retrieves device details, including ad tracking info
    func getDeviceDetails() -> [String: Any] {
        let adTrackingDetails = getAdTrackingDetails()
        
        return [
            "device_internal_id": UIDevice.current.identifierForVendor?.uuidString ?? "N/A",
            "ios_advertising_id": adTrackingDetails.idfa ?? "Tracking not allowed",
            "ad_tracking_enabled": adTrackingDetails.isTrackingEnabled,
            "make": "Apple",
            "model": UIDevice.current.model,
            "platform": UIDevice.current.systemName,
            "name": UIDevice.current.name,
            "device_type": UIDevice.current.userInterfaceIdiom == .pad ? "Tablet" : "Mobile",
            "is_mobile": UIDevice.current.userInterfaceIdiom == .phone,
            "screen": getScreenDetails()
        ]
    }

    /// Retrieves screen details
    private func getScreenDetails() -> [String: Any] {
        return [
            "width": Int(UIScreen.main.bounds.width),
            "height": Int(UIScreen.main.bounds.height),
            "screen_dpi": Int(UIScreen.main.scale)
        ]
    }
}
