//
//  Misc+SN.swift
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
    
    /// Converts Array, Dictionary, Set, or String to JSON String.
    /// - Parameter prettify: Set true to prettify string, default is false.
    /// - Returns: Optional JSON String (if applicable).
    func toJSON(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options: JSONSerialization.WritingOptions = prettify ? [.prettyPrinted] : []
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: data, encoding: .utf8)
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

public extension Dictionary {
    
    /// Returns a new dictionary containing the results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure. `transform` accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
    /// - Returns: A dictionary containing the transformed elements of this sequence.
    func mapKeysAndValues<K, T>(_ transform: ((key: Key, value: Value)) throws -> (K, T)) rethrows -> [K : T] {
        return [K: T](uniqueKeysWithValues: try map(transform))
    }
    
    /// Returns a new dictionary containing the non-`nil` results of calling the given transformation with each element of this sequence.
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: A dictionary of the non-`nil` results of calling `transform` with each element of the sequence.
    func compactMapKeysAndValues<K, T>(_ transform: ((key: Key, value: Value)) throws -> (K, T)?) rethrows -> [K : T] {
        return [K: T](uniqueKeysWithValues: try compactMap(transform))
    }
    
    /// Returns a new dictionary containing the key-value pairs of the dictionary that satisfy the given keys.
    /// - Parameter includedkeys: An array of keys that indicates which key-value pairs should be included in the returned dictionary.
    /// - Returns: A new dictionary that contains the specified keys only.
    func filter(includedkeys: [Key]) -> [Key : Value] {
        includedkeys.reduce(into: [Key: Value]()) { result, key in
            result[key] = self[key]
        }
    }
}

public extension Optional {
    
    /// The absence of a value returns true.
    var isNil: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
    
    /// The absence of a value returns false.
    var isNotNil: Bool {
        return isNil ? false : true
    }
}
