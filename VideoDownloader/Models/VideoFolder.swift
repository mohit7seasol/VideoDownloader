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
    var videoIds: [UUID]
    let isSystemFolder: Bool
    var isDeviceVideos: Bool
    
    init(id: UUID = UUID(), name: String, createdAt: Date = Date(), videoIds: [UUID] = [], isSystemFolder: Bool = false, isDeviceVideos: Bool = false) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.videoIds = videoIds
        self.isSystemFolder = isSystemFolder
        self.isDeviceVideos = isDeviceVideos
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, createdAt, videoIds, isSystemFolder, isDeviceVideos
    }
}

// Folder Manager to handle folder operations
class FolderManager: ObservableObject {
    static let shared = FolderManager()
    private let foldersKey = "videoFolders"
    private let fileManager = FileManager.default
    
    @Published var folders: [VideoFolder] = []
    @Published var deviceVideos: [DeviceVideo] = []
    @Published var isScanningVideos = false
    @Published var lastRefreshTime: Date?
    
    private var refreshTask: DispatchWorkItem?
    
    private init() {
        loadFolders()
        ensureDownloadsFolderExists()
    }
    
    private func ensureDownloadsFolderExists() {
        let downloadsExists = folders.contains { $0.name == "Downloads" && $0.isSystemFolder }
        
        if !downloadsExists {
            let downloadsFolder = VideoFolder(name: "Downloads", isSystemFolder: true, isDeviceVideos: true)
            folders.insert(downloadsFolder, at: 0)
            saveFolders()
            print("✅ Downloads folder created")
        }
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
        
        // For user folders, return app videos
        let allVideos = SavedVideosManager.shared.getSavedVideos()
        return allVideos.filter { folder.videoIds.contains($0.id) }
    }
    
    func getAllVideos() -> [SavedVideo] {
        return SavedVideosManager.shared.getSavedVideos()
    }
    
    func deleteFolder(folderId: UUID) {
        guard let folder = folders.first(where: { $0.id == folderId }) else { return }
        if folder.isSystemFolder {
            print("⚠️ Cannot delete system folder: \(folder.name)")
            return
        }
        folders.removeAll { $0.id == folderId }
        saveFolders()
    }
    
    func renameFolder(folderId: UUID, newName: String) {
        guard let index = folders.firstIndex(where: { $0.id == folderId }) else { return }
        if folders[index].isSystemFolder {
            print("⚠️ Cannot rename system folder: \(folders[index].name)")
            return
        }
        folders[index].name = newName
        saveFolders()
    }
    
    func canDeleteFolder(_ folder: VideoFolder) -> Bool {
        return !folder.isSystemFolder
    }
    
    func canRenameFolder(_ folder: VideoFolder) -> Bool {
        return !folder.isSystemFolder
    }
    
    // Load device videos with fast refresh
    func loadDeviceVideos(forceRefresh: Bool = false, completion: (() -> Void)? = nil) {
        // If we have videos and not forcing refresh, and last refresh was less than 30 seconds ago, use cached data
        if !forceRefresh && !deviceVideos.isEmpty, let lastRefresh = lastRefreshTime, Date().timeIntervalSince(lastRefresh) < 30 {
            print("📱 Using cached device videos (\(deviceVideos.count) videos)")
            completion?()
            return
        }
        
        // Cancel any pending refresh task
        refreshTask?.cancel()
        
        isScanningVideos = true
        
        // Create new refresh task
        let task = DispatchWorkItem { [weak self] in
            VideoScanner.shared.refreshVideos { [weak self] in
                DispatchQueue.main.async {
                    self?.deviceVideos = VideoScanner.shared.deviceVideos
                    self?.isScanningVideos = false
                    self?.lastRefreshTime = Date()
                    self?.objectWillChange.send()
                    print("✅ Loaded \(self?.deviceVideos.count ?? 0) device videos")
                    completion?()
                }
            }
        }
        
        refreshTask = task
        DispatchQueue.global(qos: .userInitiated).async(execute: task)
    }
    
    // Quick load without scanning (use cached data)
    func quickLoadDeviceVideos() {
        deviceVideos = VideoScanner.shared.deviceVideos
        lastRefreshTime = VideoScanner.shared.lastScanTime
        objectWillChange.send()
    }
}
