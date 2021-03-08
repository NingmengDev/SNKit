//
//  SNNavigationBar.swift
//  SNKit
//
//  Created by SN on 2020/3/3.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

/// A customized navigation bar to control the bar background color.
public final class SNNavigationBar : UIView {
    
    /// To customize title, title view, bar button items, etc.
    public let navigationItem = UINavigationItem(title: "")
    
    /// To customize tint color for the bar's button items.
    public var barButtonItemTintColor: UIColor? {
        set { navigationBar.tintColor = newValue }
        get { return navigationBar.tintColor }
    }
    
    /// To customize bar background color for the bar. Same as 'backgroundColor'.
    public var barTintColor: UIColor? {
        set { backgroundColor = newValue }
        get { return backgroundColor }
    }
    
    /// To customize display attributes for the bar’s title text.
    public var titleTextAttributes: [NSAttributedString.Key : Any]? {
        set { navigationBar.titleTextAttributes = newValue }
        get { return navigationBar.titleTextAttributes }
    }
    
    /// To display or hide the line at the bottom of the bar.
    public var isShadowImageHidden: Bool {
        set { navigationBar.shadowImage = newValue ? UIImage() : nil }
        get { return navigationBar.shadowImage == nil ? false : true }
    }
    
    /// The internal real navigation bar.
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.sizeToFit()
        return navigationBar
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configurateAndAddNavigationBar()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configurateAndAddNavigationBar()
    }
    
    private func configurateAndAddNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.navigationBar.pushItem(self.navigationItem, animated: false)
        self.addSubview(self.navigationBar)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        var frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: 0.0)
        frame.size.height = max(44.0, self.navigationBar.bounds.height)
        frame.origin.y = self.bounds.height - frame.size.height
        self.navigationBar.frame = frame
    }
}
