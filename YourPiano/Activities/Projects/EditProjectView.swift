//
//  EditProjectView.swift
//  YourPiano
//
//  Created by Alex Po on 01.07.2022.
//

import SwiftUI
import CloudKit

/// View to edit project attributes or to delete  project permanently
struct EditProjectView: View {

    /// Current project.
    let project: Project

    /// Environment variable to control View dismiss.
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var dataController: DataController

    @State private var showingNotificationsError = false

    @State private var showingDeleteConfirm = false
    /// Property to store project title
    @State private var title: String
    /// Property to store project detail
    @State private var detail: String
    /// Property to store project color
    @State private var color: String

    /// A flag showing whether to remind user or not.
    @State private var remindMe: Bool

    /// Time to show  notification
    @State private var reminderTime: Date

    let colorColumns = [GridItem(.adaptive(minimum: 44))]

    init(project: Project) {
        self.project = project

        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)

        if let projectReminderTime = project.reminderTime {
            _remindMe = State(wrappedValue: true)
            _reminderTime = State(wrappedValue: projectReminderTime)
        } else {
            _remindMe = State(wrappedValue: false)
            _reminderTime = State(wrappedValue: Date())
        }
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
            }
            Section(header: Text("Section reminders")) {
                Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))
                    .alert(isPresented: $showingNotificationsError) {
                        Alert(
                            title: Text("OOPS_!"),
                            message: Text("NOTIFICATION_PROBLEM_MSG"),
                            primaryButton: .default(Text("CHECK_SETTINGS"),
                            action: showAppSettings),
                            secondaryButton: .cancel())
                    }
                if remindMe {
                    DatePicker("Reminder time",
                               selection: $reminderTime.onChange(update),
                               displayedComponents: .hourAndMinute
                    )
                }
            }
            Section(
                footer: Text(
                    "Closing a section moves it from the Open to Completed tab; deleting it removes the section completely."
                ) // swiftlint:disable:previous line_length
            ) {
                Button(project.closed ? "Reopen this section" : "Close this section",
                       action: toggleProjectClose)

                Button("Delete this section") {
                    showingDeleteConfirm.toggle()
                }
                .accentColor(.red)
            }
        }
        .navigationTitle("Edit Section")
        .toolbar(content: {
            Button {
                let records = project.prepareCloudRecords()
                let operation = CKModifyRecordsOperation(
                    recordsToSave: records,
                    recordIDsToDelete: nil
                )
                operation.modifyRecordsResultBlock = { result in
                    if case .failure(let error) = result {
                        print("Error: \(error.localizedDescription)")
                    }
                }
                CKContainer.default().publicCloudDatabase.add(operation)
            } label: {
                Label("UPLOAD_TO_ICLOUD", systemImage: "icloud.and.arrow.up")
            }
        })
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

    /// Updates project's title, detail and color to their actual values,
    /// updates reminders time and tries to set reminders or shows alert
    /// if notifications error occurred.
    func update() {
        project.title = title
        project.detail = detail
        project.color = color

        if remindMe {
            project.reminderTime = reminderTime
            dataController.addReminders(for: project) { success in
                if !success {
                    project.reminderTime = nil
                    remindMe = false
                    showingNotificationsError = true
                }
            }
        } else {
            project.reminderTime = nil
            dataController.removeReminders(for: project)
        }
    }

    /// Deletes current project, its reminders, and dismisses the View
    func delete() {
        dataController.removeReminders(for: project)
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }

    /// Closes a project if it was open and vice-verse
    func toggleProjectClose() {
        project.closed.toggle()

        // poor temp solution for HomeView FRC to update items!!!
        for item in project.projectItems {
            item.completed = item.completed
        }
        if project.closed {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
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
