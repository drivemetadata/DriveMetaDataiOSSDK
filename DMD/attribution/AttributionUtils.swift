

//
//  DMDAttributionExtensions.swift
//  dmd-swift
//
//  Copyright © 2025 DMD, Inc. All rights reserved.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import Foundation
#if attribution
import DMDCore
#endif

/// Configuration keys for enabling/disabling attribution features.
extension DMDConfigKey {
    static let enableSearchAds = "com.dmd.attribution.searchads.enable"
    static let enableSKAdAttribution = "com.dmd.attribution.skadattribution.enable"
}

public extension DMDConfig {

    /// Enables (true) or disables (false) Apple Search Ads API in the Attribution module.
    var isSearchAdsEnabled: Bool {
        get { options[DMDConfigKey.enableSearchAds] as? Bool ?? false }
        set { options[DMDConfigKey.enableSearchAds] = newValue }
    }

    /// Enables (true) or disables (false) SKAdNetwork in the Attribution module.
    var isSKAdAttributionEnabled: Bool {
        get { options[DMDConfigKey.enableSKAdAttribution] as? Bool ?? false }
        set { options[DMDConfigKey.enableSKAdAttribution] = newValue }
    }
}

public extension Collectors {
    static let Attribution = DMDAttributionModule.self
}

#endif
