//
//  EditProjectView.swift
//  YourPiano
//
//  Created by Alex Po on 01.07.2022.
//

import SwiftUI

struct EditProjectView: View {
    let project: Project
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteConfirm = false

    @EnvironmentObject var dataController: DataController
    
    
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    
    let colorColumns = [GridItem(.adaptive(minimum: 44))]
    
    init(project: Project) {
        self.project = project
        
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
    }

    var body: some View {
        Form {
            Section(header: Text("Basic Settings")) {
                TextField("Section name", text: $title.onChange(update))
                TextField("Description of the section", text: $detail.onChange(update))
            }
            Section(header: Text("Custom section color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id: \.self) { item in
                        ZStack {
                            Color(item)
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(6)
                            if item == self.color {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                            }
                        }
                        .onTapGesture {
                            self.color = item
                            update()
                        }
                    }
                }
                .padding(.vertical)
                
                Section(footer: Text("Closing a section moves it from the Open to Completed tab; deleting it removes the section completely.")) {
                    Button(project.closed ? "Reopen this section" : "Close this section") {
                        project.closed.toggle()
                    }
                    Button("Delete this section") {
                        showingDeleteConfirm.toggle()
                    }
                    .accentColor(.red)
                }
            }
        }
        .navigationTitle("Edit Section")
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("Delete Section?"),
                message: Text("Do you confirm that with a firm hand you want to remove this section and all of its items?"),
                primaryButton: .default(Text("Delete"), action: delete),
                secondaryButton: .cancel()
            )
        }
    }
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
    }
    
    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        EditProjectView(project: Project.example)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
