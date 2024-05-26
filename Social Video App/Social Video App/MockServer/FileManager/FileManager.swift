//
//  MockServerFileManager.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import Foundation

struct MockServerFileManager {
    
    // MARK: - Read
    static func readFile<T: Codable>(fileName: String) async -> T? {
        guard let fileURL = getFileUrl(fileName: fileName) else { return nil }
        
        // Check if the file already exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("Error - File does not exist at path:", fileURL.path)
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: fileURL.path) {
            do {
                let json = try JSONDecoder().decode(T.self, from: data)
                return json
            } catch {
                print("Error - Loading \(fileName) JSON Failed")
                return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK: - Update
    static func addFile(fileName: String, withContent content: Data) {
        guard let fileURL = getFileUrl(fileName: fileName) else { return }
        
        // Check if the file already exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("File does not exist at path:", fileURL.path)
            createFile(fileName: fileName, withContent: content)
            return
        }
        
        do {
            try content.write(to: URL(fileURLWithPath: fileURL.path))
        } catch {
            print("Error - updating file: \(error)")
        }
    }
    
    // MARK: - Create
    static private func createFile(fileName: String, withContent content: Data) {
        guard let fileURL = getFileUrl(fileName: fileName) else { return }
        
        // Check if the file already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("Error - File already exists at path:", fileURL.path)
            return
        }
        
        // Create the file
        let created = FileManager.default.createFile(atPath: fileURL.path, contents: content, attributes: nil)
        
        if created {
            print("SUCCESS - File created at path:", fileURL.path)
        } else {
            print("Error - creating file")
        }
    }
    
    // MARK: - Delete
    static func deleteFile(fileName: String) {
        
        guard let fileURL = getFileUrl(fileName: fileName) else { return }
        
        // Check if the file already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                print("Error - deleting file: \(error)")
            }
        }
    }
}

extension MockServerFileManager {
    static func getVideoDirectory() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error - Documents directory not found")
            return nil
        }
        
        // Append the file name to the documents directory
        let videosDirectory = documentsDirectory.appendingPathComponent("videos")
        
        if !doesVideosFolderExist(with: videosDirectory) {
            do {
                try FileManager.default.createDirectory(at: videosDirectory, withIntermediateDirectories: true, attributes: nil)
                return videosDirectory
            } catch {
                print("Error - failed to create videos directory")
                return nil
            }
        } else {
            return nil
        }
    }
    
    private static func doesVideosFolderExist(with videoDirectoryPath: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let fileManager = FileManager.default
        let exists = fileManager.fileExists(atPath: videoDirectoryPath.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    private static func getFileUrl(fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error - Documents directory not found")
            return nil
        }
        
        // Append the file name to the documents directory
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        return fileURL
    }
}

extension MockServerFileManager {
    
    // MARK: - Read file part of app bundle
    static func loadJson<T: Codable>(fileName: String) async -> T? {
        guard !fileName.isEmpty, let filePath = Bundle.main.path(forResource: fileName, ofType: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
            do {
                let json = try JSONDecoder().decode(T.self, from: data)
                return json
            } catch {
                print("Error - Loading \(fileName) JSON Failed due to deserialization")
                return nil
            }
        } catch {
            print("Error - Loading \(fileName) JSON Failed")
            return nil
        }
    }
    
    static func getVideoFromFile(filePath: String) -> Data? {
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                let videoData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                return videoData
            } catch {
                print("Error - could not read file as Data")
                return nil
            }
        } else {
            print("Error - file not found")
            return nil
        }
    }
}
