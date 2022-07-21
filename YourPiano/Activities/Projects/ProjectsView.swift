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
    @StateObject var viewModel: ViewModel
    /// A boolean to bind with ActionSheet that shows sorting options.
    @State private var showingSortOrder = false
    /// A tag to remember which tab was selected when the app went into the background or was closed.
    static let openTag: String? = "Open"
    /// A tag to remember which tab was selected when the app went into the background or was closed.
    static let closedTag: String? = "Completed"

    /// Initializes View either for open projects, or for closed ones.
    /// - Parameter showClosedProjects: if true - only closed projects will be listed,
    /// if false - View will show only open projects.
    init(dataController: DataController, showClosedProjects: Bool) {
        let viewModel = ViewModel(
            dataController: dataController,
            showClosedProjects: showClosedProjects
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var projectsList: some View {
        List {
            ForEach(viewModel.projects) {project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        viewModel.delete(at: offsets, from: project)
                    }
                    if viewModel.showClosedProjects == false { // !showClosedProjects
                        Button {
                            withAnimation {
                                viewModel.addItem(to: project)
                            }
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
            if viewModel.showClosedProjects == false {
                Button {
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
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
    var body: some View {
        NavigationView {
            Group {
                if viewModel.projects.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            .navigationTitle(viewModel.showClosedProjects ? "Completed Sections" : "Sections in progress")
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimized")) { viewModel.sortOrder = .optimized},
                    .default(Text("Creation date")) { viewModel.sortOrder = .creationDate },
                    .default(Text("Title")) { viewModel.sortOrder = .title}
                ])
            }
            .toolbar {
                addProjectToolbarItem
                sortOrderToolbarItem
            }
            SelectSomethingView()
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ProjectsView(dataController: dataController, showClosedProjects: false)
    }
}
