//
//  HomeScreenVM.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import Foundation
import SwiftUI

final class HomeScreenVM: ObservableObject {
    @Published var posts: [PostModel]? = nil
    @Published var searchKeyword: String = ""
    @Published var userProfile: UserProfilModel? = nil
    var username: String
    var originalData: [PostModel]? = nil
    private var apiTask: Task<Void, Never>?
    
    init(username: String) {
        self.username = username
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadData()
        }
    }
    
    func loadData() {
        apiTask?.cancel()
        apiTask = Task {
            await loadFeedData()
            await loadUserProfile()
        }
    }
    
    private func loadFeedData() async  {
        if let data = await NetworkClient.fetchFeed() {
            DispatchQueue.main.async {
                withAnimation {
                    self.posts = data
                    self.originalData = data
                }
            }
        } else {
            DispatchQueue.main.async {
                withAnimation {
                    self.posts = [PostModel]()
                    self.originalData = [PostModel]()
                }
            }
        }
    }
    
    private func loadUserProfile() async {
        if let userData = await NetworkClient.fetchUserProfile(username: username) {
            DispatchQueue.main.async {
                withAnimation {
                    self.userProfile = userData
                }
            }
        }
    }
    
    func refreshFeed() async {
        DispatchQueue.main.async {
            withAnimation {
                self.posts = nil
            }
            // delay added to show refresh
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.apiTask?.cancel()
                self.apiTask = Task {
                    await self.loadFeedData()
                }
            }
        }
    }
    
    func searchApplied() {
        withAnimation {
            if searchKeyword.isEmpty {
                self.posts = self.originalData
            } else {
                self.posts = self.posts?.filter({ post in
                    return post.username?.lowercased().contains(self.searchKeyword.lowercased()) ?? false
                })
            }
        }
    }
}
