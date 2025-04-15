import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let clientId = "clientId"
        static let clientToken = "clientToken"
        static let clientAppId = "clientAppId"
        static let workspaceId = "workspaceId"

        static let sdkVersion = "sdkVersion"
        static let deviceInternalId = "deviceInternalId"
        static let isFirstTimeInstall = "isFirstTime"
    }
    
    /// Saves client-related data securely
    func saveClientData(clientId: Int, clientToken: String, clientAppId: Int,workspaceId :Int) {
        DispatchQueue.global(qos: .background).async {
            self.defaults.set(clientId, forKey: Keys.clientId)
            self.defaults.set(clientToken, forKey: Keys.clientToken)
            self.defaults.set(clientAppId, forKey: Keys.clientAppId)
            self.defaults.set(workspaceId, forKey: Keys.workspaceId)

            self.defaults.set("0.0.6", forKey: Keys.sdkVersion)
            self.defaults.set(UIDevice.current.identifierForVendor?.uuidString, forKey: Keys.deviceInternalId)
        }
    }
    
    /// Retrieves stored client data
    func getClientData() -> (
        clientId: Int?,
        clientToken: String?,
        clientAppId: Int?,
        workspaceId: Int?,
        sdkVersion: String?,
        deviceInternalId: String?
    ) {
        let clientId = defaults.integer(forKey: Keys.clientId)
        let clientAppId = defaults.integer(forKey: Keys.clientAppId)
        let workspaceId = defaults.integer(forKey: Keys.workspaceId)
        
        return (
            clientId == 0 ? nil : clientId,
            defaults.string(forKey: Keys.clientToken),
            clientAppId == 0 ? nil : clientAppId,
            workspaceId == 0 ? nil : workspaceId,
            defaults.string(forKey: Keys.sdkVersion),
            defaults.string(forKey: Keys.deviceInternalId)
        )
    }

    
    /// Retrieves the device's internal ID
    func getDeviceInternalID() -> String {
        return defaults.string(forKey: Keys.deviceInternalId) ?? "Device ID not found"
    }
    
    /// Saves first-time installation status
    func setFirstTimeInstall(_ isFirstTime: Bool) {
        defaults.setValue(isFirstTime, forKey: Keys.isFirstTimeInstall)
    }
    
    /// Checks if this is the first installation
    func isFirstTimeInstall() -> Bool {
        return defaults.bool(forKey: Keys.isFirstTimeInstall)
    }
}

