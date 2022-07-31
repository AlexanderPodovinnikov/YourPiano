//
//  DataController.swift
//  YourPiano
//
//  Created by Alex Po on 28.06.2022.
//

import CoreData
import SwiftUI
import CoreSpotlight
import WidgetKit

/// An environment singleton responsible for managing Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {

    // We need to cache the model and share them between multiple containers for testing purposes,
    // so Core Data won't load it twice!
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer

    /// The UserDefaults suite as a local property
    let defaults: UserDefaults

    /// Loads and saves whether our unlock has been purchased.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }
        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }

    /// Initializes a data controller, either in memory (for  testing and previewing),
    /// or on permanent storage.
    /// 
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults suite where user data should be stored.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        // Create in-memory database by writing to /dev/null
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // so if we’re using a real database we redirect Core Data to use our app group’s container
            let groupID = "group.com.Po.Alex.YourPiano"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("Main.sqlite")
            }
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            // Check the box "Use with iCloud" in CoreData configuration
            // and enable this to sync data across all devices
            self.container.viewContext.automaticallyMergesChangesFromParent = true

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()

                // Dramatically speeds up all UI tests
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }
    // for preview and testing
    /// Creates example projects and items to make manual testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext

        for projectCounter in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Section \(projectCounter)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()

            for itemCounter in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        try viewContext.save()
    }

    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all the attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            // And force all widgets to update.
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Deletes given item or project.
    /// - Parameters:
    ///   - object: Item or Project to delete
    func delete(_ object: NSManagedObject) {
        let id = object.objectID.uriRepresentation().absoluteString

        if object is Item {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        } else {
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        }
        container.viewContext.delete(object)
    }

    // Core Data runs the batch delete request on the persistent store,
    // without updating the managed object context reading from that store.
    // To fix this, we need a method, that gets the result of calling execute(),
    // reads out the object IDs of the delete objects, then merges those into our live view context.

    // deletes objects in right way correctly updates data context)
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }

    }
    // For testing only,
    // and I don't know what happens with Spotlight searchable items.
    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        delete(fetchRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        delete(fetchRequest2)
    }

    /// Counts elements in a fetch request.
    /// - Parameter fetchRequest: A fetch request to count.
    /// - Returns: Number of elements
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    /// Adds a new project.
    /// - Returns: True if adding project succeed, false if it failed.
    @discardableResult func addProject() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3

        if canCreate {
            let project = Project(context: container.viewContext)
            project.closed = false
            project.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }

    /// Creates a Spotlight record for an item, sends it toSpotlight for indexing and saves an item.
    /// - Parameter item: An item to store and indexing in Spotlight.
    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString

        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.title
        attributeSet.contentDescription = item.detail

        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        save()
    }

    /// Returns an item by its identifier provided by Spotlight
    /// - Parameter uniqueIdentifier: A Spotlight identifier of a searched item
    /// - Returns: an instance of a searched item
    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else { return nil }
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }
        return try? container.viewContext.existingObject(with: id) as? Item
    }

    /// Creates a request to fetch a limited number of top priority not completed items
    /// from open projects.
    /// - Parameter count: Number of  items you want to fetch.
    /// - Returns: A fetch request.
    func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
        let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()

        let completedPredicate = NSPredicate(format: "completed = false")
            let openPredicate = NSPredicate(format: "project.closed = false")
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
            itemRequest.predicate = compoundPredicate

            itemRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \Item.priority, ascending: false)
            ]

            itemRequest.fetchLimit = count

        return itemRequest
    }

    /// Fetches a result of given Core Data request.
    /// - Returns: An array of T
    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }

    // preview data
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }

        return dataController
    }()
}
