//
//  Secuence-Sorting.swift
//  YourPiano
//
//  Created by Alex Po on 03.07.2022.
//

import Foundation

extension Sequence {

    /// Sorts any sequence by element property path according to the given comparison function .
    ///
    /// - rethrows if comparison function throws
    /// - Parameters:
    ///   - keyPath: A path to elements properties, that should be compared.
    ///   - areInIncreasingOrder: A comparison function.
    /// - Returns: A sorted array of sequence elements.
    func sorted<Value>(
            by keyPath: KeyPath<Element, Value>,
            using areInIncreasingOrder: (Value, Value) throws -> Bool
    ) rethrows -> [Element] {

        try self.sorted {
            try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }

    /// Sorts sequence that is Comparable by element property path.
    /// - Parameter keyPath: A path to elements properties, that should be compared.
    /// - Returns: A sorted array of sequence elements.
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        self.sorted(by: keyPath, using: <)
    }
}
