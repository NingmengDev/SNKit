//
//  SNNetworking.swift
//  SNKit
//
//  Created by SN on 2020/3/1.
//  Copyright © 2020 Apple. All rights reserved.
//

import Moya

/// Convenience request-making class, `SNMoyaTarget` will be used as designated target.
public final class SNNetworking {
    
    /// A most-simplified designated request-making method, takes the target object as its only parameter.
    /// - Parameter target: Any object which conforms to SNMoyaTarget.
    /// - Returns: A token that wrapping `Cancellable` request to cancel the request later.
    @discardableResult
    public static func request(_ target: SNMoyaTarget) -> SNNetworkTrackingToken {
        let request = SNMoyaProvider.request(target) { (_, _) in }
        return SNNetworkTrackingToken(request: request)
    }
    
    /// A simplified designated request-making method, takes progress handler as its optional parameter.
    /// - Parameters:
    ///   - target: target: Any object which conforms to SNMoyaTarget.
    ///   - progress: Progress handler to be executed when progress changes.
    ///   - completionHandler: Completion handler to be executed when a request has completed.
    /// - Returns: A token that wrapping `Cancellable` request to cancel the request later.
    @discardableResult
    public static func request(_ target: SNMoyaTarget,
                               progress: ProgressBlock? = nil,
                               completionHandler: @escaping SNMoyaCompletionHandler) -> SNNetworkTrackingToken {
        let request = SNMoyaProvider.request(target,
                                             progress: progress,
                                             completionHandler: completionHandler)
        return SNNetworkTrackingToken(request: request)
    }
    
    /// A designated request-making method, pass an 'owner' object to track request token automatically.
    /// - Parameters:
    ///   - target: Any object which conforms to SNMoyaTarget.
    ///   - owner: Any object which conforms to SNNetworkTrackingCompatible.
    ///   - progress: Progress handler to be executed when progress changes.
    ///   - completionHandler: Completion handler to be executed when a request has completed.
    /// - Returns: A token that wrapping `Cancellable` request to cancel the request later.
    @discardableResult
    public static func request(_ target: SNMoyaTarget,
                               in owner: SNNetworkTrackingCompatible,
                               progress: ProgressBlock? = nil,
                               completionHandler: @escaping SNMoyaCompletionHandler) -> SNNetworkTrackingToken {
        /// Customize request tracking plugin.
        let trackingPlugin = SNNetworkTrackingPlugin()
        let request = SNMoyaProvider.request(target,
                                             plugins: [trackingPlugin],
                                             progress: progress,
                                             completionHandler: completionHandler)
        return trackingPlugin.track(request, in: owner)
    }
}
