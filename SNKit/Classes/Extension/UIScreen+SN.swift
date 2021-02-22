//
//  UIScreen+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public extension UIScreen {
    
    /// Get the screen width.
    var width: CGFloat {
        return bounds.width
    }
    
    /// Get the screen height.
    var height: CGFloat {
        return bounds.height
    }
    
    /// Get the maximum screen length.
    var maximumLength: CGFloat {
        return max(width, height)
    }
    
    /// Get the minimum screen length.
    var minimumLength: CGFloat {
        return min(width, height)
    }
    
    /// Check if current screen is a Retina display.
    var isRetina: Bool {
        return responds(to: #selector(UIScreen.displayLink(withTarget:selector:))) && scale == 2.0
    }
    
    /// Check if current screen is a Retina HD display.
    var isRetinaHD: Bool {
        return responds(to: #selector(UIScreen.displayLink(withTarget:selector:))) && scale == 3.0
    }
}

public extension UIScreen {
    
    /// 以指定的屏幕宽度为基准获取屏幕适配值
    /// - Parameters:
    ///   - base: 指定的屏幕宽度
    ///   - lhs: 当前屏幕宽度大于指定的屏幕宽度时的适配值
    ///   - rhs: 当前屏幕宽度小于等于指定的屏幕宽度时的适配值
    /// - Returns: 屏幕适配值
    static func valueBaseWidth<T>(_ width: CGFloat, lhs: T, rhs: T) -> T {
        return main.minimumLength > width ? lhs : rhs
    }
    
    /// 以4.0英寸屏幕宽度为基准获取屏幕适配值
    /// - Parameters:
    ///   - lhs: 当前屏幕宽度大于4.0英寸屏幕宽度时的适配值
    ///   - rhs: 当前屏幕宽度小于等于4.0英寸屏幕宽度时的适配值
    /// - Returns: 屏幕适配值
    static func valueBase4InchWidth<T>(lhs: T, rhs: T) -> T {
        return valueBaseWidth(320.0, lhs: lhs, rhs: rhs)
    }
}
