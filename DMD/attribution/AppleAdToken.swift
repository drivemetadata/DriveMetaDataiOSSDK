import Foundation
import AdServices

public protocol DMDAdClientProtocol {
    func requestAttributionDetails(_ completionHandler: @escaping (DMDAttributionDataa?, Error?) -> Void)
}

public class DMDHTTPAdClient {
   
    
    public init() {}
    public func requestAttributionDetails(_ completionHandler: @escaping ([String: Any]?, Error?) -> Void) {
        guard #available(iOS 14.3, *) else {
            print("AdServices not available on this iOS version.")
            completionHandler(nil, nil)
            return
        }

        DispatchQueue.global(qos: .background).async {
            do {
                let adAttributionToken = try AAAttribution.attributionToken()

                guard !adAttributionToken.isEmpty else {
                    print("Attribution token is empty.")
                    DispatchQueue.main.async {
                        completionHandler(nil, AdServiceErrors.invalidToken)
                    }
                    return
                }

                guard let url = URL(string: APIConfig.shared.apiURL) else {
                    print("Invalid API URL.")
                    DispatchQueue.main.async {
                        completionHandler(nil, AdServiceErrors.invalidUrl)
                    }
                    return
                }

                self.sendAttributionRequest(url: url, token: adAttributionToken) { tags, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            completionHandler(nil, error)
                        }
                        return
                    }
                    
                    if let tags = tags {
                        let wrapped: [String: Any] = [DMDConstants.DMD_APPLE_ATTRIBUTION: tags]
                        DispatchQueue.main.async {
                            completionHandler(wrapped, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completionHandler(nil, nil)
                        }
                    }

                }
            } catch {
                print("Failed to retrieve attribution token: \(error)")
                DispatchQueue.main.async {
                    completionHandler(nil, AdServiceErrors.invalidToken)
                }
            }
        }
    }

    


    private func sendAttributionRequest(
        url: URL,
        token: String,
        completionHandler: @escaping ([String: Any]?, Error?) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = token.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error: \(error)")
                completionHandler(nil, error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❗️No data received")
                completionHandler(nil, nil)
                return
            }

            do {
                // Parse JSON into a dictionary
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                   var modijson = [String: Any]()
               
                    
                    // Safely extract String fields
                    for (jsonKey, modKey) in AttributionFieldMappings.stringFields {
                        if let value = jsonObject[jsonKey] {
                            if let casted = value as? String {
                                modijson[modKey] = casted
                            } else {
                                print("⚠️ \(modKey) exists but is not a String")
                            }
                        } else {
                            print("⚠️ \(modKey) is missing in JSON")
                        }
                    }

                    // Safely extract Int fields
                    for (jsonKey, modKey) in AttributionFieldMappings.intFields {
                        if let value = jsonObject[jsonKey] {
                            if let casted = value as? Int {
                                modijson[modKey] = casted
                            } else {
                                print("⚠️ \(modKey) exists but is not an Int")
                            }
                        } else {
                            print("⚠️ \(modKey) is missing in JSON")
                        }
                    }
                    
                    
                    
                    
                    var modifiedJson = modijson
                    modifiedJson[DMDConstants.DMD_APPLE_AD_TOKEN] = token // 👈 Add your custom key-value here

                    completionHandler(modifiedJson, nil)
                } else {
                    print("⚠️ JSON response is not a dictionary")
                    completionHandler(nil, nil)
                }
            } catch {
                print("❗️JSON parsing error: \(error.localizedDescription)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("🧾 Raw JSON:\n\(raw)")
                }
                completionHandler(nil, error)
            }
        }

        task.resume()
    }



}

struct AttributionFieldMappings {
    static let stringFields: [String: String] = [
        "claimType": "claim_type",
        "countryOrRegion": "country_or_region",
        "conversionType": "conversion_type",
        "clickDate": "click_date"
    ]

    static let intFields: [String: String] = [
        "orgId": "org_id",
        "campaignId": "campaign_id",
        "adGroupId": "ad_group_id",
        "keywordId": "keyword_id",
        "adId": "ad_id"
    ]
}









public struct DMDAttributionDataa: Codable {
    let clickedWithin30D: String?
    let clickedDate: String?
    let conversionType: String?
    let orgId: String?
    let campaignId: String?
    let adGroupId: String?
    let adKeyword: String?
    let region: String?
    let adId: String?
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

// MARK: - Apple Key Constants
enum AppleInternalKeys {
    enum AAAAttribution: String {
        case attribution = "attribution"
        case clickDate = "clickDate"
        case conversionType = "conversionType"
        case keywordId = "keywordId"
        case orgId = "orgId"
        case countryOrRegion = "countryOrRegion"
        case adGroupId = "adGroupId"
        case campaignId = "campaignId"
        case adId = "adId"
    }
}
