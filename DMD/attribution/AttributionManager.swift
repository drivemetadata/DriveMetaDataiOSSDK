//
//  DMDASIdentifierManager.swift
//  DriveMetaData
//
//  Created by DriveMetaData on 2025.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import AdSupport
import Foundation
import UIKit
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// Protocol for handling ad tracking information.
public protocol DMDASIdentifierManagerProtocol {
    var advertisingIdentifier: String { get }
    var isAdvertisingTrackingEnabled: Bool { get }
    var identifierForVendor: String { get }
    var trackingAuthorizationStatus: TrackingAuthorizationStatus { get }
}

/// Enum representing tracking authorization statuses.
public enum TrackingAuthorizationStatus: String {
    case notDetermined = "Not Determined"
    case restricted = "Restricted"
    case denied = "Denied"
    case authorized = "Authorized"
    case unknown = "Unknown"

    static func from(rawValue: UInt) -> TrackingAuthorizationStatus {
        switch rawValue {
        case 0: return .notDetermined
        case 1: return .restricted
        case 2: return .denied
        case 3: return .authorized
        default: return .unknown
        }
    }
}

/// Implementation of DMDASIdentifierManagerProtocol.
public class DMDASIdentifierManager: DMDASIdentifierManagerProtocol {
    
    // MARK: - Properties
    private let idManager: ASIdentifierManager
    private let device: UIDevice
    private let trackingManager: DMDTrackingManagerProtocol

    public static let shared = DMDASIdentifierManager()
    
    // Lazy-loaded identifierForVendor to optimize performance.
    public lazy var identifierForVendor: String = {
        device.identifierForVendor?.uuidString ?? UUID().uuidString
    }()

    // MARK: - Initialization
    private init(
        idManager: ASIdentifierManager = ASIdentifierManager.shared(),
        device: UIDevice = UIDevice.current,
        trackingManager: DMDTrackingManagerProtocol = DMDTrackingManager()
    ) {
        self.idManager = idManager
        self.device = device
        self.trackingManager = trackingManager
    }

    // MARK: - Computed Properties

    /// Retrieves the advertising identifier (IDFA).
    public var advertisingIdentifier: String {
        idManager.advertisingIdentifier.uuidString
    }

    /// Determines if advertising tracking is enabled.
    public var isAdvertisingTrackingEnabled: Bool {
        if #available(iOS 14, *) {
            return trackingAuthorizationStatus == .authorized
        }
        return idManager.isAdvertisingTrackingEnabled
    }

    /// Retrieves the current tracking authorization status.
    public var trackingAuthorizationStatus: TrackingAuthorizationStatus {
        trackingManager.trackingAuthorizationStatus
    }
}

// MARK: - Tracking Manager Protocol

public protocol DMDTrackingManagerProtocol {
    var trackingAuthorizationStatus: TrackingAuthorizationStatus { get }
}

/// Implementation of the tracking manager.
public class DMDTrackingManager: DMDTrackingManagerProtocol {
    public var trackingAuthorizationStatus: TrackingAuthorizationStatus {
        if #available(iOS 14, *) {
            return TrackingAuthorizationStatus.from(rawValue: ATTrackingManager.trackingAuthorizationStatus.rawValue)
        }
        return .unknown
    }
}

#endif
