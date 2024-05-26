//
//  NetworkClient.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import Foundation

class NetworkClient {
    private enum EndPoint : String {
        case feed = "/api/feed"
        case post = "/api/post/"
        case profile = "/api/profile/"
        
        func getUrl(id: String? = nil) -> URL? {
            if let id = id, !id.isEmpty {
                return URL(string: "http://localhost:8080\(self.rawValue)\(id)")
            }
            return URL(string: "http://localhost:8080\(self.rawValue)")
        }
    }
    
    class func fetchFeed() async -> [PostModel]? {
        return await fetchArray(endpointType: .feed)
    }
    
    class func fetchPost(id: String) async -> PostModel? {
        return await fetchObject(id: id, endpointType: .post)
    }
    
    class func fetchUserProfile(username: String) async -> UserProfilModel? {
        return await fetchObject(id: username, endpointType: .profile)
    }
}

extension NetworkClient {
    //MARK: - API func for getting array response
    private class func fetchArray<T: Codable>(id: String? = nil, endpointType: EndPoint) async -> [T]? {
        if let url = endpointType.getUrl(id: id) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                do {
                    let json = try JSONDecoder().decode(NetworkResponseArray<T>.self, from: data)
                    return json.data
                } catch {
                    print("Error - serialization of response failed")
                    return nil
                }
            } catch {
                MockServerClient.shared.stopServer()
                MockServerClient.shared.reinit()
                print("Error - \(error)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    //MARK: - API func for getting object response
    private class func fetchObject<T: Codable>(id: String? = nil, endpointType: EndPoint) async -> T? {
        if let url = endpointType.getUrl(id: id) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                do {
                    let json = try JSONDecoder().decode(NetworkResponseObject<T>.self, from: data)
                    return json.data
                } catch {
                    print("Error - serialization of response failed")
                    return nil
                }
            } catch {
                MockServerClient.shared.stopServer()
                MockServerClient.shared.reinit()
                print("Error - \(error)")
                return nil
            }
        } else {
            return nil
        }
    }
}
