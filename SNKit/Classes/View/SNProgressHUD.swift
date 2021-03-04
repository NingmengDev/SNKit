//
//  SNProgressHUD.swift
//  SNKit
//
//  Created by SN on 2020/3/2.
//  Copyright © 2020 Apple. All rights reserved.
//

import MBProgressHUD

/// SNProgressHUD is a subclass of MBProgressHUD.
/// Provides some convenient methods to displays a simple HUD.
/// For more information of usage, see also MBProgressHUD.
public final class SNProgressHUD : MBProgressHUD {
    
    private enum Status : Int {
        case textOnly
        case loading
        case loadingTextOnly
        case success
        case info
        case error
    }
    
    private struct Constant {
        static let layerCornerRadius: CGFloat = 8.0
        static let backgroundColorAlpha: CGFloat = 1.0
        static let delayTimeInterval: TimeInterval = 1.5
        static let bundleName: String = "SNProgressHUD.bundle"
        static let hideDelayTimerKey: String = "hideDelayTimer"
    }
    
    private static let shared = SNProgressHUD(frame: UIScreen.main.bounds)
    private override init(view: UIView) { super.init(view: view) }
        
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentColor = UIColor.white
        self.removeFromSuperViewOnHide = true
        self.label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
        self.bezelView.layer.cornerRadius = Constant.layerCornerRadius
        self.bezelView.color = UIColor(white: 0.1, alpha: Constant.backgroundColorAlpha)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func windowHUD() -> SNProgressHUD {
        let hud = SNProgressHUD.shared
        if let superview = hud.superview {
            superview.bringSubviewToFront(hud)
        } else if let window = UIApplication.windowForHUD {
            hud.frame = window.bounds
            window.addSubview(hud)
            hud.show(animated: true)
        }
        return hud
    }
    
    private static func viewHUD(_ view: UIView) -> SNProgressHUD {
        guard let hud = SNProgressHUD.forView(view) as? SNProgressHUD else {
            return SNProgressHUD.showAdded(to: view, animated: true)
        }
        hud.superview?.bringSubviewToFront(hud)
        return hud
    }
    
    private static func image(for status: Status) -> UIImage? {
        var name: String?
        switch status {
        case .success:
            name = "sn_hud_done"
        case .info:
            name = "sn_hud_info"
        case .error:
            name = "sn_hud_error"
        default:
            break
        }
        guard let validName = name else { return nil }
        guard let bundlePath = Bundle.main.path(forResource: Constant.bundleName, ofType: nil) else { return nil }
        if #available(iOS 13.0, *) {
            return UIImage(named: validName, in: Bundle(path: bundlePath), with: nil)?.withRenderingMode(.alwaysTemplate)
        } else {
            return UIImage(named: validName, in: Bundle(path: bundlePath), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    private func show(_ text: String? = nil, status: Status) {
        self.label.text = text
        switch status {
        case .loading:
            self.mode = .indeterminate
        case .loadingTextOnly:
            self.mode = .text
        default:
            if status == .textOnly {
                self.mode = .text
            } else {
                let image = SNProgressHUD.image(for: status)
                self.customView = UIImageView(image: image)
                self.mode = .customView
            }
            self.hide(animated: true, afterDelay: Constant.delayTimeInterval)
        }
    }
}

private extension UIApplication {
    
    /// Return a window that available in current app.
    static var windowForHUD: UIWindow? {
        if let window = UIApplication.keyWindowForHUD {
            return window
        }
        if let window = UIApplication.shared.windows.first {
            return window
        }
        return UIApplication.shared.delegate?.window ?? nil
    }
    
    /// Get the key window, compatible with iOS 13 and multiple scenes.
    static var keyWindowForHUD: UIWindow? {
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

/// Provides some convenient methods to display or dismiss a shared HUD in window.
public extension SNProgressHUD {
    
    /// Displays a loading hud containing a activity indicator and an optional tips text.
    /// After displaying, the hud will be removed until invoking the method named "dismiss" manually.
    /// - Parameter text: The loading tips text.
    static func showLoading(_ text: String? = nil) {
        SNProgressHUD.windowHUD().show(text, status: .loading)
    }
    
    /// Displays a loading hud containing only a tips text.
    /// After displaying, the hud will be removed until invoking the method named "dismiss" manually.
    /// - Parameter text: The loading tips text.
    static func showLoadingOnly(_ text: String) {
        SNProgressHUD.windowHUD().show(text, status: .loadingTextOnly)
    }

    /// Hides the shared HUD from window immediately.
    static func dismiss() {
        SNProgressHUD.shared.hide(animated: true)
    }
    
    /// Hides the shared HUD from window after a delay.
    /// - Parameter delay: Delay in seconds until the HUD is hidden.
    static func dismiss(after delay: TimeInterval) {
        SNProgressHUD.shared.hide(animated: true, afterDelay: delay)
    }
    
    /// Displays a hud containing only a tips text.
    /// After displaying, the hud will be removed automatically after 1.5s delay.
    /// - Parameter text: The tips text.
    static func showOnly(_ text: String) {
        SNProgressHUD.windowHUD().show(text, status: .textOnly)
    }
    
    /// Displays a hud containing a done status image and a tips text.
    /// After displaying, the hud will be removed automatically after 1.5s delay.
    /// - Parameter text: The tips text of done status.
    static func showSuccess(_ text: String) {
        SNProgressHUD.windowHUD().show(text, status: .success)
    }
    
    /// Displays a hud containing a alerting status image and a tips text.
    /// After displaying, the hud will be removed automatically after 1.5s delay.
    /// - Parameter text: The tips text of alerting status.
     static func showInfo(_ text: String) {
        SNProgressHUD.windowHUD().show(text, status: .info)
    }
    
    /// Displays a hud containing a error status image and a tips text.
    /// After displaying, the hud will be removed automatically after 1.5s delay.
    /// - Parameter text: The tips text of error status.
    static func showError(_ text: String) {
        SNProgressHUD.windowHUD().show(text, status: .error)
    }
}

/// Provides some convenient methods to display or dismiss a HUD in a given view.
public extension SNProgressHUD {
    
    /// Displays a loading hud containing a activity indicator and an optional tips text.
    /// After displaying, the hud will be removed until invoking the method named "dismiss(from:)" manually.
    /// - Parameters:
    ///   - text: The loading tips text.
    ///   - view: The view that the HUD will be added to.
    static func showLoading(_ text: String? = nil, in view: UIView) {
        SNProgressHUD.viewHUD(view).show(text, status: .loading)
    }
    
    /// Displays a loading hud containing only a tips text.
    /// After displaying, the hud will be removed until invoking the method named "dismiss(from:)" manually.
    /// - Parameters:
    ///   - text: The loading tips text.
    ///   - view: The view that the HUD will be added to.
    static func showLoadingOnly(_ text: String, in view: UIView) {
        SNProgressHUD.viewHUD(view).show(text, status: .loadingTextOnly)
    }
    
    /// Hides the HUD from the given view immediately.
    /// - Parameter view: The view that the HUD added to.
    static func dismiss(from view: UIView) {
        SNProgressHUD.hide(for: view, animated: true)
    }
    
    /// Hides the HUD from the given view after a delay.
    /// - Parameters:
    ///   - view: The view that the HUD added to.
    ///   - delay: Delay in seconds until the HUD is hidden.
    static func dismiss(from view: UIView, after delay: TimeInterval) {
        guard let hud = SNProgressHUD.forView(view) else {
            return
        }
        hud.hide(animated: true, afterDelay: delay)
    }
    
    /// Displays a hud containing only a tips text.
    /// After displaying, the hud will be removed automatically after 1.5s delay.
    /// - Parameters:
    ///   - text: The tips text.
    ///   - view: The view that the HUD will be added to.
    static func showOnly(_ text: String, in view: UIView) {
        SNProgressHUD.viewHUD(view).show(text, status: .textOnly)
    }
    
    /// Displays a hud containing a done status image and a tips text.
    /// After displaying, the hud will be removed automatically after 1.5s delay.
    /// - Parameters:
    ///   - text: The tips text of done status.
    ///   - view: The view that the HUD will be added to.
    static func showSuccess(_ text: String, in view: UIView) {
        SNProgressHUD.viewHUD(view).show(text, status: .success)
    }
    
    /// Displays a hud containing a alerting status image and a tips text.
    /// After displaying, the hud will be removed automatically after 1.5s delay.
    /// - Parameters:
    ///   - text: The tips text of alerting status.
    ///   - view: The view that the HUD will be added to.
    static func showInfo(_ text: String, in view: UIView) {
        SNProgressHUD.viewHUD(view).show(text, status: .info)
    }

    /// Displays a hud containing a error status image and a tips text.
    /// After displaying, the hud will be removed automatically after 1.5s delay.
    /// - Parameters:
    ///   - text: The tips text of error status.
    ///   - view: The view that the HUD will be added to.
    static func showError(_ text: String, in view: UIView) {
        SNProgressHUD.viewHUD(view).show(text, status: .error)
    }
}
