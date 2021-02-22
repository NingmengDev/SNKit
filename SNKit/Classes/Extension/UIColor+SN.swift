//
//  UIColor+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public extension UIColor {
    
    /// Random color.
    static var random: UIColor {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return .init(red: red, green: green, blue: blue)
    }
    
    /// Grouped background color.
    static var groupTableBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGroupedBackground
        } else {
            return .groupTableViewBackground
        }
    }
    
    /// Foreground color for separators.
    static var separatorDefault: UIColor {
        if #available(iOS 13.0, *) {
            return .separator
        } else {
            return .from(hex: "#C6C6C8")
        }
    }
    
    /// Hexadecimal value string.
    var hexString: String {
        let components: [Int] = {
            let comps = cgColor.components!.map { Int($0 * 255.0) }
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()
        return String(format: "#%02X%02X%02X", components[0], components[1], components[2])
    }
}

public extension UIColor {
    
    /// Create an UIColor in format RGBA.
    /// - Parameters:
    ///   - red: Red value.
    ///   - green: Green value.
    ///   - blue: Blue value.
    ///   - alpha: Alpha value.
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    /// Create an UIColor in format RGBA.
    /// - Parameters:
    ///   - red: Red value.
    ///   - green: Green value.
    ///   - blue: Blue value.
    ///   - alpha: Alpha value.
    /// - Returns: Color created in format RGBA.
    static func from(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) -> UIColor {
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Create Color from hexadecimal value.
    /// - Parameters:
    ///   - hex: HEX value (example: 0x000000).
    ///   - alpha: Alpha value.
    /// - Returns: Color created from hexadecimal value.
    static func from(hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Create Color from hexadecimal value.
    /// - Parameters:
    ///   - hex: HEX value (example: #FFFFFF).
    ///   - alpha: Alpha value.
    /// - Returns: Color created from hexadecimal value.
    static func from(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var string = ""
        if hex.lowercased().hasPrefix("0x") {
            string = hex.replacingOccurrences(of: "0x", with: "")
        } else if hex.hasPrefix("#") {
            string = hex.replacingOccurrences(of: "#", with: "")
        } else {
            string = hex
        }

        if string.count == 3 { /// Convert hex to 6 digit format if in short format.
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }
        
        if let hexValue = Int(string, radix: 16) {
            return .from(hex: hexValue)
        } else { /// If hex is invalid，return clear color.
            return .clear
        }
    }
}
