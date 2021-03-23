//
//  String+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

public extension String {
    
    /// Returns a new string containing the characters of the String at the given index.
    /// - Parameter at: The value must lie within the bounds of the String.
    /// - Returns: The substring at index.
    func substring(at: Int) -> String {
        let start = index(startIndex, offsetBy: at)
        return String(self[start])
    }
    
    /// Returns a new string containing the characters of the String from the one at a given index to the end.
    /// - Parameter from: The value must lie within the bounds of the String, or be equal to the length of the String.
    /// - Returns: The substring from index.
    func substring(from: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        return String(self[start...])
    }
    
    /// Returns a new string containing the characters of the String up to, but not including, the one at a given index.
    /// - Parameter to: The value must lie within the bounds of the String, or be equal to the length of the String.
    /// - Returns: The substring to index.
    func substring(to: Int) -> String {
        let end = index(startIndex, offsetBy: to)
        return String(self[..<end])
    }
    
    /// Returns a string object containing the characters of the String that lie within a given range.
    /// - Parameter range: The range must not exceed the bounds of the String.
    /// - Returns: The substring between the range.
    func substring(with range: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
    
    /// Returns a new string containing the characters of the String from the one at a given index with the length.
    /// - Parameters:
    ///   - from: The value must lie within the bounds of the String, or be equal to the length of the String.
    ///   - length: Amount of characters to be sliced after given index.
    /// - Returns: The substring from index and length.
    func substring(from: Int, length: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: length)
        return String(self[start..<end])
    }
    
    /// Creates a URL instance from the provided string, encoding with the character set, and relative to the base URL.
    /// - Parameters:
    ///   - percentEncoding: The characters not replaced in the string.
    ///   - url: The base URL for the URL instance.
    /// - Returns: An URL.
    func toURL(byAdding percentEncoding: CharacterSet? = nil, relativeTo url: URL? = nil) -> URL? {
        guard let set = percentEncoding, let encoded = addingPercentEncoding(withAllowedCharacters: set) else {
            return URL(string: self, relativeTo: url)
        }
        return URL(string: encoded, relativeTo: url)
    }
}
