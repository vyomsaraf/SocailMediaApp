//
//  PostCardView.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI
import SwiftData

struct PostCardListItem: View {
    
    var post: PostModel
    var widthRatio: CGFloat = 0.7
    var heightRatio: CGFloat = 0.3
    var loggedInUsername: String
    
    var body: some View {
        PostCardView(post: post, widthRatio: widthRatio, heightRatio: heightRatio)
            .background(
                NavigationLink(value: NavigationModel(username: loggedInUsername, postId: post.id, navigationItem: .postDetail), label: { })
                .opacity(0)
            )
            .frame(maxWidth: .infinity)
            .padding()
    }
}

struct PostCardView: View {
    var post: PostModel
    var widthRatio: CGFloat = 0.7
    var heightRatio: CGFloat = 0.3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            if let thumbnailUrl = post.thumbnailUrl {
                AppImage(url: thumbnailUrl, width: UIScreen.main.bounds.width * widthRatio, height: UIScreen.main.bounds.height * heightRatio, cornerRadius: 8.0)
            }
            
            HStack {
                if let username = post.username {
                    AppImage(label: username, size: 25.0, labelFontSize: .footnote)
                        .clipShape(Circle())
                    Text(username)
                        .font(.caption)
                        .foregroundStyle(.secondary, .white)
                }
            }
            Text("\(post.likes ?? 0) Likes")
                .font(.footnote)
                .foregroundStyle(.secondary, .white)
        }
        .padding()
        .modifier(AppOverlay(v_Padding: 0.0, h_Padding: 0.0, cornerRadius: 8.0))
        .background(Color.white.cornerRadius(8.0))
    }
}
