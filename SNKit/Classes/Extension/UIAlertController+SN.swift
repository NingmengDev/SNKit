//
//  UIAlertController+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public extension UIAlertController {
    
    /// Index of cancel button, default is -2.
    var cancelButtonIndex: Int {
        return -2
    }
    
    /// Index of destructive button, default is -1.
    var destructiveButtonIndex: Int {
        return -1
    }
    
    /// Index of first-other button, default is 0.
    var firstOtherButtonIndex: Int {
        return 0
    }
    
    /// Creates a new UIAlertController with a title, message and a set of actions.
    /// - Parameters:
    ///   - title: The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
    ///   - message: Descriptive text that provides additional details about the reason for the alert.
    ///   - style: The style to use when presenting the alert controller. Use this parameter to configure the alert controller as an action sheet or as a modal alert.
    ///   - cancelButtonTitle: The title of the cancel button.
    ///   - destructiveButtonTitle: The title of the destructive button.
    ///   - otherButtonTitles: The title array of other normal buttons.
    ///   - actionsHandler: A block to execute when the user selects any one of action button. This block takes the index of selected action button as parameter.
    convenience init(title: String?,
                     message: String?,
                     style: UIAlertController.Style = .alert,
                     cancelButtonTitle: String? = nil,
                     destructiveButtonTitle: String? = nil,
                     otherButtonTitles: [String]? = nil,
                     actionsHandler: ((UIAlertController, Int) -> Void)? = nil) {
        
        /// Initialization.
        self.init(title: title, message: message, preferredStyle: style)
        
        /// Cancel button.
        if let cancelButtonTitle = cancelButtonTitle {
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { [weak self] (action) in
                guard let alertController = self else { return }
                actionsHandler?(alertController, alertController.cancelButtonIndex)
            }
            self.addAction(cancelAction)
        }
        
        /// Destructive button.
        if let destructiveButtonTitle = destructiveButtonTitle {
            let destructiveAction = UIAlertAction(title: destructiveButtonTitle, style: .destructive) { [weak self] (action) in
                guard let alertController = self else { return }
                actionsHandler?(alertController, alertController.destructiveButtonIndex)
            }
            self.addAction(destructiveAction)
        }
        
        /// Other buttons.
        if let otherButtonTitles = otherButtonTitles, !otherButtonTitles.isEmpty {
            for (index, otherButtonTitle) in otherButtonTitles.enumerated() {
                let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { [weak self] (action) in
                    guard let alertController = self else { return }
                    actionsHandler?(alertController, alertController.firstOtherButtonIndex + index)
                }
                self.addAction(otherAction)
            }
        }
    }
    
    /// Presents a new UIAlertController to the root view controller of a window that available in current app.
    /// Returns the initialized alert controller object.
    @discardableResult
    static func show(title: String? = nil,
                     message: String? = nil,
                     style: UIAlertController.Style = .alert,
                     cancelButtonTitle: String? = nil,
                     destructiveButtonTitle: String? = nil,
                     otherButtonTitles: [String]? = nil,
                     actionsHandler: ((UIAlertController, Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, style: style,
                                                cancelButtonTitle: cancelButtonTitle,
                                                destructiveButtonTitle: destructiveButtonTitle,
                                                otherButtonTitles: otherButtonTitles,
                                                actionsHandler: actionsHandler)
        UIApplication.windowRootViewControllerForAlert?.present(alertController, animated: true)
        return alertController
    }
}

private extension UIApplication {
    
    /// Return the root view controller of a window that available in current app.
    static var windowRootViewControllerForAlert: UIViewController? {
        if let window = UIApplication.availableKeyWindowForAlert {
            return window.rootViewController
        }
        if let window = UIApplication.shared.windows.first {
            return window.rootViewController
        }
        if let window = UIApplication.shared.delegate?.window {
            return window?.rootViewController
        }
        return nil
    }
    
    /// Get the key window, compatible with iOS 13 and multiple scenes.
    static var availableKeyWindowForAlert: UIWindow? {
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
}
