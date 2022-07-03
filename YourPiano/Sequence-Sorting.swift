//
//  Secuence-Sorting.swift
//  YourPiano
//
//  Created by Alex Po on 03.07.2022.
//

import Foundation

extension Sequence {
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        self.sorted {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }
}
