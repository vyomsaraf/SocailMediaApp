//
//  PostModel.swift
//  Social Video App
//
//  Created by Vyom on 24/05/24.
//

import Foundation
import SwiftData

typealias asDictionary = [String: Any]

struct NetworkResponseObject<T: Codable>: Codable {
    var status: String?
    var data: T?
}

struct NetworkResponseArray<T: Codable>: Codable {
    var status: String?
    var data: [T]?
}

struct UserProfilModel: Codable, Identifiable, Hashable {
   
    var id: UUID = UUID()
    var username: String?
    var profileUrl: String?
    var posts: [PostModel]?
    
    enum CodingKeys: String, CodingKey {
        case username
        case profileUrl = "profilePictureUrl"
        case posts
    }
}


struct PostModel: Codable, Identifiable, Hashable {
    var id: String?
    var videoUrl: String?
    var thumbnailUrl: String?
    var username: String?
    var likes: Int?
    //MARK: - property for handling posting video
    var isUploadedFromDevice: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "postId"
        case videoUrl
        case thumbnailUrl = "thumbnail_url"
        case username
        case likes
        case isUploadedFromDevice
    }
}

@Model
class PostUserLikeData {
    var postsLikedByUser: [String : PostsLiked] = [String: PostsLiked]()
    
    init() { }
    
}

struct PostsLiked: Codable {
    var username: String = ""
    var postIds: [String]? = nil
}
