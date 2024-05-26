//
//  PostView.swift
//  Social Video App
//
//  Created by Vyom on 26/05/24.
//

import SwiftUI
import AVKit
import SwiftData

struct PostView: View {
    @StateObject var postVM: PostCardViewModel
    
    init(postId: String, loggedInUsername: String, modelContext: ModelContext?) {
        _postVM = StateObject(wrappedValue: PostCardViewModel(modelContext: modelContext, postId: postId, loggedInUsername: loggedInUsername))
    }
    
    var body: some View {
        VStack {
            if let videoUrlString = postVM.post?.videoUrl, let videoUrl = URL(string: videoUrlString) {
                VideoPlayer(player: AVPlayer(url: videoUrl)) {
                    VStack {
                        userNameView()
                        Spacer()
                        likesView()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .padding(.vertical)
        .modifier(AppNavigationTitleBar(title: "Post Detail"))
    }
    
    @ViewBuilder
    private func userNameView() -> some View {
        HStack {
            Text("Posted by: ")
                .font(.footnote)
                .foregroundStyle(.primary, .white)
            if let username = postVM.post?.username, !username.isEmpty {
                AppImage(label: username, size: 32.0, labelFontSize: .footnote)
                    .clipShape(Circle())
                Text(username)
                    .font(.footnote)
                    .foregroundStyle(.secondary, .white)
            }
        }
        .padding(.vertical, 4.0)
        .padding(.horizontal, 16.0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.7))
    }
    
    @ViewBuilder
    private func likesView() -> some View {
        HStack {
            Text("\(postVM.post?.likes ?? 0) Likes")
                .font(.footnote)
                .foregroundStyle(.black)
            if postVM.isLikeButtonEnabled {
                Button(action: {
                    postVM.postLiked()
                }, label: {
                    Image(systemName: "heart")
                        .tint(.primary)
                })
            }
            Spacer()
        }
        .padding(.vertical, 4.0)
        .padding(.horizontal, 16.0)
        .background(.white.opacity(0.7))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
