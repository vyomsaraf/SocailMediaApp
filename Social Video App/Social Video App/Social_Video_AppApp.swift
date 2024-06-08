//
//  Social_Video_AppApp.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI

@main
struct Social_Video_AppApp: App {
    @State private var isAppActive = false
    
    var body: some Scene {
        WindowGroup {
            if isAppActive {
                Router()
                    .modelContainer(for: [PostUserLikeData.self])
            }else {
                SplashScreen(isAppActive: $isAppActive)
            }
        }
    }
}
