//
//  SimpleWidget.swift
//  YourPianoWidgetExtension
//
//  Created by Alex Po on 30.07.2022.
//

import WidgetKit
import SwiftUI

struct YourPianoWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("UP_NEXT")
                .font(.title)
            if let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text("NOTHING")
            }
        }
    }
}

struct SimpleYourPianoWidget: Widget {
    let kind: String = "SimpleYourPianoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YourPianoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("UP_NEXT")
        .description("YOUR_TOP_ITEM")
        .supportedFamilies([.systemSmall])
    }
}
