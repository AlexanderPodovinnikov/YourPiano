//
//  ProjectsViewModel.swift
//  YourPiano
//
//  Created by Alex Po on 16.07.2022.
//

import Foundation
import CoreData

extension ProjectsView {
// Why extension - this approach means I don’t pollute the namespace
// with view models that apply in only one place.

    /// An object to manipulate data
    ///
    /// This class should conform  to NSObject and NSFetchResultsControllerDelegate,
    /// so we able to use it with NSFetchedResultsController
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        /// We need access to our data
        let dataController: DataController

        /// Selected sorting option
        @Published var sortOrder = Item.SortOrder.optimized

        /// If true - View will show only closed projects,
        /// if false - only open projects will be shown
        let showClosedProjects: Bool

        private let projectsController: NSFetchedResultsController<Project>

        /// Pure array of projects, fetched from the data scope by inner means of DataController
        @Published var projects = [Project]()

        /// An Initializer that creates NSFetchedResultsController using self as a delegate,
        /// so we need to call super.init() inside the initializer.
        /// - Parameters:
        ///   - dataController: An instance of DataController with our data.
        ///   - showClosedProjects: Whether to show open or closed projects.
        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects

            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)

            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init() // to create NSObject
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch  projects.")
            }
        }

        /// Creates new item in a project.
        /// - Parameter project: a project to create new item.
        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
            item.project = project
            item.creationDate = Date()
            // Try to trigger FRC for items shown in Home View - it works!
            item.completed = false
            dataController.save()
        }

        /// Deletes items in a project
        /// - Parameters:
        ///   - offsets: indices of items to be deleted
        ///   - project: a project, where items should be deleted
        func delete(at offsets: IndexSet, from project: Project) {
            let allItems = project.projectItems(using: sortOrder)
            for offset in offsets {
                let item = allItems[offset]
                dataController.delete(item)
            }
            dataController.save()
        }

        /// Creates a new project
        func addProject() {
            let project = Project(context: dataController.container.viewContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
        }

        // Remember 'projectsController.delegate = self'
        /// A method to run by controller when data change
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = projectsController.fetchedObjects { // as? [Project]
                projects = newProjects
            }
        }
    }
}
