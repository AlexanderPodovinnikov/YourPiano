//
//  AssetTests.swift
//  YourPianoTests
//
//  Created by Alex Po on 12.07.2022.
//

import XCTest
@testable import YourPiano

class AssetTests: XCTestCase {

    // Loading color strings from into a SwiftUI Color struct will always succeed,
    // because if the color doesn’t exist we’ll get a silent log in Xcode’s debug area.
    // So, to make this testable we’re going to load the color using UIKit instead –
    // this will return an optional UIColor, which we can then check against nil
    // to see whether our test passed or failed.

    func testColorsExist() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }

    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }

}
