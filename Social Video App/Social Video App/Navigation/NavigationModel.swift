//
//  NavigationModel.swift
//  Social Video App
//
//  Created by Vyom on 08/06/24.
//

import Foundation

struct NavigationModel : Identifiable, Hashable {
    var id: UUID = UUID()
    var username: String
    var postId: String?
    var userProfile: UserProfilModel?
    var navigationItem: NavItem
}

enum NavItem {
    case home
    case postDetail
    case profile
}
