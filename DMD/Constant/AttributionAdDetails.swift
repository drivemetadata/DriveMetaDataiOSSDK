//
//  AttributionAdDetails.swift
//  Pods
//
//  Created by DriveMetaData on 01/03/25.
//


#if os(iOS)
import Foundation

#if attribution
import DMDSDKCore
#endif

/// Stores device-related advertising identifiers.
public struct DMDDeviceIdentifiers {
    public static let idfa = "device.advertising.id"
    public static let idfv = "device.advertising.vendorId"
    public static let isTrackingEnabled = "device.advertising.trackingEnabled"
}

/// Stores App Tracking Transparency (ATT) status keys.
public struct DMDTrackingStatus {
    public static let trackingAuthorization = "device.tracking.authorizationStatus"
    
    public enum AuthorizationStatus: String {
        case authorized = "authorized"
        case denied = "denied"
        case restricted = "restricted"
        case notDetermined = "not_determined"
    }
}

/// Stores Apple Search Ads attribution keys.
public struct DMDAdAttributionKeys {
    public static let adClicked = "ad.click.within_30_days"
    public static let adClickDate = "ad.click.date"
    public static let adConversionDate = "ad.conversion.date"
    public static let adConversionType = "ad.conversion.type"
    public static let adOrgName = "ad.organization.name"
    public static let adOrgId = "ad.organization.id"
    public static let adCampaignId = "ad.campaign.id"
    public static let adCampaignName = "ad.campaign.name"
    public static let adId = "ad.identifier"
    public static let adGroupId = "ad.group.id"
    public static let adGroupName = "ad.group.name"
    public static let adKeyword = "ad.keyword"
    public static let adKeywordMatchType = "ad.keyword.matchType"
    public static let adCreativeSetId = "ad.creativeSet.id"
    public static let adCreativeSetName = "ad.creativeSet.name"
    public static let adRegion = "ad.region"
}

/// Groups all attribution-related constants for easy access.
public struct DMDAttribution {
    public static let moduleName = "dmd.attribution"
    
    public static let allKeys = [
        DMDDeviceIdentifiers.idfa,
        DMDDeviceIdentifiers.idfv,
        DMDDeviceIdentifiers.isTrackingEnabled,
        DMDTrackingStatus.trackingAuthorization,
        DMDAdAttributionKeys.adClicked,
        DMDAdAttributionKeys.adClickDate,
        DMDAdAttributionKeys.adConversionDate,
        DMDAdAttributionKeys.adConversionType,
        DMDAdAttributionKeys.adOrgName,
        DMDAdAttributionKeys.adOrgId,
        DMDAdAttributionKeys.adCampaignId,
        DMDAdAttributionKeys.adCampaignName,
        DMDAdAttributionKeys.adId,
        DMDAdAttributionKeys.adGroupId,
        DMDAdAttributionKeys.adGroupName,
        DMDAdAttributionKeys.adKeyword,
        DMDAdAttributionKeys.adKeywordMatchType,
        DMDAdAttributionKeys.adCreativeSetId,
        DMDAdAttributionKeys.adCreativeSetName,
        DMDAdAttributionKeys.adRegion
    ]
}
#endif
