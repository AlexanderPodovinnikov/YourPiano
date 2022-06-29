//
//  ContentView.swift
//  YourPiano
//
//  Created by Alex Po on 28.06.2022.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ProjectsView(showClosedProjects: false)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("In progress")
                }
            ProjectsView(showClosedProjects: true)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Finished")
                }
        }
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
