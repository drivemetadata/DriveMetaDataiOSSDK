//
//  DMDAttributionData.swift
//  dmd-swift
//
//  Copyright © 2025 DriveMetaData, Inc. All rights reserved.
//

#if os(iOS)
import Foundation

/// *Persistent storage for ad attribution data in DriveMetaData's SDK.*
public struct DMDAttributionData: Codable {
    
    // MARK: - Properties
    
    public let clickedWithin30D: String?
    public let clickedDate: String?
    public let conversionDate: String?
    public let conversionType: String?
    public let purchaseDate: String?
    public let orgName: String?
    public let orgId: String?
    public let campaignId: String?
    public let campaignName: String?
    public let adGroupId: String?
    public let adGroupName: String?
    public let adKeyword: String?
    public let adKeywordMatchType: String?
    public let creativeSetName: String?
    public let creativeSetId: String?
    public let region: String?
    public let adId: String?

    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case clickedWithin30D = "ad_user_clicked_last_30_days"
        case clickedDate = "ad_user_date_clicked"
        case conversionDate = "ad_user_date_converted"
        case conversionType = "ad_user_conversion_type"
        case purchaseDate = "ad_purchase_date"
        case orgName = "ad_org_name"
        case orgId = "ad_org_id"
        case campaignId = "ad_campaign_id"
        case campaignName = "ad_campaign_name"
        case adId = "ad_id"
        case adGroupId = "ad_group_id"
        case adGroupName = "ad_group_name"
        case adKeyword = "ad_keyword"
        case adKeywordMatchType = "ad_keyword_matchtype"
        case creativeSetName = "ad_creativeset_name"
        case creativeSetId = "ad_creativeset_id"
        case region = "ad_region"
    }

    // MARK: - Initializers

    /// Default initializer with optional parameters.
    public init(
        clickedWithin30D: String? = nil,
        clickedDate: String? = nil,
        conversionDate: String? = nil,
        conversionType: String? = nil,
        purchaseDate: String? = nil,
        orgName: String? = nil,
        orgId: String? = nil,
        campaignId: String? = nil,
        campaignName: String? = nil,
        adGroupId: String? = nil,
        adGroupName: String? = nil,
        adKeyword: String? = nil,
        adKeywordMatchType: String? = nil,
        creativeSetName: String? = nil,
        creativeSetId: String? = nil,
        region: String? = nil,
        adId: String? = nil
    ) {
        self.clickedWithin30D = clickedWithin30D
        self.clickedDate = clickedDate
        self.conversionDate = conversionDate
        self.conversionType = conversionType
        self.purchaseDate = purchaseDate
        self.orgName = orgName
        self.orgId = orgId
        self.campaignId = campaignId
        self.campaignName = campaignName
        self.adGroupId = adGroupId
        self.adGroupName = adGroupName
        self.adKeyword = adKeyword
        self.adKeywordMatchType = adKeywordMatchType
        self.creativeSetName = creativeSetName
        self.creativeSetId = creativeSetId
        self.region = region
        self.adId = adId
    }

    /// Initializes from a dictionary.
    public init?(dictionary: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            return nil
        }
        guard let decodedData = try? JSONDecoder().decode(DMDAttributionData.self, from: jsonData) else {
            return nil
        }
        self = decodedData
    }

    // MARK: - Computed Properties

    /// Returns a dictionary representation of the struct, excluding empty values.
    public var dictionary: [String: String] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMapValues { ($0 as? String)?.isEmpty == false ? $0 as? String : nil }
    }

    /// Checks if the struct contains no valid attribution data.
    public var isEmpty: Bool {
        return dictionary.isEmpty
    }

    /// Returns the count of non-nil properties.
    public var count: Int {
        return dictionary.count
    }

    /// Subscript for dictionary-like access.
    public subscript(_ key: String) -> String? {
        return dictionary[key]
    }
}
#endif
