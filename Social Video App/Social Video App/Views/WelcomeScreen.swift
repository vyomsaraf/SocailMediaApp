//
//  WelcomeScreen.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI

struct WelcomeScreen: View {
    
    @State var username: String = ""
    @State var isAlertShown: Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 8.0) {
                Text("Please enter your username")
                    .font(.headline)
                    .foregroundStyle(.secondary, .white)
                TextField("username....", text: $username)
                    .foregroundColor(.primary)
                    .modifier(ClearButton(text: $username))
                    .modifier(AppOverlay(v_Padding: 8.0, cornerRadius: 8.0))
                    .padding()
                Button(action: {
                    UIApplication.shared.endEditing()
                    Task {
                        await setupData()
                    }
                }, label: {
                    Text("Submit")
                })
                .buttonStyle(.borderedProminent)
                .disabled(username.isEmpty)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .modifier(AppNavigationTitleBar(title: "Welcome"))
            .navigationDestination(for: String.self) { view in
                if view == "HomeScreen" {
                    HomeScreen(username: username)
                }
            }
        }
        .alert(Text("Error"), isPresented: $isAlertShown, actions: {
        }, message: {
            Text("Loading User Failed")
        })
    }
    
    private func setupData() async {
        if await MockServerClient.shared.setupServerUserProfileData(username: username) {
            
            path.append("HomeScreen")
        } else {
            withAnimation {
                isAlertShown = true
            }
        }
    }
}
