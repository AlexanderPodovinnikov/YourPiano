//
//  HomeView.swift
//  YourPiano
//
//  Created by Alex Po on 28.06.2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    static let tag: String? = "Home"
        
    var body: some View {
        VStack {
            Button("Add Data") {
                dataController.deleteAll()
                try? dataController.createSampleData()
            }
        }
        .navigationTitle("Home")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
