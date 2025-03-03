//
//  DMDAttributionProtocol.swift
//  dmd-swift
//
//  Copyright © 2025 DMD, Inc. All rights reserved.
//

#if os(iOS)
import Foundation
#if attribution
import DMDCore
#endif

/// Protocol defining the required methods and properties for attribution data management.
public protocol DMDAttributionProtocol {

    /// Retrieves all available attribution data.
    /// - Returns: [String: Any] containing persistent and volatile attribution details.
    var attributionData: [String: Any] { get }

    /// Retrieves the Identifier for Advertisers (IDFA).
    /// - Returns: String representation of IDFA.
    var idfa: String { get }

    /// Retrieves the Identifier for Vendors (IDFV).
    /// - Returns: String representation of IDFV.
    var idfv: String { get }

    /// Retrieves volatile device tracking data at runtime.
    /// - Returns: [String: Any] containing IDFV, IDFA, tracking status, etc.
    var volatileData: [String: Any] { get }

    /// Indicates whether advertising tracking is enabled.
    /// - Returns: String representation (true if tracking is allowed, false if disabled).
    var isTrackingEnabled: String { get }

    /// Updates conversion value in the SKAdNetwork for tracking campaign effectiveness.
    /// - Parameter request: DMDRequest containing tracking data.
    func updateConversionValue(from request: DMDRequest)
}
#endif
