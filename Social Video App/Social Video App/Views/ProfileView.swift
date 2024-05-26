//
//  ProfileView.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI
import AVKit

struct ProfileView: View {
    @EnvironmentObject var homeScreenVM: HomeScreenVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16.0) {
                AppImage(url: homeScreenVM.userProfile?.profileUrl, label: homeScreenVM.userProfile?.username ?? homeScreenVM.username, size: 65.0, labelFontSize: .footnote)
                    .clipShape(Circle())
                Text(homeScreenVM.username)
                    .font(.title2)
                    .foregroundStyle(.primary, .white)
            }
            .padding(.horizontal)
            Divider()
            serverActionsView()
                .padding(.horizontal)
            Divider()
            Text("Posts(\(homeScreenVM.userProfile?.posts?.count ?? 0))")
                .font(.headline)
                .padding(.horizontal)
            postsView()
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.secondary.opacity(0.1))
        .modifier(AppNavigationTitleBar(title: "Profile"))
    }
    
    @ViewBuilder
    private func serverActionsView() -> some View {
        HStack {
            Button(action: {
                MockServerClient.shared.stopServer()
                withAnimation {
                    homeScreenVM.serverStatus = false
                }
            }, label: {
                Text("Stop Server")
            })
            .disabled(!homeScreenVM.serverStatus)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            
            Button(action: {
                MockServerClient.shared.reinit(){ success in
                    withAnimation {
                        homeScreenVM.serverStatus = success
                    }
                }
            }, label: {
                Text("Start Server")
            })
            .disabled(homeScreenVM.serverStatus)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func postsView() -> some View {
        if let posts = homeScreenVM.userProfile?.posts, !posts.isEmpty {
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(posts, id: \.id) { post in
                        if let videoUrlString = post.videoUrl, let videoUrl = URL(string: videoUrlString) {
                            VStack {
                                VideoPlayer(player: AVPlayer(url: videoUrl)) {
                                    VStack {
                                        Spacer()
                                        likesView(post: post)
                                    }
                                }
                                .cornerRadius(8.0)
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.height * 0.13)
                            .modifier(AppOverlay(v_Padding: 0.0, h_Padding: 0.0, cornerRadius: 8.0))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        } else {
            ContentUnavailableView(
                "No Posts Posted",
                image: "emptyState")
        }
    }
    
    @ViewBuilder
    private func likesView(post: PostModel) -> some View {
        HStack {
            Text("\(post.likes ?? 0) Likes")
                .font(.footnote)
                .foregroundStyle(.black)
            Spacer()
        }
        .padding(.vertical, 4.0)
        .padding(.horizontal, 16.0)
        .background(.white.opacity(0.7))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
