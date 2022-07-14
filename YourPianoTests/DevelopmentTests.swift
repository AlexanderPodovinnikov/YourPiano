//
//  DevelopmentTests.swift
//  YourPianoTests
//
//  Created by Alex Po on 13.07.2022.
//
// When Xcode runs our test suite, it creates one instance of the XCTestCase class
// for each of our tests, then runs it back in a shared instance of the app.
// This is efficient to run, but comes with an important proviso:
// if you use a singleton like DataController.preview,
// that gets shared everywhere in all your tests.

// As a result, we need to be careful how we use them: if you modify the preview
// then attempt to run tests against specific parts of its state, you will hit problems.
// Yes, write tests for any example objects you use in your previews,
// but don’t try to make assertions about the preview data controller itself.

import XCTest
import CoreData
@testable import YourPiano

class DevelopmentTests: BaseTestCase {

    func testSampleDataCreationWorks() throws {
        try dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 5, "There should be 5 sample projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items.")
    }

    func testDeleteAllClearsEverything() throws {
        try dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 0, "DeleteAll should leave 0  projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "DeleteAll should leave 0 items.")
    }

    func testExampleProjectIsClosed() {
        let project = Project.example
        XCTAssertTrue(project.closed, "The example project should be closed.")
    }

    func testExampleItemIsHighPriority() {
        let item = Item.example
        XCTAssertEqual(item.priority, 3, "The example item should be high priority.")
    }

}
