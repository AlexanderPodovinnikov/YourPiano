//
//  DataController-Notifications.swift
//  YourPiano
//
//  Created by Alex Po on 24.07.2022.
//

import Foundation
import UserNotifications

extension DataController {

    ///  Tries to place reminder for a project in Notification Center.
    ///  Asks user for permissions if they weren't granted.
    ///
    ///  If there'r authorisation problems or other errors, the completion handler
    ///  will be called on main thread with its parameter set to false.  Otherwise
    ///  the handler will be called with 'true'.
    /// - Parameters:
    ///   - project: A project to remind user about
    ///   - completion: A Handler for possible errors
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: project, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// Removes all pending notifications for a project (if any exist).
    /// - Parameter project: A project with reminders enabled.
    func removeReminders(for project: Project) {
        let center = UNUserNotificationCenter.current()
        let id = project.objectID.uriRepresentation().absoluteString

        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }

    }

    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle

        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }
        let components = Calendar.current.dateComponents(
                            [.hour, .minute],
                            from: project.reminderTime ?? Date()
                        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let id = project.objectID.uriRepresentation().absoluteString

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
