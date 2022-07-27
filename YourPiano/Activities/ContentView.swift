//
//  ContentView.swift
//  YourPiano
//
//  Created by Alex Po on 28.06.2022.
//

import SwiftUI
import CoreSpotlight
import StoreKit

struct ContentView: View {
    @EnvironmentObject var dataController: DataController

    // Will work in iOS16. Use onAppear(perform: showRequestReview)
    // with some condition call of requestReview() in the performing method:
    // @Environment(\.requestReview) var requestReview


    /// This property is for remembering the last selected tab
    @SceneStorage("selectedView") var selectedView: String?

    var body: some View {
        TabView(selection: $selectedView) {
            HomeView(dataController: dataController)
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ProjectsView(dataController: dataController, showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("In progress")
                }
            ProjectsView(dataController: dataController, showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Completed")
                }
            AwardsView(dataController: dataController)
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Awards")
                }
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveHome)
    }

    /// Moves us on the Home tab when the app was launched by user activity
    /// - Parameter input: Any NSUserActivity object
    func moveHome(_ input: Any) {
        selectedView = HomeView.tag
    }

    // Try it in iOS16
    func showRequestReview() {
        // on some condition:
        // requestReview()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
