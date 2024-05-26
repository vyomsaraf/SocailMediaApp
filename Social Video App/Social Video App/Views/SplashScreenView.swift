//
//  SplashScreenView.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI

struct SplashScreen: View {
    
    @State private var scale = 0.7
    @Binding var isAppActive: Bool
    
    var body: some View {
        VStack {
            VStack {
                Image("splashIcon")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.5)
                Text("Social Media")
                    .font(.largeTitle)
            }
            .scaleEffect(scale)
            .onAppear{
                withAnimation(.easeIn(duration: 0.7)) {
                    self.scale = 0.9
                }
            }
        }.task {
            await MockServerClient.shared.setupServerFeedData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation {
                    self.isAppActive = true
                }
            }
        }
    }
}
