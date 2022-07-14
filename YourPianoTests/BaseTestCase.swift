//
//  YourPianoTests.swift
//  YourPianoTests
//
//  Created by Alex Po on 12.07.2022.
//

import CoreData
import XCTest
@testable import YourPiano

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
