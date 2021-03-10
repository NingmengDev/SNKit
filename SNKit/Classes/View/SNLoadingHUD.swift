//
//  SNLoadingHUD.swift
//  SNKit
//
//  Created by SN on 2020/3/2.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

public final class SNLoadingHUD : UIView {
    
    private struct Defaults {
        static let offset: CGFloat = -10.0
        static let duration = TimeInterval(UINavigationController.hideShowBarDuration)
    }
    
    private var activityIndicator: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .gray
        }
        let indicator = UIActivityIndicatorView(style: style)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .center
        return label
    }()

    /// 用于调节竖直方向上的偏移量
    private var elementsCenterYConstraint: NSLayoutConstraint?
    /// 延时关闭计时器
    private weak var hideDelayTimer: Timer?
    
    // MARK: - Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(self.activityIndicator)
        self.addSubview(self.statusLabel)
        
        self.elementsCenterYConstraint = activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: Defaults.offset)
        self.statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10.0).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.elementsCenterYConstraint?.isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private static func viewHUD(_ view: UIView) -> SNLoadingHUD {
        /// view中尚未含有hud，则新建一个
        guard let hud = SNLoadingHUD.hud(for: view) else {
            let hud = SNLoadingHUD(frame: view.bounds)
            view.addSubview(hud)
            return hud
        }
        /// view中已含有一个hud，则
        /// 移除进行中的动画
        hud.layer.removeAllAnimations()
        /// 恢复默认透明度
        hud.alpha = 1.0
        /// 取消延时关闭
        hud.hideDelayTimer?.invalidate()
        /// 置顶
        hud.frame = view.bounds
        view.bringSubviewToFront(hud)
        return hud
    }
    
    @objc private func dismissAnimated() {
        UIView.animate(withDuration: Defaults.duration, animations: {
            self.alpha = 0.0
        }) { (finished) in
            if finished {
                self.activityIndicator.stopAnimating()
                self.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Public
    
    /// Creates a new loading HUD, adds it to provided view and shows it.
    /// - Parameters:
    ///   - view: The view that the HUD will be added to.
    ///   - status: The tips text that displayed below indicator.
    ///   - tint: The tint color of the hud.
    ///   - verticalOffset: To adjust the offset in the vertical direction.
    public static func show(in view: UIView, status: String, tint: UIColor = .gray, verticalOffset: CGFloat = 0.0) {
        let hud = SNLoadingHUD.viewHUD(view)
        hud.statusLabel.text = status
        hud.statusLabel.textColor = tint
        hud.activityIndicator.color = tint
        hud.activityIndicator.startAnimating()
        hud.elementsCenterYConstraint?.constant = Defaults.offset + verticalOffset
    }

    /// Finds the top-most HUD subview and returns it.
    /// - Parameter view: The view that is going to be searched.
    /// - Returns: A reference to the last HUD subview discovered.
    public static func hud(for view: UIView) -> SNLoadingHUD? {
        for hud in view.subviews.reversed() {
            if hud.isKind(of: self) {
                return hud as? SNLoadingHUD
            }
        }
        return nil
    }
    
    /// Hides the HUD after a delay.
    /// - Parameters:
    ///   - view: The view that the HUD added to.
    ///   - delay: Delay in seconds until the HUD is hidden.
    public static func dismiss(from view: UIView, delay: TimeInterval = 0.0) {
        guard let hud = SNLoadingHUD.hud(for: view) else { return }
        /// 移除正在进行中的动画
        hud.layer.removeAllAnimations()
        /// 移除前一个计时器
        hud.hideDelayTimer?.invalidate()
        /// 不延时，则直接关闭
        guard delay > 0.0 else {
            hud.dismissAnimated()
            return
        }
        /// 构建计时器延时关闭
        let timer = Timer(timeInterval: delay, target: hud,
                          selector: #selector(dismissAnimated),
                          userInfo: nil, repeats: false)
        RunLoop.current.add(timer, forMode: .common)
        hud.hideDelayTimer = timer
    }
}
