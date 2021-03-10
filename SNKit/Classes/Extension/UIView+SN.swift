//
//  UIView+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public extension UIView {
    
    /// Random color, for debugging.
    private static var debugColor: UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// For debugging, set random background color for the view and its subviews.
    /// - Parameter view: Debugging view.
    static func debugInColor(_ view: UIView) {
        view.backgroundColor = UIView.debugColor
        for subview in view.subviews {
            subview.backgroundColor = UIView.debugColor
        }
    }
}

public extension UIView {
    
    private typealias UIViewTapGestureHandler = (UITapGestureRecognizer) -> Void
    private static var tapGestureHandlerAssociatedKey = "UIViewTapGestureHandler"

    /// Convenience, attaching a tap gesture recognizer to the view.
    /// - Parameter handler: A block to handle the gesture recognized by the receiver.
    func tapAction(_ handler: ((UITapGestureRecognizer) -> Void)?) {
        self.tapGestureHandler = handler
        self.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(tapGestureRecognizerEvent(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private var tapGestureHandler: UIViewTapGestureHandler? {
        set { objc_setAssociatedObject(self, &UIView.tapGestureHandlerAssociatedKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
        get { return objc_getAssociatedObject(self, &UIView.tapGestureHandlerAssociatedKey) as? UIViewTapGestureHandler }
    }
    
    @objc private func tapGestureRecognizerEvent(_ gestureRecognizer: UITapGestureRecognizer) {
        self.tapGestureHandler?(gestureRecognizer)
    }
}
