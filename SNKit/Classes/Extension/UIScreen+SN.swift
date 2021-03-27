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
    
    /// Gets the fit value in current screen based on the specified screen width.
    /// - Parameters:
    ///   - base: The specified screen width.
    ///   - lhs: The adaptation value when the current screen width is greater than the specified screen width.
    ///   - rhs: The adaptation value when the current screen width is less than or equal to the specified screen width.
    /// - Returns: The fit value in current screen.
    static func valueBaseWidth<T>(_ width: CGFloat, lhs: T, rhs: T) -> T {
        return main.minimumLength > width ? lhs : rhs
    }
    
    /// Gets the fit value in current screen based on the 4-inch screen width (320.0pt).
    /// - Parameters:
    ///   - lhs: The adaptation value when the current screen width is greater than the 4-inch screen width.
    ///   - rhs: The adaptation value when the current screen width is less than or equal to the 4-inch screen width.
    /// - Returns: The fit value in current screen.
    static func valueBase4InchWidth<T>(lhs: T, rhs: T) -> T {
        return valueBaseWidth(320.0, lhs: lhs, rhs: rhs)
    }
}
