//
//  ProjectsView.swift
//  YourPiano
//
//  Created by Alex Po on 28.06.2022.
//

import SwiftUI

/// Universal view for open and closed projects (sections), that shows
/// list of projects, each - with list of own items
struct ProjectsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    /// Boolean to bind with ActionSheet that shows sorting options
    @State private var showingSortOrder = false
    /// Selected sorting option
    @State private var sortOrder = Item.SortOrder.optimized

    /// If true - View will show only closed projects,
    /// if false - only open projects will be shown
    let showClosedProjects: Bool
    let projects: FetchRequest<Project>
    /// a tag to remember which tab was selected when the app went into the background or was closed
    static let openTag: String? = "Open"
    /// a tag to remember which tab was selected when the app went into the background or was closed
    static let closedTag: String? = "Completed"

    var projectsList: some View {
        List {
            ForEach(projects.wrappedValue) {project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        delete(at: offsets, from: project)
                    }
                    if !showClosedProjects { // !showClosedProjects
                        Button {
                            addItem(to: project)
                        } label: {
                            Label("Add New Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if !showClosedProjects {
                Button(action: addProject) {

                    // Label("Add Section", systemImage: "plus")
                    // Label View will be placed automatically depending on the platform

                    // Next code was written instead due to a bug in VoiceOver.
                    // Maybe, later it won't be needed
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Section")
                    } else {
                        Label("Add Section", systemImage: "plus")
                    }
                }
            }
        }
    }

    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

    /// Initializes View either for open projects, or for closed ones
    /// - Parameter showClosedProjects: if true - only closed projects will be listed,
    /// if false - View will show only open projects
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        projects = FetchRequest<Project>(
            entity: Project.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)
            ],
            predicate: NSPredicate(format: "closed = %d", showClosedProjects)
        )
    }

    var body: some View {
        NavigationView {
            Group {
                if projects.wrappedValue.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            .navigationTitle(showClosedProjects ? "Completed Sections" : "Sections in progress")
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimized")) { sortOrder = .optimized},
                    .default(Text("Creation date")) { sortOrder = .creationDate },
                    .default(Text("Title")) { sortOrder = .title}
                ])
            }
            .toolbar {
                addProjectToolbarItem
                sortOrderToolbarItem
            }
            SelectSomethingView()
        }
    }

    /// Creates new item in a project.
    /// - Parameter project: a project to create new item.
    func addItem(to project: Project) {
        withAnimation {
            let item = Item(context: managedObjectContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
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
        withAnimation {
            let project = Project(context: managedObjectContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
