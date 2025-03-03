//
//  DMDAttributionModule.swift
//  dmd-swift
//
//  Copyright © 2025 DMD, Inc. All rights reserved.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import Foundation
#if attribution
import DMDCore
#endif

public class DMDAttributionModule: Collector, DispatchListener {

    public let id: String = ModuleNames.attribution
    public var config: DMDConfig
    public var data: [String: Any]? { attributionData.allAttributionData }

    private var attributionData: AttributionDataProtocol!
    private var diskStorage: DMDDiskStorageProtocol!

    /// *Convenience initializer* for unit testing.
    /// - Parameters:
    ///   - context: DMDContext instance.
    ///   - delegate: ModuleDelegate? instance.
    ///   - diskStorage: DMDDiskStorageProtocol? instance.
    ///   - attributionData: Custom AttributionDataProtocol instance.
    convenience init(context: DMDContext,
                     delegate: ModuleDelegate?,
                     diskStorage: DMDDiskStorageProtocol?,
                     attributionData: AttributionDataProtocol) {
        self.init(context: context, delegate: delegate, diskStorage: diskStorage) { _ in }
        self.attributionData = attributionData
    }

    /// *Primary initializer* for DMDAttributionModule.
    /// - Parameters:
    ///   - context: DMDContext instance.
    ///   - delegate: ModuleDelegate? instance.
    ///   - diskStorage: DMDDiskStorageProtocol? instance.
    ///   - completion: ModuleCompletion callback when initialization is complete.
    required public init(context: DMDContext,
                         delegate: ModuleDelegate?,
                         diskStorage: DMDDiskStorageProtocol?,
                         completion: ModuleCompletion) {
        self.config = context.config
        self.diskStorage = diskStorage ?? DMDDiskStorage(config: config, forModule: "attribution", isCritical: false)
        self.attributionData = AttributionData(config: config, diskStorage: self.diskStorage)
        completion((.success(true), nil))
    }

    /// *Handles attribution tracking logic before dispatching requests.*
    /// - Parameter request: DMDRequest containing event data.
    public func willTrack(request: DMDRequest) {
        guard config.isSKAdAttributionEnabled else { return }
        attributionData.updateConversionValue(from: request)
    }

}
#endif
