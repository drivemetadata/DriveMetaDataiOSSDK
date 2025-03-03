//
//  DMDAdClient.swift
//  dmd-swift
//
//  Copyright © 2025 DriveMetaData, Inc. All rights reserved.
//

#if os(iOS)
import AdServices
import Foundation

#if attribution
import TealiumCore
#endif

/// *Protocol defining attribution request behavior.*
public protocol DMDAdClientProtocol {
    func requestAttributionDetails(_ completionHandler: @escaping (DMDAttributionData?, Error?) -> Void)
}

/// *Apple AdServices-based Attribution Client for DriveMetaData SDK.*
public class DMDHTTPAdClient: DMDAdClientProtocol {
    
    // MARK: - Initializer
    public init() {}

    // MARK: - Private Methods

    /// Parses Apple's attribution data into DMDAttributionData.
    /// - Parameter details: Apple-provided attribution dictionary.
    /// - Returns: Parsed DMDAttributionData or nil if data is invalid.
    private func parseAttributionData(from details: [String: NSObject]?) -> DMDAttributionData? {
        guard let details = details else { return nil }
        
        return DMDAttributionData(
            clickedWithin30D: details[AppleInternalKeys.AAAAttribution.attribution.rawValue]?.description,
            clickedDate: details[AppleInternalKeys.AAAAttribution.clickDate.rawValue]?.description,
            conversionType: details[AppleInternalKeys.AAAAttribution.conversionType.rawValue]?.description,
            adKeyword: details[AppleInternalKeys.AAAAttribution.keywordId.rawValue]?.description,
            orgId: details[AppleInternalKeys.AAAAttribution.orgId.rawValue]?.description,
            region: details[AppleInternalKeys.AAAAttribution.countryOrRegion.rawValue]?.description,
            adGroupId: details[AppleInternalKeys.AAAAttribution.adGroupId.rawValue]?.description,
            campaignId: details[AppleInternalKeys.AAAAttribution.campaignId.rawValue]?.description,
            adId: details[AppleInternalKeys.AAAAttribution.adId.rawValue]?.description
        )
    }

    // MARK: - Public Methods

    /// Requests Apple's AdServices attribution details and parses the response.
    /// - Parameter completionHandler: Callback with DMDAttributionData or an error.
    public func requestAttributionDetails(_ completionHandler: @escaping (DMDAttributionData?, Error?) -> Void) {
        guard #available(iOS 14.3, *) else {
            completionHandler(nil, nil)
            return
        }

        do {
            let adAttributionToken = try AAAttribution.attributionToken()
            guard let url = URL(string: "https://api-adservices.apple.com/api/v1/") else {
                completionHandler(nil, AdServiceErrors.invalidUrl)
                return
            }
            sendAttributionRequest(url: url, token: adAttributionToken, completionHandler: completionHandler)
        } catch {
            completionHandler(nil, AdServiceErrors.invalidToken)
        }
    }

    // MARK: - Private Network Handling

    /// Sends a network request to Apple's AdServices API.
    /// - Parameters:
    ///   - url: API endpoint.
    ///   - token: Attribution token.
    ///   - completionHandler: Callback with attribution data or error.
    private func sendAttributionRequest(url: URL, token: String, completionHandler: @escaping (DMDAttributionData?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = token.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                completionHandler(nil, error)
                return
            }

            guard let data = data else {
                completionHandler(nil, AdServiceErrors.nilData)
                return
            }

            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: NSObject] else {
                    completionHandler(nil, AdServiceErrors.invalidJson)
                    return
                }
                completionHandler(self.parseAttributionData(from: jsonResponse), nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
}

// MARK: - Error Handling
public extension DMDHTTPAdClient {
    enum AdServiceErrors: Error {
        case invalidUrl
        case invalidJson
        case nilData
        case invalidToken
    }
}
#endif
