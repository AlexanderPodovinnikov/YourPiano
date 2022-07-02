//
//  ProjecrtHeaderView.swift
//  YourPiano
//
//  Created by Alex Po on 01.07.2022.
//

import SwiftUI

struct ProjecrtHeaderView: View {
    @ObservedObject var project: Project
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(project.projectTitle)
                ProgressView(value: project.completionAmount)
                    .accentColor(Color(project.projectColor))
            }
            NavigationLink(destination: EditProjectView(project: project)) {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
            }
        }
        .padding(.bottom, 10)
    }
}

struct ProjecrtHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProjecrtHeaderView(project: Project.example)
            
    }
}
