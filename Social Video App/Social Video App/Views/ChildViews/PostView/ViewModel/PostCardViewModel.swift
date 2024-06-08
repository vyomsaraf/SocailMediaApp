//
//  PostCardViewModel.swift
//  Social Video App
//
//  Created by Vyom on 26/05/24.
//

import Foundation
import SwiftUI
import SwiftData

final class PostCardViewModel : ObservableObject {
    var modelContext: ModelContext?
    var loggedInUsername: String
    @Published var post: PostModel? = nil
    @Published var isLikeButtonEnabled: Bool = false
    @Bindable var postUserLikeData: PostUserLikeData = PostUserLikeData()
    private var apiTask: Task<Void, Never>?
    
    init(modelContext: ModelContext? = nil, postId: String, loggedInUsername: String) {
        self.modelContext = modelContext
        self.loggedInUsername = loggedInUsername
        fetchUserLikeData()
        apiTask = Task {
            if await MockServerClient.shared.setupServerPostData(postId: postId) {
                await loadPost(id: postId)
                DispatchQueue.main.async {
                    self.isLikeButtonEnabled = self.setIsLikeButtonEnabled()
                }
            }
        }
    }
    
    deinit {
        apiTask?.cancel()
    }
    
    func loadPost(id: String) async {
        let postData = await NetworkClient.fetchPost(id: id)
        DispatchQueue.main.async {
            withAnimation {
                self.post = postData
            }
        }
    }
    
    private func fetchUserLikeData() {
        do {
            let descriptor = FetchDescriptor<PostUserLikeData>()
            if let likeData = try modelContext?.fetch(descriptor).first {
                self.postUserLikeData = likeData
            }
        } catch {
            print("Error - Fetch failed")
        }
    }
    
    func setIsLikeButtonEnabled() -> Bool {
        if let postUsername = post?.username {
            if postUsername == loggedInUsername {
                return false
            } else if let postsLiked = postUserLikeData.postsLikedByUser[loggedInUsername], postsLiked.postIds?.contains(loggedInUsername) ?? false {
                return false
            }
            return true
        }
        return false
    }
    
    func postLiked() {
        var postData = postUserLikeData.postsLikedByUser[loggedInUsername] ?? PostsLiked(username: loggedInUsername)
        var postIds = postData.postIds ?? [String]()
        postIds.append(post?.id ?? "")
        postData.postIds = postIds
        postUserLikeData.postsLikedByUser[loggedInUsername] = postData
        modelContext?.insert(postUserLikeData)
        var likes = self.post?.likes ?? 0
        likes = likes + 1
        withAnimation {
            self.post?.likes = likes
            self.isLikeButtonEnabled = false
        }
        apiTask?.cancel()
        apiTask = Task {
            await updatePost()
        }
    }
    
    private func updatePost() async {
        if let post = self.post {
            if await MockServerClient.shared.updateServerPostData(postId: self.post?.id ?? "", data: post) {
               //MARK: - Updated successfully
                print("SUCCESS - updated successfully")
            } else {
                print("Error - update failed")
            }
        }
    }
}
