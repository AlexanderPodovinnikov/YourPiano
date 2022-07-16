//
//  HomeView.swift
//  YourPiano
//
//  Created by Alex Po on 28.06.2022.
//

import SwiftUI
import CoreData
// we need CoreData to create NSFetchRequest by hand
// (to show the 10 highest-priority incomplete items from open projects)
// But the whole thing does not reflect changes in projects - I will rewrite it later on MVVM
// This means using NSFetchedResultsController,
// which will perform the initial fetch request and also stay updated.

/// View that represents open projects in horizontal scroll view,
/// and 10 incomplete highest-priority items from open projects
struct HomeView: View {
    @EnvironmentObject var dataController: DataController

    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        predicate: NSPredicate(format: "closed = false")
    ) var projects: FetchedResults<Project>

    /// A tag to remember which tab was selected when the app went into the background or was closed.
    static let tag: String? = "Home"

    let items: FetchRequest<Item>
    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        request.predicate = NSPredicate(format: "completed = false AND project.closed = false")
//        but I'v done it the hard way:
        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [completedPredicate, openPredicate]
        )
        request.predicate = compoundPredicate

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]
        // that's what it was all about:
        request.fetchLimit = 10
        items = FetchRequest(fetchRequest: request)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                        // ForEach requires function for content
                        // ProjectSummaryView.init – the initializer for ProjectSummaryView –
                        // is a function that accepts a project from array and returns a view,
                        // so we can shorten this all stuff:
                            ForEach(projects, content: ProjectSummaryView.init)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding([.horizontal, .top]) // where to leave?
                    }

                    VStack(alignment: .leading) {
                        ItemsListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        ItemsListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .toolbar {
                Button("Add Data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .previewInterfaceOrientation(.portrait)
    }
}
