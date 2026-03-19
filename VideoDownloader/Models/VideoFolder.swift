//
//  VideoFolder.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 19/03/26.
//

import Foundation
import SwiftUI
import Combine

struct VideoFolder: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var createdAt: Date
    var videoIds: [UUID] // References to videos in this folder
    
    init(id: UUID = UUID(), name: String, createdAt: Date = Date(), videoIds: [UUID] = []) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.videoIds = videoIds
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, createdAt, videoIds
    }
}

// Folder Manager to handle folder operations
class FolderManager: ObservableObject {
    static let shared = FolderManager()
    private let foldersKey = "videoFolders"
    private let fileManager = FileManager.default
    
    @Published var folders: [VideoFolder] = []
    
    private init() {
        loadFolders()
        // Don't create any default folder
    }
    
    func loadFolders() {
        guard let data = UserDefaults.standard.data(forKey: foldersKey) else {
            folders = []
            return
        }
        
        do {
            folders = try JSONDecoder().decode([VideoFolder].self, from: data)
        } catch {
            print("Error loading folders: \(error)")
            folders = []
        }
    }
    
    func saveFolders() {
        do {
            let data = try JSONEncoder().encode(folders)
            UserDefaults.standard.set(data, forKey: foldersKey)
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } catch {
            print("Error saving folders: \(error)")
        }
    }
    
    func createFolder(name: String) {
        let newFolder = VideoFolder(name: name)
        folders.append(newFolder)
        saveFolders()
    }
    
    func addVideoToFolder(videoId: UUID, folderId: UUID) {
        guard let index = folders.firstIndex(where: { $0.id == folderId }) else { return }
        if !folders[index].videoIds.contains(videoId) {
            folders[index].videoIds.append(videoId)
            saveFolders()
        }
    }
    
    func getVideosForFolder(folderId: UUID) -> [SavedVideo] {
        guard let folder = folders.first(where: { $0.id == folderId }) else { return [] }
        let allVideos = SavedVideosManager.shared.getSavedVideos()
        return allVideos.filter { folder.videoIds.contains($0.id) }
    }
    
    func deleteFolder(folderId: UUID) {
        folders.removeAll { $0.id == folderId }
        saveFolders()
    }
    
    func renameFolder(folderId: UUID, newName: String) {
        guard let index = folders.firstIndex(where: { $0.id == folderId }) else { return }
        folders[index].name = newName
        saveFolders()
    }
}
