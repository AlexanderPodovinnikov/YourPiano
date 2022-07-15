//
//  YourPianoUITests.swift
//  YourPianoUITests
//
//  Created by Alex Po on 14.07.2022.
//

import XCTest

class YourPianoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state -
        // such as interface orientation - required for your tests before they run.
        // The setUp method is a good place to do this.
    }

    func testAppHas4Tabs() throws {
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }

    func testOpenTabAddsProjects() {
        app.buttons["In progress"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially.")

        for tapCount in 1...5 {
            app.buttons["Add Section"].tap()
            XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) row(s) in the list.")
        }
    }

    func testAddingItemInsertsRow() {
        app.buttons["In progress"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially.")

        app.buttons["Add Section"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 row for 1 project.")
        app.buttons["Add New Item"].tap()
        XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 rows after inserting new item.")
    }

    func testEditingProjectUpdatesCorrectly() {
        app.buttons["In progress"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially.")

        app.buttons["Add Section"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 row for 1 project.")

        app.buttons["New Section"].tap()
        app.textFields["Section name"].tap()

        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        // This should be the "< Back" button. Works but looks like a workaround:
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["New Section 2"].exists,
                      "The edited project name should be visible in the list.")
    }

    func testOpeningAndClosingMovesProject() {
        app.buttons["In progress"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows initially.")

        app.buttons["Add Section"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 row for 1 project.")

        app.buttons["New Section"].tap()
        app.buttons["Close this section"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no rows after closing project.")

        app.buttons["Completed"].tap()
        XCTAssertTrue(app.buttons["New Section"].exists, "There should be one closed project.")

        app.buttons["New Section"].tap()
        app.buttons["Reopen this section"].tap()
        XCTAssertFalse(app.buttons["New Section"].exists, "There should be no project in the list after reopening it.")

        app.buttons["In progress"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be one reopened project.")
    }

    func testEditingItemUpdatesCorrectly() {
        // Go to Open Projects and add one project and one item.
        testAddingItemInsertsRow()

        app.buttons["New Item"].tap()
        app.textFields["Item name"].tap()

        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        // This should be the "< Back" button. Works but looks like a workaround:
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["New Item 2"].exists,
                      "The edited item name should be visible in the list.")
    }

    func testAllAwardsShowLockedAlert() {
        app.buttons["Awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists,
                          "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }

    func testOpeningAwardShowsUnlockedAlert() {
        // Go to Open Projects and add one project and one item.
        testAddingItemInsertsRow()
        app.buttons["Awards"].tap()
        app.scrollViews.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.alerts["Unlocked First Steps"].exists, "First award should be unlocked.")

    }

    func testSwipeDeletesItem() {
        // Go to Open Projects and add one project and one item.
        testAddingItemInsertsRow()

        app.buttons["New Item"].swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 row after deleting item.")
    }
}
