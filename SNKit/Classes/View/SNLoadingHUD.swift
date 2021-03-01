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
        static let status: String = "正在载入"
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
    private weak var elementsCenterYConstraint: NSLayoutConstraint?
    /// 延时关闭计时器
    private weak var hideDelayTimer: Timer?
    
    // MARK: - Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(self.activityIndicator)
        self.addSubview(self.statusLabel)
        
        self.addConstraint(NSLayoutConstraint(item: self.activityIndicator, attribute: .centerX, relatedBy: .equal,
                                              toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: self.statusLabel, attribute: .centerX, relatedBy: .equal,
                                              toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: self.statusLabel, attribute: .top, relatedBy: .equal,
                                              toItem: self.activityIndicator, attribute: .bottom, multiplier: 1.0, constant: 10.0))
        let centerYConstraint = NSLayoutConstraint(item: self.activityIndicator, attribute: .centerY, relatedBy: .equal,
                                                   toItem: self, attribute: .centerY, multiplier: 1.0, constant: Defaults.offset)
        self.addConstraint(centerYConstraint)
        self.elementsCenterYConstraint = centerYConstraint
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private class func viewHUD(_ view: UIView) -> SNLoadingHUD {
        /// view中尚未含有hud，则新建一个
        guard let hud = SNLoadingHUD.hud(for: view) else {
            let hud = SNLoadingHUD(frame: view.bounds)
            view.addSubview(hud)
            return hud
        }
        
        /// view中尚已含有一个hud，则
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
    
    /// 显示一个loading的hud，使用默认的提示文本 - "正在载入"
    /// - Parameters:
    ///   - view: 用于显示的view
    ///   - tint: 显示颜色
    ///   - verticalOffset: 竖直方向的调整
    public static func show(in view: UIView, tint: UIColor = .gray, verticalOffset: CGFloat = 0.0) {
        self.show(in: view, status: Defaults.status, tint: tint, verticalOffset: verticalOffset)
    }

    /// 显示一个loading的hud，可指定提示文本
    /// - Parameters:
    ///   - view: 用于显示的view
    ///   - status: 提示文本
    ///   - tint: 显示颜色
    ///   - verticalOffset: 竖直方向的调整
    public static func show(in view: UIView, status: String, tint: UIColor = .gray, verticalOffset: CGFloat = 0.0) {
        let hud = SNLoadingHUD.viewHUD(view)
        hud.statusLabel.text = status
        hud.statusLabel.textColor = tint
        hud.activityIndicator.color = tint
        hud.activityIndicator.startAnimating()
        hud.elementsCenterYConstraint?.constant = Defaults.offset + verticalOffset
    }
    
    /// 获取某个view上已存在的hud
    /// - Parameter view: 用于显示的view
    /// - Returns: 已存在的hud
    public static func hud(for view: UIView) -> SNLoadingHUD? {
        for hud in view.subviews.reversed() {
            if hud.isKind(of: self) {
                return hud as? SNLoadingHUD
            }
        }
        return nil
    }

    /// 移除某个view上已存在的hud
    /// - Parameters:
    ///   - view: 用于显示的view
    ///   - delay: 延迟几秒执行
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
