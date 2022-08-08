//
//  PlatformAdjustments.swift
//  YourPiano
//
//  Created by Alex Po on 07.08.2022.
//

import SwiftUI

extension Notification.Name {
    static let willResignActive = UIApplication.willResignActiveNotification
}

/// Provides different navigation view based on platform.
struct StackNavigationView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationView(content: content)
            .navigationViewStyle(.stack)
    }
}

// Fixing buttons in AwardView for different platforms
typealias ImageButtonStyle = BorderlessButtonStyle

// Fixing problem with collapsing sections on maxOS -
// we'v been forced to use modifier .collapsible(false)
// but iOS does not support it, so it is used only in macOS code now
extension Section where Parent: View, Content: View, Footer: View {
    func disableCollapsing() -> some View {
        self
    }
}

// Eviscerating .onDeleteCommand for iOS (we need it on mac to delete items
// in more traditional way).
// Also adding mac-specific padding (use it for Form adjustment)
extension View {
    func onDeleteCommand(perform action: (() -> Void)?) -> some View {
        self
    }
    func macOnlyPadding() -> some View {
        self
    }
}

// Spacer that works only for macOS
typealias MacOnlySpacer = EmptyView
