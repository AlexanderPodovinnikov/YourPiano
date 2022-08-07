//
//  ProjectHeaderView.swift
//  YourPiano
//
//  Created by Alex Po on 01.07.2022.
//

import SwiftUI

struct ProjectHeaderView: View {
    @ObservedObject var project: Project

    var body: some View {
        NavigationLink(destination: EditProjectView(project: project)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(project.projectTitle)
                    ProgressView(value: project.completionAmount)
                        .accentColor(Color(project.projectColor))
                }
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
                }
        }
        .padding(.bottom, 10)
//        .accessibilityElement(children: .combine) // bug
    }
}

struct ProjectHeaderView_Previews: PreviewProvider {

    static var previews: some View {
        ProjectHeaderView(project: Project.example)

    }
}
