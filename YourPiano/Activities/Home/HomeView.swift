//
//  HomeView.swift
//  YourPiano
//
//  Created by Alex Po on 28.06.2022.
//

import SwiftUI
import CoreData
import CoreSpotlight

/// View that represents open projects in horizontal scroll view,
/// and 10 incomplete highest-priority items from open projects
struct HomeView: View {
    @StateObject var viewModel: ViewModel

    /// A tag to remember which tab is selected when the app went into the background or was closed.
    static let tag: String? = "Home"

    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding([.horizontal, .top]) // where to leave?
                    }

                    VStack(alignment: .leading) {

                        ItemsListView(title: "Up next",
                                      items: $viewModel.upNext
                        )
                        ItemsListView(title: "More to explore",
                                      items: $viewModel.moreToExplore
                        )
                    }
                    .padding(.horizontal)
                }
                // Will show edit view for selected item:
                if let item = viewModel.selectedItem { // we'v got an item from the search result
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $viewModel.selectedItem,
                        label: EmptyView.init
                    ).id(item)
                }
            }
            .navigationTitle("Home")
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .toolbar {
                Button("Delete All", action: viewModel.deleteAll)
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }
    /// Loads an item that was selected by user in Spotlight results.
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier =
                userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.selectItem(with: uniqueIdentifier)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        HomeView(dataController: dataController)
            .previewInterfaceOrientation(.portrait)
    }
}
