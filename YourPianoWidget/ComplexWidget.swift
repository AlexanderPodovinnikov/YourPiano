//
//  ComplexWidget.swift
//  YourPianoWidgetExtension
//
//  Created by Alex Po on 30.07.2022.
//

import WidgetKit
import SwiftUI

struct YourPianoWidgetMultiplyEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.sizeCategory) var sizeCategory

    var items: ArraySlice<Item> {
        let itemsCount: Int
        switch widgetFamily {
        case .systemSmall:
            itemsCount = 1
        case .systemLarge:
            if sizeCategory < .extraExtraLarge {
                itemsCount = 5
            } else {
                itemsCount = 4
            }
        case .systemExtraLarge:
            itemsCount = 5
        default:
            if sizeCategory < .extraLarge {
                itemsCount = 3
            } else {
                itemsCount = 2
            }
        }
        return entry.items.prefix(itemsCount)
    }

    var body: some View {
        VStack(spacing: 5) {
            ForEach(items) { item in
                HStack {
                    Color(item.project?.color ?? "Light Blue")
                        .frame(width: 5)
                        .clipShape(Capsule())

                    VStack(alignment: .leading) {
                        Text(item.itemTitle)
                            .font(.headline)
                            .layoutPriority(1)
                        if let projectTitle = item.project?.projectTitle {
                            Text(projectTitle)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(20)
    }
}

struct ComplexYourPianoWidget: Widget {
    let kind: String = "ComplexYourPianoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YourPianoWidgetMultiplyEntryView(entry: entry)
        }
        .configurationDisplayName("UP_NEXT")
        .description("MOST_IMPORTANT")
    }
}
