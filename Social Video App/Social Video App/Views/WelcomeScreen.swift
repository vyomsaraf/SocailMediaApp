//
//  WelcomeScreen.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI

struct WelcomeScreen: View {
    
    @Binding var path : [NavigationModel]
    @State var username: String = ""
    @State var isAlertShown: Bool = false
    
    var body: some View {
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
        .alert(Text("Error"), isPresented: $isAlertShown, actions: {
        }, message: {
            Text("Loading User Failed")
        })
    }
    
    private func setupData() async {
        if await MockServerClient.shared.setupServerUserProfileData(username: username) {
            path.append(NavigationModel(username: username, navigationItem: .home))
        } else {
            withAnimation {
                isAlertShown = true
            }
        }
    }
}
