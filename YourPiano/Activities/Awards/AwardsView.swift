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
    @EnvironmentObject var dataController: DataController
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    static let tag: String? = "Awards"
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }

    var body: some View {
        NavigationView {
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
                                    dataController.hasEarned(award: item)
                                    ? Color(item.color)
                                    : .secondary.opacity(0.5)
                                )
                        }
                        .accessibilityLabel(
                            Text(
                                dataController.hasEarned(award: item)
                                ? "Unlocked \(item.name)"
                                : "Locked"
                            )
                        )
                        .accessibilityHint(Text(item.description))
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
        if dataController.hasEarned(award: selectedAward) {
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
        AwardsView()
            .environmentObject(dataController)

    }
}
