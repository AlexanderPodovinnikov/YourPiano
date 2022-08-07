//
//  HomeView.swift
//  YourPianoMac
//
//  Created by Alex Po on 07.08.2022.
//

import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            List {
                ItemsListView(title: "Up next",
                              items: $viewModel.upNext
                )
                ItemsListView(title: "More to explore",
                              items: $viewModel.moreToExplore
                )
            }
            .listStyle(.sidebar)
            .navigationTitle("Home")
            .toolbar {
                Button("Delete All", action: viewModel.deleteAll)
            }
        }
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
