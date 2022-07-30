//
//  YourPianoWidget.swift
//  YourPianoWidget
//
//  Created by Alex Po on 28.07.2022.
//

import WidgetKit
import SwiftUI

// There is some glitches: when a very top item was toggled from completed to not completed,
// widget still shows an old one
@main
struct YourPianoWidgets: WidgetBundle {

    var body: some Widget {
        SimpleYourPianoWidget()
        ComplexYourPianoWidget()
    }
}
