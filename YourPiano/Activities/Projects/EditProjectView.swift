//
//  EditProjectView.swift
//  YourPiano
//
//  Created by Alex Po on 01.07.2022.
//

import SwiftUI

/// View to edit project attributes or to delete  project permanently
struct EditProjectView: View {

    /// Current project.
    let project: Project
    /// Environment variable to control View dismiss.
    @Environment(\.presentationMode) var presentationMode

    /// Boolean to bind with deletion alert.
    @State private var showingDeleteConfirm = false

    @EnvironmentObject var dataController: DataController

    /// Property to store project title
    @State private var title: String
    /// Property to store project detail
    @State private var detail: String
    /// Property to store project color
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
                    ForEach(Project.colors, id: \.self, content: colorButton)
                }
                .padding(.vertical)

                Section(
                    footer: Text(
                        "Closing a section moves it from the Open to Completed tab; deleting it removes the section completely."
                    ) // swiftlint:disable:previous line_length
                ) {
                    Button(project.closed ? "Reopen this section" : "Close this section") {
                        project.closed.toggle()
                        // Home View doesn't know
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
                message: Text("Do you confirm that with a firm hand you want to remove this section and all of its items?"),  // swiftlint:disable:this line_length
                primaryButton: .default(Text("Delete"), action: delete),
                secondaryButton: .cancel()
            )
        }
    }

    /// Creates a colored button, that represents one of the project's custom colors.
    /// User can choose color with tap - selected color will be marked.
    /// - Parameter item: Name of the available color.
    /// - Returns: View - a colored button with/ or without checkmark.
    func colorButton(for item: String) -> some View {
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
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == color
                ? [.isButton, .isSelected]
                : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }

    /// Updates project's title, detail and color to their actual values
    func update() {
        project.title = title
        project.detail = detail
        project.color = color

    }

    /// Deletes current project and dismisses the View
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
