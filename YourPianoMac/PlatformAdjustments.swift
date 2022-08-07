//
//  PlatformAdjustments.swift
//  YourPianoMac
//
//  Created by Alex Po on 07.08.2022.
//

import SwiftUI

//Fixing error in macOS
typealias InsetGroupedListStyle = SidebarListStyle

extension Notification.Name {
    static let willResignActive = NSApplication.willResignActiveNotification
}

/// Provides different navigation view based on platform.
struct StackNavigationView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0, content: content)
    }
}

// Fixing buttons in AwardView for different platforms 
typealias ImageButtonStyle = BorderlessButtonStyle

// Fixing problem with collapsing sections on maxOS -
// we'v been forced to use modifier .collapsible(false)
// but iOS does not support it
extension Section where Parent: View, Content: View, Footer: View {
    func disableCollapsing() -> some View {
        self.collapsible(false)
    }
}

// Spacer that works only for macOS
typealias MacOnlySpacer = Spacer

// mac-specific padding (use it for Form adjustment)
extension View {
    func macOnlyPadding() -> some View {
        self.padding()
    }
}
