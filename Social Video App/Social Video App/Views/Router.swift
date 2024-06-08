//
//  Router.swift
//  Social Video App
//
//  Created by Vyom on 08/06/24.
//

import SwiftUI

struct Router: View {
    @Environment(\.modelContext) private var modelContext
    @State var path = [NavigationModel]()
    
    var body: some View {
        NavigationStack(path: $path) {
            WelcomeScreen(path: $path)
                .navigationDestination(for: NavigationModel.self, destination: {navModel in
                    switch navModel.navigationItem {
                    case .home :
                        HomeScreen(username: navModel.username)
                    case .postDetail :
                        PostView(postId: navModel.postId ?? "", loggedInUsername: navModel.username, modelContext: modelContext)
                    case .profile :
                        ProfileView(username: navModel.username, userProfile: navModel.userProfile)
                    }
                })
        }
    }
}
