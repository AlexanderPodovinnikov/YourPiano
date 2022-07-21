//
//  ItemsListView.swift
//  YourPiano
//
//  Created by Alex Po on 07.07.2022.
//

import SwiftUI

// Knowing bugs (iOS 15.5 Swift 5):
// 1. Added item is not visible in the View until is edited
// 2. Changing project attributes such as "closed" or "color"
// is not visible in items list without calling implemented
// in ViewModel refetching method

/// A simple list of items, that work as navigation link, with a title.
struct ItemsListView: View {

    /// A title of the list.
    let title: LocalizedStringKey
    var items: ArraySlice<Item>
    @ObservedObject var viewModel: HomeView.ViewModel // required for updating color of items when project color changes

    var body: some View {
        Group {
            if items.isEmpty {
                EmptyView()
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top)

                ForEach(items) {item in
                    NavigationLink(destination: EditItemView(item: item)) {
                        HStack(spacing: 20) {
                            Circle()
                                .stroke(Color(item.project?.projectColor ?? "Light Blue"), lineWidth: 3)
                                .frame(width: 44, height: 44)
                            VStack(alignment: .leading) {
                                Text(item.itemTitle)
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if !item.itemDetail.isEmpty {
                                    Text(item.itemDetail)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.secondarySystemGroupedBackground)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                        .frame(maxWidth: .infinity, alignment: .leading) // ???
                    }
                }
            }
        }
        .onAppear {
//          There is some glitch in NSFetchedResultsController - without next
//          call the view doesn't reflect project closing/opening and changing color - fixed!
//            viewModel.refetchItemsOnSomeGlitch()
        }
    }
}

// struct ItemsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemsListView()
//    }
// }
