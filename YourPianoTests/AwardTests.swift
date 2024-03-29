//
//  AwardTests.swift
//  YourPianoTests
//
//  Created by Alex Po on 12.07.2022.
//

import CoreData
import XCTest
@testable import YourPiano

class AwardTests: BaseTestCase {
    let awards = Award.allAwards

    func testAwardsIDMatchName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award id should always match its name.")
        }
    }

    func testNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New users should have no earned awards.")
        }
    }

    func testItemAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var items = [Item]()

            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                items.append(item)
            }
            let matches = awards.filter { award in
                award.criterion == "items" && dataController.hasEarned(award: award)
            }
            XCTAssertEqual(matches.count, count + 1, "Adding \(value) items should unlock \(count + 1) awards.")
            for item in items {
                dataController.delete(item)
            }
        }
    }

    func testCompletedAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var items = [Item]()

            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                item.completed = true
                items.append(item)
            }
            let matches = awards.filter { award in
                award.criterion == "complete" && dataController.hasEarned(award: award)
            }
            XCTAssertEqual(matches.count, count + 1, "Completing \(value) items should unlock \(count + 1) awards.")
            for item in items {
                dataController.delete(item)
            }
        }
    }
}
