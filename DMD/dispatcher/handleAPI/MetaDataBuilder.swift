//
//  MetaDataBuilder.swift
//  Pods
//
//  Created by DriveMetaData on 06/04/25.
//

class MetadataBuilder {
    
    static func buildBaseMetadata(
        eventType: String,
        tags: [String: Any] = [:],
        includeExtraDetails: Bool = false
    ) -> [String: Any] {
        let retrievedData = StorageManager.shared.getClientData()

        var metadata: [String: Any] = [
            DMDConstants.DMD_UA: "",
            DMDConstants.DMD_REQUEST_ID: DeviceInfoManager.shared.generateUniqueID(),
            DMDConstants.DMD_REQUEST_RECEIVED: DateTimeManager.shared.getCurrentDate(),
            DMDConstants.DMD_REQUEST_SENT: DateTimeManager.shared.getCurrentDate(),
            DMDConstants.DMD_ANONYMOUS_ID: DeviceInfoManager.shared.getAnonymousId(),
            DMDConstants.DMD_SESSION_ID: SessionManager.shared.getSessionID(),
            DMDConstants.DMD_TIMESTAMP: DateTimeManager.shared.getCurrentDate(),
            DMDConstants.DMD_EVENT_TYPE: eventType,
            DMDConstants.DMD_REQUEST_FORM: DMDConstants.DMD_REQUEST_FORM_VALUE,
            DMDConstants.DMD_TOKEN: retrievedData.clientToken ?? "",
            DMDConstants.DMD_CLIENT_ID: retrievedData.clientId ?? 0,
            DMDConstants.DMD_LOCALE: Locale.current.identifier,
            DMDConstants.DMD_IP: Utils.getIPAddress() ?? "0.0.0.0"
        ]

        if includeExtraDetails {
            metadata[DMDConstants.DMD_APP_DETAILS] = AppInfoManager.shared.getAppDetails()
            metadata[DMDConstants.DMD_DEVICE_DETAILS] = DeviceInfoManager.shared.getDeviceDetails()
            metadata[DMDConstants.DMD_LIBRARY_DETAILS] = AppInfoManager.shared.getLibraryDetails()
        }

        metadata.merge(tags) { (_, new) in new }

        return [DMDConstants.DMD_META: metadata]
    }
    
    static func sendEvent(
        eventType: String,
        tags: [String: Any] = [:],
        includeExtraDetails: Bool = false,
        endPoint: String,
        onSuccess: ((String) -> Void)? = nil,
        onFailure: ((String) -> Void)? = nil
    ) {
        let metadata = buildBaseMetadata(
            eventType: eventType,
            tags: tags,
            
            includeExtraDetails: includeExtraDetails
        )
        
        
        debugPrint(endPoint)
        print(tags)
        

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: metadata, options: [])
            
            RestApiManager.shared.sendRequest(jsonData: metadata, endPoint: endPoint) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let responseString):
                        onSuccess?(responseString)
                    case .failure(let error):
                        onFailure?(error.localizedDescription)
                    }
                }
            }
        } catch {
            onFailure?(error.localizedDescription)
        }
    }
}

