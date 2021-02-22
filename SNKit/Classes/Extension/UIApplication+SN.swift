//
//  UIApplication+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    /// App's bundle identifier.
    static var bundleIdentifier: String? {
        return Bundle.main.bundleIdentifier
    }

    /// App's display name.
    static var displayName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
    
    /// App's current version string.
    static var versionNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    /// App's current build string.
    static var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

public extension UIApplication {
    
    /// Return true when current device is Infinity Display series.
    static var isRunningInX: Bool {
        if #available(iOS 11.0, *) {
            if let safeAreaInsets = UIApplication.compatibleKeyWindow?.safeAreaInsets {
                return safeAreaInsets.bottom > 0.0
            }
            if let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets {
                return safeAreaInsets.bottom > 0.0
            }
            if let safeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets {
                return safeAreaInsets.bottom > 0.0
            }
        }
        return false
    }
    
    /// Get the key window, compatible with iOS 13 and multiple scenes.
    static var compatibleKeyWindow: UIWindow? {
        guard #available(iOS 13.0, *) else {
            return UIApplication.shared.keyWindow
        }
        guard UIApplication.shared.supportsMultipleScenes else {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
        return UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 }).first?.windows
            .filter({ $0.isKeyWindow }).first
    }
    
    /// Get current height of status bar, compatible with iOS 13 and multiple scenes.
    static var compatibleStatusBarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0.0
        if #available(iOS 13.0, *) {
            if let statusBarFrame = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame {
                statusBarHeight = statusBarFrame.height /// May be not comprehensive enough.
            }
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight /// returns 0.0 if the status bar is hidden.
    }
    
    /// Standard height of UINavigationBar.
    static var compatibleNavigationBarHeight: CGFloat {
        return self.compatibleStatusBarHeight + 44.0
    }
}

public extension UIApplication {
    
    /// Attempts to open the resource at the specified URL asynchronously.
    /// - Parameters:
    ///   - url: The resource identified by this URL may be local to the current app or it may be one that must be provided by a different app.
    ///   - options: A dictionary of options to use when opening the URL.
    ///   - completionHandler: The block to execute with the results.
    static func openSpecifiedURL(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any] = [:], completionHandler: ((Bool) -> Void)? = nil) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: options, completionHandler: completionHandler)
        } else {
            completionHandler?(false)
        }
    }
    
    /// Attempts to open the Dialing app with the given phone number.
    /// - Parameters:
    ///   - number: A phone number.
    ///   - completionHandler: The block to execute with the results.
    static func callNumber(_ number: String, completionHandler: ((Bool) -> Void)? = nil) {
        if let url = URL(string: "telprompt://\(number)") {
            UIApplication.openSpecifiedURL(url, completionHandler: completionHandler)
        } else {
            completionHandler?(false)
        }
    }
    
    /// Open the Settings app and displays the app’s custom settings, if it has any.
    /// - Parameters:
    ///   - options: A dictionary of options to use when opening the Settings app.
    ///   - completionHandler: The block to execute with the results.
    static func openSettings(_ completionHandler: ((Bool) -> Void)? = nil) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.openSpecifiedURL(url, completionHandler: completionHandler)
        } else {
            completionHandler?(false)
        }
    }
}
