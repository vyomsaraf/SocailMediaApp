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
    @StateObject var homeScreenVM: HomeScreenVM
    
    init(username: String) {
        _homeScreenVM = StateObject(wrappedValue: HomeScreenVM(username: username))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            searchBar()
            if let posts = homeScreenVM.posts, !posts.isEmpty {
                VStack(alignment: .leading, spacing: 8.0) {
                    List(posts, id: \.id) { post in
                        PostCardListItem(post: post, loggedInUsername: homeScreenVM.username)
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
            }
        }
        .modifier(AppNavigationTitleBar(title: "Home"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: NavigationModel(username: homeScreenVM.username, userProfile: homeScreenVM.userProfile, navigationItem: .profile)) {
                    AppImage(url: homeScreenVM.userProfile?.profileUrl, label: homeScreenVM.userProfile?.username ?? homeScreenVM.username, size: 45.0, labelFontSize: .footnote)
                        .clipShape(Circle())
                }
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
        .onReceive(homeScreenVM.$searchKeyword.debounce(for: 1, scheduler: RunLoop.main)) { _ in
            homeScreenVM.searchApplied()
        }
    }
}
