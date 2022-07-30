//
//  HomeViewModel.swift
//  YourPiano
//
//  Created by Alex Po on 16.07.2022.
//

import Foundation
import CoreData

// Knowing bugs (iOS 15.5 Swift 5):
// 1. Added item is not visible in the View until is edited - fixed by adding 'item.completed = false'
// in ProjectViewModel method addItem(to:)
//
// 2. Changing project attributes such as "closed" or "color"
// is not visible in items list without calling implemented
// in ViewModel refetching method (deleted) - temporary solution:
//
// 'closed' issue fixed by adding 'item.completed = item.completed' for each project's item
// in EditProjectView 'close' Button method - may be thrown out by the compiler during optimization.
//
// 'color' issue fixed by adding the observed property viewModel to ItemsListView. Property isn't used so...
//
// POSSIBLE FRC GLITCH SOLUTION: Apparently the problem is how FRC is
// monitoring changes when predicate has a condition based on a relationship
// but not an owned property. Try to add a property for Item entity(!) -
// projectIsClosed and set this property from the projects side.

extension HomeView {

    /// An object to manipulate data, presented in Home View.
    class ViewModel: ObservableObject {

        // To make one generic class instead of this two!

        // swiftlint:disable:next nesting
        class ProjectsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
            let parent: ViewModel

            init(parent: ViewModel) {
                self.parent = parent
            }
            func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
                if let newProjects = controller.fetchedObjects as? [Project] {
                    parent.projects = newProjects
                }
            }
        }
        // swiftlint:disable:next nesting
        class ItemsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
            let parent: ViewModel

            init(parent: ViewModel) {
                self.parent = parent
            }
            func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
                if let newItems = controller.fetchedObjects as? [Item] {
                    parent.items = newItems
                    parent.upNext = parent.items.prefix(3)
                    parent.moreToExplore = parent.items.dropFirst(3)
                }
            }
        }

        private let projectsController: NSFetchedResultsController<Project>
        private let itemsController: NSFetchedResultsController<Item>
        private var projectsControllerDelegate: ProjectsControllerDelegate?
        private var itemsControllerDelegate: ItemsControllerDelegate?

        /// An array of fetched projects
        @Published var projects = [Project]()
        /// An array of fetched 10 items of highest priority from open projects
        @Published var items = [Item]()

        /// An item we selected outside the app, e.g. in Spotlight results
        @Published var selectedItem: Item?

        var dataController: DataController

        /// A slice, containing first 3 hi priority items
        @Published var upNext = ArraySlice<Item>()

        /// A slice, containing up to 7 more items from the fetch request results
        @Published var moreToExplore = ArraySlice<Item>()

        init(dataController: DataController) {
            self.dataController = dataController

            let projectRequest: NSFetchRequest<Project> = Project.fetchRequest()
            projectRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            projectRequest.predicate = NSPredicate(format: "closed = false")

            projectsController = NSFetchedResultsController(
                fetchRequest: projectRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            // Construct a fetch request to show the 10 highest-priority,
            // incomplete items from open projects.
            let itemRequest = dataController.fetchRequestForTopItems(count: 10)

            itemsController = NSFetchedResultsController(
                fetchRequest: itemRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            projectsControllerDelegate = ProjectsControllerDelegate(parent: self)
            projectsController.delegate = projectsControllerDelegate

            itemsControllerDelegate = ItemsControllerDelegate(parent: self)
            itemsController.delegate = itemsControllerDelegate

            do {
                try projectsController.performFetch()
                try itemsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
                items = itemsController.fetchedObjects ?? []
                upNext = items.prefix(3)
                moreToExplore = items.dropFirst(3)
            } catch {
                print("Failed to fetch initial data.")
            }
        }

        /// Wrapper for dataController.item(with:) method.
        /// - Parameter identifier: An identifier for searched item provided by Spotlight
        func selectItem(with identifier: String) {
            selectedItem = dataController.item(with: identifier)
        }

        /// Adds sample data for testing and preview
        func addSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }

        func deleteAll() {
            dataController.deleteAll()
        }
    }
}
