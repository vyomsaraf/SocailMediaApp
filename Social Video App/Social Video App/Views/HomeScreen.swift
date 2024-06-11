//
//  HomeScreen.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI
import Kingfisher
import SwiftData

struct HomeScreen: View {
    @State var homeScreenVM: HomeScreenVM
    @Binding var path : [NavigationModel]
    
    init(username: String, path: Binding<[NavigationModel]>) {
        _path = path
        _homeScreenVM = State(wrappedValue: HomeScreenVM(username: username))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            searchBar()
            if let posts = homeScreenVM.posts, !posts.isEmpty {
                VStack(alignment: .leading, spacing: 8.0) {
                    List(posts, id: \.id) { post in
                        PostCardListItem(post: post, loggedInUsername: homeScreenVM.username, path: $path)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) )
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.1))
                    .listStyle(.plain)
                    .refreshable {
                        await homeScreenVM.refreshFeed()
                    }
                }
            } else if homeScreenVM.posts != nil {
                ContentUnavailableView(
                    "No Feeds Found",
                    image: "emptyState")
            } else {
                HomeScreenLoaderView()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Please wait. Loading Feeds")
            }
        }
        .modifier(AppNavigationTitleBar(title: "Home"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: NavigationModel(username: homeScreenVM.username, userProfile: homeScreenVM.userProfile, navigationItem: .profile)) {
                    AppImage(url: homeScreenVM.userProfile?.profileUrl, label: homeScreenVM.userProfile?.username ?? homeScreenVM.username, size: 45.0, labelFontSize: .footnote)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Profile")
                .accessibilityHint("View Profile")
            }
        }
    }
    
    @ViewBuilder
    private func searchBar() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("username....", text: $homeScreenVM.searchKeyword)
                .foregroundColor(.primary)
        }
        .modifier(ClearButton(text: $homeScreenVM.searchKeyword, isSearchBar: true))
        .modifier(AppOverlay(v_Padding: 8.0, cornerRadius: 8.0))
        .padding()
        .task(id: homeScreenVM.searchKeyword, priority: .background) {
            homeScreenVM.searchApplied()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Search Bar")
        .accessibilityValue(homeScreenVM.searchKeyword)
        .accessibilityHint("Search Feeds based on username")
    }
}
