//
//  SNNotificationCenter.swift
//  SNKit
//
//  Created by SN on 2020/3/2.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

private var SNNotificationObservingTokensKey = "SNNotificationObservingTokens"

/// Represents an object type that is compatible with SNNotification.
/// You can use `SNNotificationCenter` class to add an entry to the notification center.
public protocol SNNotificationCompatible : AnyObject { }

/// Acquiescently, NSObject conforms to SNNotificationCompatible.
extension NSObject : SNNotificationCompatible { }

/// Provides a variate of 'SNNetworkTrackingTokens' to retain notification tokens.
fileprivate extension SNNotificationCompatible {
    
    /// A lazy-loaded SNNotificationObservingTokens for using with any object conformed to SNNotificationCompatible,
    /// SNNotificationObservingTokens associated with this object, creating one if necessary.
    var associatedObservingTokens: SNNotificationObservingTokens {
        guard let associatedTokens = objc_getAssociatedObject(self, &SNNotificationObservingTokensKey) as? SNNotificationObservingTokens else {
            let tokens = SNNotificationObservingTokens()
            objc_setAssociatedObject(self, &SNNotificationObservingTokensKey, tokens, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tokens
        }
        return associatedTokens
    }
}

/// Provides a thread-safe way to manager observing tokens.
/// When associating object deinited, it will release all retaining tokens.
fileprivate final class SNNotificationObservingTokens {
    
    private let _tokens = NSMutableDictionary()
    private var _lock = pthread_mutex_t()
    
    init() {
        pthread_mutex_init(&_lock, nil)
    }
    
    func containsToken(forName aName: NSNotification.Name) -> Bool {
        let aToken: Any?
        pthread_mutex_lock(&_lock)
        aToken = _tokens[aName]
        pthread_mutex_unlock(&_lock)
        return (aToken is SNNotificationToken)
    }
    
    func setToken(_ aToken: SNNotificationToken, forName aName: NSNotification.Name) {
        pthread_mutex_lock(&_lock)
        _tokens[aName] = aToken
        pthread_mutex_unlock(&_lock)
    }
    
    func removeToken(forName aName: NSNotification.Name) {
        pthread_mutex_lock(&_lock)
        _tokens.removeObject(forKey: aName)
        pthread_mutex_unlock(&_lock)
    }
    
    func removeAllTokens() {
        pthread_mutex_lock(&_lock)
        _tokens.removeAllObjects()
        pthread_mutex_unlock(&_lock);
    }
    
    deinit {
        self.removeAllTokens()
        pthread_mutex_destroy(&_lock)
    }
}

/// Wraps the observer token received from
/// NotificationCenter.addObserver(forName:object:queue:using:)
/// and unregisters it in deinit.
fileprivate final class SNNotificationToken {
    let notificationCenter: NotificationCenter
    let token: NSObjectProtocol

    init(notificationCenter: NotificationCenter = .default, token: NSObjectProtocol) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}

fileprivate extension NotificationCenter {
    /// Convenience wrapper for addObserver(forName:object:queue:using:)
    /// that returns our custom NotificationToken.
    func observe(name: NSNotification.Name?,
                 queue: OperationQueue?,
                 using block: @escaping (Notification) -> Void) -> SNNotificationToken {
        let token = addObserver(forName: name, object: nil, queue: queue, using: block)
        return SNNotificationToken(notificationCenter: self, token: token)
    }
}

/// A convenient tool to observe a notification, and no longer need to remove observer manually.
public final class SNNotificationCenter {
        
    /// Adds an entry to the notification center to receive notifications that passed to the provided block.
    /// - Parameters:
    ///   - owner: An object that the entry will associat with.
    ///   - name: The name of the notification to register for delivery to the observer block.
    ///   - queue: The operation queue where the block runs.
    ///   - block: The block that executes when receiving a notification.
    public static func addObserver(in owner: SNNotificationCompatible,
                                   forName name: NSNotification.Name,
                                   queue: OperationQueue? = .main,
                                   using block: @escaping (Notification) -> Void) {
        if owner.associatedObservingTokens.containsToken(forName: name) { return }
        let token = NotificationCenter.default.observe(name: name, queue: queue, using: block)
        owner.associatedObservingTokens.setToken(token, forName: name)
    }
        
    /// Removes matching entries from the notification center's dispatch table.
    /// - Parameters:
    ///   - owner: The object that all of matching entries associating with.
    ///   - name: The name of the notification to remove from the dispatch table.
    public static func removeObserver(from owner: SNNotificationCompatible, name: NSNotification.Name? = nil) {
        if let aName = name {
            owner.associatedObservingTokens.removeToken(forName: aName)
        } else {
            owner.associatedObservingTokens.removeAllTokens()
        }
    }
        
    /// Creates a notification with a given name, sender, and information and posts it to the notification center.
    /// - Parameters:
    ///   - aName: The name of the notification.
    ///   - anObject: The object posting the notification.
    ///   - aUserInfo: Optional information about the the notification.
    public static func post(name aName: NSNotification.Name,
                            object anObject: Any? = nil,
                            userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: aName, object: anObject, userInfo: aUserInfo)
    }
}
