//
//  ProfileView.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI
import AVKit

struct ProfileView: View {
    var userName: String
    var userProfile: UserProfilModel? = nil
    @State var serverStatus: Bool
    @State var cardViewEnabled: Bool = false
    @Binding var path : [NavigationModel]
    
    init(username: String, userProfile: UserProfilModel? = nil, path: Binding<[NavigationModel]>) {
        self.userName = username
        self.userProfile = userProfile
        _serverStatus = State(wrappedValue: MockServerClient.shared.isServerActive)
        _path = path
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16.0) {
                AppImage(url: userProfile?.profileUrl, label: userProfile?.username ?? userName, size: 65.0, labelFontSize: .footnote)
                    .clipShape(Circle())
                Text(userProfile?.username ?? userName)
                    .font(.title2)
                    .foregroundStyle(.primary, .white)
            }
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
            Divider()
            serverActionsView()
                .padding(.horizontal)
            Divider()
            VStack(alignment: .leading, spacing: 16) {
                Toggle(LocalizedStringKey(stringLiteral: "Card View"), isOn: $cardViewEnabled)
                    .accessibilityValue(cardViewEnabled ? "ON" : "OFF")
                    .accessibilityHint("Enable To view Card View of Posts")
                Text("Posts (\(userProfile?.posts?.count ?? 0))")
                    .font(.headline)
                postsView()
            }
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
                    serverStatus = false
                }
            }, label: {
                Text("Stop Server")
            })
            .disabled(!serverStatus)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            
            Button(action: {
                MockServerClient.shared.reinit(){ success in
                    withAnimation {
                        serverStatus = success
                    }
                }
            }, label: {
                Text("Start Server")
            })
            .disabled(serverStatus)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .contain)
        .accessibilityHint("Server start and stop buttons")
    }
    
    @ViewBuilder
    private func postsView() -> some View {
        if let posts = userProfile?.posts, !posts.isEmpty {
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(posts, id: \.id) { post in
                        VStack {
                            if cardViewEnabled {
                                PostCardListItem(post: post, widthRatio: 0.3, heightRatio: 0.1, loggedInUsername: userProfile?.username ?? userName, path: $path)
                            } else {
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
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Feed with likes \(post.likes ?? 0)")
                        .accessibilityHint("Tap to view Feed detail")
                    }
                }
            }
            .frame(maxWidth: .infinity)
        } else {
            ContentUnavailableView(
                "No Feeds Posted",
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
