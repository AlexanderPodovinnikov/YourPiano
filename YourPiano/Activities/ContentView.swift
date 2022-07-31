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

    // Custom activity
    private let newSectionActivity = "com.Po.Alex.YourPiano.newSection"

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
            SharedProjectsView()
                .tag(SharedProjectsView.tag)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("COMMUNITY")
                }
        }
        .onOpenURL(perform: openURL) // !!! Looks like it does nothing !!!
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveHome)
        .onContinueUserActivity(newSectionActivity, perform: createProject)
        .userActivity(newSectionActivity) { activity in
            activity.isEligibleForPrediction = true
            activity.title = "New Section"
        }
    }

    /// Moves us on the Home tab when the app was launched by user activity
    /// - Parameter input: Any NSUserActivity object
    func moveHome(_ input: Any) {
        selectedView = HomeView.tag
    }

    // !!! Doesn't work for some reasons !!!
    /// Opens list of open projects on user pressed shortcut,
    /// and adds a new project to the list
    func openURL(_ url: URL) {
        selectedView = ProjectsView.openTag
        _ = dataController.addProject()
    }

    /// Creates a new project when user launches an activity
    func createProject(_ userActivity: NSUserActivity) {
        selectedView = ProjectsView.openTag
        dataController.addProject()
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
