//
//  DMDAdAttribution.swift
//  DriveMetaData
//
//  Created by DriveMetaData on 2025.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import Foundation
#if attribution
import TealiumCore
#endif

// MARK: - Protocol Definitions

/// Protocol for handling SKAdNetwork attribution.
public protocol DMDAdAttributionProtocol {
    func extractConversionInfo(from dispatch: DMDTrackRequest)
    func registerAdNetwork()
    func updateConversion(value: Int)
}

/// Protocol for interacting with SKAdNetwork.
public protocol DMDAttributionManagerProtocol {
    func registerAppForAdNetworkAttribution()
    func updateConversionValue(_ value: Int)
}

// MARK: - Default Implementation

/// Default implementation for handling SKAdNetwork attribution.
public class DMDAdAttribution: DMDAdAttributionProtocol {
    
    // MARK: - Properties
    private let config: DMDConfig
    private let attributor: DMDAttributionManagerProtocol

    // MARK: - Initialization
    public init(config: DMDConfig, attributor: DMDAttributionManagerProtocol = DMDAttributionManager()) {
        self.config = config
        self.attributor = attributor
    }

    // MARK: - Public Methods

    /// Extracts and updates conversion info from a tracking request.
    public func extractConversionInfo(from dispatch: DMDTrackRequest) {
        guard let event = dispatch.extractKey(lookup: config.skAdConversionKeys),
              let conversionValue = dispatch.extractLookupValue(for: event) as? Int else {
            logError("Invalid conversion event or missing conversion value.")
            return
        }

        guard (0...63).contains(conversionValue) else {
            logError("Conversion value must be between 0 and 63.")
            return
        }

        updateConversion(value: conversionValue)
    }

    /// Registers the app for ad network attribution.
    public func registerAdNetwork() {
        guard #available(iOS 11.3, *) else {
            logDebug("SKAdNetwork is not available. iOS 11.3+ required.")
            return
        }
        attributor.registerAppForAdNetworkAttribution()
    }

    /// Updates the conversion value.
    public func updateConversion(value: Int) {
        guard #available(iOS 14.0, *) else {
            logDebug("SKAdNetwork.updateConversionValue() is not available. iOS 14.0+ required.")
            return
        }
        attributor.updateConversionValue(value)
    }

    // MARK: - Private Logging Helpers

    /// Logs an error message.
    private func logError(_ message: String) {
        let errorLog = DMDLogRequest(title: "SKAdNetwork Error", message: message, logLevel: .error)
        config.logger?.log(errorLog)
    }

    /// Logs a debug message.
    private func logDebug(_ message: String) {
        let debugLog = DMDLogRequest(title: "SKAdNetwork Debug", message: message, logLevel: .debug)
        config.logger?.log(debugLog)
    }
}

// MARK: - Attribution Manager

/// Default implementation for SKAdNetwork attribution methods.
public class DMDAttributionManager: DMDAttributionManagerProtocol {
    public func registerAppForAdNetworkAttribution() {
        if #available(iOS 11.3, *) {
            SKAdNetwork.registerAppForAdNetworkAttribution()
        }
    }

    public func updateConversionValue(_ value: Int) {
        if #available(iOS 14.0, *) {
            SKAdNetwork.updatePostbackConversionValue(value)
        }
    }
}

#endif
