//
//  HomeScreenLoaderView.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI

struct HomeScreenLoaderView: View {
    var body: some View {
        let post = PostModel(thumbnailUrl: " ", username: "placeholder", likes: 23)
        VStack(alignment: .leading, spacing: 8.0) {
            List {
                ForEach(0..<10) { _ in
                    PostCardView(post: post)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) )
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.secondary.opacity(0.1))
            .listStyle(.plain)
        }
        .redacted(reason: .placeholder)
    }
}
