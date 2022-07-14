//
//  ExtensionTests.swift
//  YourPianoTests
//
//  Created by Alex Po on 14.07.2022.
//

import XCTest
import SwiftUI
@testable import YourPiano

class ExtensionTests: XCTestCase {

    struct TestItem: Equatable {
        let number: Int
    }

    func testSequenceKeyPathSortingSelf() {
        let items = [1, 4, 3, 2, 5]
        let sortedItems = items.sorted(by: \.self)
        XCTAssertEqual(sortedItems, [1, 2, 3, 4, 5], "The sorted items must be ascending.")
    }

    func testSequenceKeyPathSortingCustom() {
        var items = [TestItem]()
        for idx in 0..<5 {
            let item = TestItem(number: idx + 1)
            items.append(item)
        }
        var descendingItems = [TestItem]()
        for idx in 0..<5 {
            let item = TestItem(number: 5 - idx)
            descendingItems.append(item)
        }

        XCTAssertEqual(items.sorted(by: \.number, using: >),
                       descendingItems,
                       "Sorted items must be in descending order.")
    }

    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode(String.self, from: "DecodableString.json")
        XCTAssertEqual(data, "The rain in Spain falls mainly on the Spaniards.",
                       "The string must match the content of DecodableString.json.")
    }

    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
        XCTAssertEqual(data.count, 3,
                       "There should be three entry in the dictionary, decoded from DecodableDictionary.json.")
        XCTAssertEqual(data["Two"], 2, "The value of key 'Two' should be 2")
    }

//  Very interesting!
    func testBindingOnChange() {
        var onChangeFunctionRun = false

        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }

        var storedValue = ""
        let binding = Binding(
            get: { storedValue },
            set: { storedValue = $0}
        )
        let changedBinding = binding.onChange(exampleFunctionToCall)
        changedBinding.wrappedValue = "Test"

        XCTAssertTrue(onChangeFunctionRun, "The onChange() function wasn't run")
    }
}
