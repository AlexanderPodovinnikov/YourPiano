//
//  PerformanceTests.swift
//  YourPianoTests
//
//  Created by Alex Po on 14.07.2022.
//

import XCTest
@testable import YourPiano

class PerformanceTests: BaseTestCase {

    func testAwardCalculationPerformance() throws {
        for _ in 0..<100 {
            try dataController.createSampleData()
        }
        let awards = Array(repeating: Award.allAwards, count: 25).joined()

        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards.")

        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }

}
