//
//  Collection+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

public extension Collection {
    
    /// A Boolean value indicating whether the collection is not empty.
    var isNotEmpty: Bool {
        return isEmpty ? false : true
    }
    
    /// The full range of the collection.
    var fullRange: Range<Index> {
        return startIndex..<endIndex
    }
    
    /// Accesses the element at a given index in safe mode (nil if self is empty or out of range).
    /// - Parameter index: Index of element to access.
    /// - Returns: The element at the given index.
    func element(safeAt index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array {
    
    /// Replaces the element at index with anElement. Calling with the index exceed the bounds of the array has no effect.
    /// - Parameters:
    ///   - index: The index of the element to be replaced.
    ///   - anElement: The element with which to replace the element at index index in the array.
    mutating func replaceElement(at index: Int, with anElement: Element) {
        guard indices.contains(index) else { return }
        replaceSubrange(index...index, with: [anElement])
    }
}

public extension String {
    
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
}
