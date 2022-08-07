//
//  AwardsView.swift
//  YourPiano
//
//  Created by Alex Po on 04.07.2022.
//

import SwiftUI

/// A grid with all possible awards that shows small description
/// of each award and which ones were opened by user
struct AwardsView: View {
//    @EnvironmentObject var dataController: DataController

    @StateObject var viewModel: ViewModel
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    /// A tag to remember which tab is selected when the app went into the background or was closed.
    static let tag: String? = "Awards"
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        StackNavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) {item in
                        Button {
                            selectedAward = item
                            showingAwardDetails.toggle()
                        } label: {
                            Image(systemName: item.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(
                                    viewModel.color(for: item).map { Color($0) }
                                    ?? .secondary.opacity(0.5)
                                )
                        }
                        .accessibilityLabel(
                            Text(viewModel.label(for: item))
                        )
                        .accessibilityHint(Text(item.description))
                        .buttonStyle(ImageButtonStyle())
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAwardDetails, content: getAwardAlert)
    }
    /// Shows the name of the award, whether it was opened, and the conditions for opening
    /// - Returns: Alert with matching text
    func getAwardAlert() -> Alert {
        if viewModel.hasEarned(award: selectedAward) {
            return Alert(title: Text("Unlocked \(selectedAward.name)"),
                         message: Text(selectedAward.description),
                         dismissButton: .default(Text("OK"))
            )
        } else {
            return Alert(title: Text("Locked"),
                         message: Text(selectedAward.description),
                         dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        AwardsView(dataController: dataController)
            .environmentObject(dataController)

    }
}
