//
//  PluginType+SN.swift
//  SNKit
//
//  Created by SN on 2020/3/1.
//  Copyright © 2020 Apple. All rights reserved.
//

import Moya

private var SNNetworkTrackingTokensKey = "SNNetworkTrackingTokens"

/// Represents an object type that is compatible with SNNetworking.
/// You can use `SNNetworkTrackingPlugin` class to track a networking request.
public protocol SNNetworkTrackingCompatible : AnyObject { }

/// Acquiescently, NSObject conforms to SNNetworkingCompatible.
extension NSObject : SNNetworkTrackingCompatible { }

/// Provides a variate of 'SNNetworkTrackingTokens' to retain request tokens.
fileprivate extension SNNetworkTrackingCompatible {
    
    /// A lazy-loaded SNNetworkTrackingTokens for using with any object conformed to SNNetworkTrackingCompatible,
    /// SNNetworkTrackingTokens associated with this object, creating one if necessary.
    var associatedTrackingTokens: SNNetworkTrackingTokens {
        guard let associatedTokens = objc_getAssociatedObject(self, &SNNetworkTrackingTokensKey) as? SNNetworkTrackingTokens else {
            let tokens = SNNetworkTrackingTokens()
            objc_setAssociatedObject(self, &SNNetworkTrackingTokensKey, tokens, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tokens
        }
        return associatedTokens
    }
}

/// Provides a thread-safe way to manager request tokens.
/// When associating object deinited, it will release all retaining request tokens.
fileprivate final class SNNetworkTrackingTokens {
    
    private let _tokens = NSMutableSet()
    private var _lock = pthread_mutex_t()
    
    init() {
        pthread_mutex_init(&_lock, nil)
    }

    func add(_ token: SNNetworkTrackingToken) {
        pthread_mutex_lock(&_lock)
        _tokens.add(token)
        pthread_mutex_unlock(&_lock)
    }
    
    func remove(_ token: SNNetworkTrackingToken) {
        pthread_mutex_lock(&_lock)
        _tokens.remove(token)
        pthread_mutex_unlock(&_lock)
    }

    func removeAll() {
        /// Remove all tracking tokens.
        pthread_mutex_lock(&_lock)
        let tokens = NSSet(set: _tokens)
        _tokens.removeAllObjects()
        pthread_mutex_unlock(&_lock)
        /// Every token cancel it's request when removed from its owner.
        for token in tokens where (token is SNNetworkTrackingToken) {
            (token as? SNNetworkTrackingToken)?.request.cancel()
        }
    }
    
    deinit {
        self.removeAll()
        pthread_mutex_destroy(&_lock)
    }
}

/// Wraps the request received from SNMoyaProvider into a token object.
/// You can use `SNNetworkTrackingPlugin` class to track the token object.
public final class SNNetworkTrackingToken {
    
    public let request: Cancellable

    public init(request: Cancellable) {
        self.request = request
    }
}

/// A customized plugin that can track request tokens.
/// Every request token will be retained in plugin and released when its plugin deinited.
/// If necessary, we can cancel a request token by 'cancel' method ahead of time.
public final class SNNetworkTrackingPlugin : PluginType {
    
    private weak var weakOwner: SNNetworkTrackingCompatible?
    private var retainingToken: SNNetworkTrackingToken?
        
    /// Wraps the request received from SNMoyaProvider and tracks in its owner.
    internal func track(_ request: Cancellable, in owner: SNNetworkTrackingCompatible) -> SNNetworkTrackingToken {
        let token = SNNetworkTrackingToken(request: request)
        SNNetworkTrackingPlugin.track(token, in: owner)
        self.retainingToken = token
        self.weakOwner = owner
        return token
    }
    
    /// Tracks a request token to the given owner.
    public static func track(_ token: SNNetworkTrackingToken, in owner: SNNetworkTrackingCompatible) {
        if token.request.isCancelled { return }
        owner.associatedTrackingTokens.add(token)
    }
    
    /// Untracks a request token from the given owner.
    public static func cancel(_ token: SNNetworkTrackingToken, from owner: SNNetworkTrackingCompatible) {
        token.request.cancel()
        owner.associatedTrackingTokens.remove(token)
    }
    
    /// Untracks all request tokens from the given owner.
    public static func cancelAll(from owner: SNNetworkTrackingCompatible) {
        owner.associatedTrackingTokens.removeAll()
    }
    
    deinit {
        guard let owner = weakOwner else { return }
        guard let token = retainingToken else { return }
        SNNetworkTrackingPlugin.cancel(token, from: owner)
    }
}
