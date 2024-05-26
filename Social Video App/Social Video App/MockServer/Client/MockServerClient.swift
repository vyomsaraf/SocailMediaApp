//
//  MockServerClient.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import Swifter
import Foundation

class MockServerClient {
    private let server = HttpServer()
    
    static let shared =  MockServerClient()
    
    var isServerActive: Bool = false
    
    private init() {
        stopServer()
        //MARK: - Start the server
        do {
            try server.start()
            isServerActive = true
            print("SUCCESS - Server started")
        } catch {
            isServerActive = false
            print("Error - Server start error: \(error)")
        }
    }
    
    func reinit(completion: ((Bool) -> Void)? = nil) {
        //MARK: - Restart the server
        do {
            try server.start()
            isServerActive = true
            completion?(true)
        } catch {
            isServerActive = false
            completion?(false)
            print("Error - Server restart error: \(error)")
        }
    }
    
    func stopServer() {
        server.stop()
        isServerActive = false
    }
    
    func setupServerFeedData() async {
        //MARK: - setup /api/feed data
        if let feedData : NetworkResponseArray<PostModel> = await MockServerFileManager.readFile(fileName: "feed") {
            stopServer()
            server["/api/feed"] = { request in
                do {
                    let jsonData = try JSONEncoder().encode(feedData)
                    return .ok(.data(jsonData, contentType: "application/json"))
                } catch {
                    return .ok(.json(feedData))
                }
            }
            reinit()
        } else if let feedData : NetworkResponseArray<PostModel> = await MockServerFileManager.loadJson(fileName: "feed") {
            stopServer()
            server["/api/feed"] = { request in
                do {
                    let jsonData = try JSONEncoder().encode(feedData)
                    return .ok(.data(jsonData, contentType: "application/json"))
                } catch {
                    return .ok(.json(feedData))
                }
            }
            if let data = feedData.data {
                await updateFeedData(data: data, isResponseUpdateNeeded: false)
            }
            reinit()
        }
    }
    
    func setupServerPostData(postId: String) async -> Bool{
        //MARK: - setup /api/post/postId data
        if let postData : NetworkResponseObject<PostModel> = await MockServerFileManager.readFile(fileName: "post_\(postId)") {
            stopServer()
            server["/api/post/\(postId)"] = { request in
                do {
                    let jsonData = try JSONEncoder().encode(postData)
                    return .ok(.data(jsonData, contentType: "application/json"))
                } catch {
                    return .ok(.json(postData))
                }
            }
            reinit()
            return true
        } else if let feedData : NetworkResponseArray<PostModel> = await MockServerFileManager.loadJson(fileName: "feed"), let post = feedData.data?.filter({return $0.id == postId}).first {
            return await updateServerPostData(postId: postId, data: post)
        } else {
            return false
        }
    }
    
    func setupServerUserProfileData(username: String) async -> Bool {
        //MARK: - setup /api/profile/username data
        if let userProfileData : NetworkResponseObject<UserProfilModel> = await MockServerFileManager.readFile(fileName: "profile_\(username)") {
            stopServer()
            server["/api/profile/\(username)"] = { request in
                do {
                    let jsonData = try JSONEncoder().encode(userProfileData)
                    return .ok(.data(jsonData, contentType: "application/json"))
                } catch {
                    return .ok(.json(userProfileData))
                }
            }
            reinit()
            return true
        } else if let userProfileData : NetworkResponseObject<UserProfilModel> = await MockServerFileManager.loadJson(fileName: "profile_\(username)") {
            stopServer()
            server["/api/profile/\(username)"] = { request in
                do {
                    let jsonData = try JSONEncoder().encode(userProfileData)
                    return .ok(.data(jsonData, contentType: "application/json"))
                } catch {
                    return .ok(.json(userProfileData))
                }
            }
            reinit()
            if let data = userProfileData.data {
                return await updateServerUserData(username: username, data: data)
            }
            return false
        } else {
            let userProfileData = NetworkResponseObject(status: "success", data: UserProfilModel(username: username))
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(userProfileData)
                MockServerFileManager.addFile(fileName: "profile_\(username)", withContent: jsonData)
                stopServer()
                server["/api/profile/\(username)"] = { request in
                    do {
                        let jsonData = try JSONEncoder().encode(userProfileData)
                        return .ok(.data(jsonData, contentType: "application/json"))
                    } catch {
                        return .ok(.json(userProfileData))
                    }
                }
                reinit()
                return true
            } catch {
                print("Error - adding user failed")
                return false
            }
        }
    }
    
    func updateServerPostData(postId: String, data: PostModel) async -> Bool {
        let updatedData = NetworkResponseObject(status: "success", data: data)
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(updatedData)
            MockServerFileManager.addFile(fileName: "post_\(postId)", withContent: jsonData)
            updateResponse(with: "/api/post/\(postId)", data: updatedData)
            //MARK: - updating /api/feed data
            await updateFeedData(data: [data])
            return true
        } catch {
            print("Error - encoding failed")
            return false
        }
    }
    
    func updateServerUserData(username: String, data: UserProfilModel) async -> Bool {
        let updatedData = NetworkResponseObject(status: "success", data: data)
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(updatedData)
            MockServerFileManager.addFile(fileName: "profile_\(username)", withContent: jsonData)
            updateResponse(with: "/api/profile/\(username)", data: updatedData)
            //MARK: - updating /api/feed data
            if let feedData = data.posts {
                await updateFeedData(data: feedData)
            }
            return true
        } catch {
            print("Error - encoding failed")
            return false
        }
    }
    
    private func updateFeedData(data: [PostModel], isResponseUpdateNeeded: Bool = true) async {
        if var feedData : NetworkResponseArray<PostModel> = await MockServerFileManager.readFile(fileName: "feed") {
            if var feeds = feedData.data, !feeds.isEmpty {
                feeds = feeds.filter({ feed in
                    return !data.contains(where: {$0.id == feed.id})
                })
                feeds.append(contentsOf: data)
            } else {
                feedData.data = data
            }
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(feedData)
                MockServerFileManager.addFile(fileName: "feed", withContent: jsonData)
                if isResponseUpdateNeeded {
                    updateResponse(with: "/api/feed", data: feedData)
                }
            } catch {
                print("Error - encoding failed")
            }
        } else {
            let feedData = NetworkResponseArray(status: "success", data: data)
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(feedData)
                MockServerFileManager.addFile(fileName: "feed", withContent: jsonData)
                if isResponseUpdateNeeded {
                    updateResponse(with: "/api/feed", data: feedData)
                }
            } catch {
                print("Error - encoding failed")
            }
        }
    }
    
    private func updateResponse<T: Codable>(with endpoint: String, data: T) {
        stopServer()
        server[endpoint] = { request in
            do {
                let jsonData = try JSONEncoder().encode(data)
                return .ok(.data(jsonData, contentType: "application/json"))
            } catch {
                return .ok(.json(data))
            }
        }
        reinit()
    }
}

extension MockServerClient {
    func uploadPost(username: String) async -> Bool {
        var videoFileUrl : URL? = nil
        server["/upload"] = { request in
            let body = request.body
            
            // Convert body to Data
            let videoData = Data(body)
            // Generate a unique filename for the video
            let filename = UUID().uuidString + ".mp4"
            
            if let videoDirectory = MockServerFileManager.getVideoDirectory() {
                let filePath = videoDirectory.appendingPathComponent(filename)
                
                // Write the video data to the file
                do {
                    try videoData.write(to: filePath)
                    videoFileUrl = filePath
                    return .ok(.text("Video uploaded successfully with filename \(filename)"))
                } catch {
                    return .internalServerError
                }
            } else {
                return .internalServerError
            }
        }
        
        if let fileUrl = videoFileUrl {
            let id = UUID().uuidString
            let post = PostModel(id: id, videoUrl: fileUrl.absoluteString, username: username, likes: 0, isUploadedFromDevice: true)
            return await updateServerPostData(postId: id, data: post)
        } else {
            return false
        }
    }
}
