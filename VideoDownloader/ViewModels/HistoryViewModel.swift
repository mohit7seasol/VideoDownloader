//
//  HistoryViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 16/03/26.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class HistoryViewModel: ObservableObject {
    @Published var savedVideos: [SavedVideo] = []
    @Published var isLoading = false
    @Published var showDeleteAlert = false
    @Published var videoToDelete: SavedVideo?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadVideos()
    }
    
    func loadVideos() {
        isLoading = true
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            let videos = SavedVideosManager.shared.getSavedVideos()
            
            // Debug: Print all video paths and check if thumbnails exist
            print("📱 Loading \(videos.count) videos from storage")
            for video in videos {
                let (videoExists, thumbnailExists) = video.validateFiles()
                print("  Video: \(video.id)")
                print("    - Video path: \(video.videoURL.path)")
                print("    - Video exists: \(videoExists)")
                print("    - Thumbnail path: \(video.thumbnailURL?.path ?? "none")")
                print("    - Thumbnail exists: \(thumbnailExists)")
            }
            
            self.savedVideos = videos
            self.isLoading = false
        }
    }
    
    func deleteVideo(_ video: SavedVideo) {
        SavedVideosManager.shared.deleteVideo(video)
        loadVideos()
    }
    
    func confirmDelete(_ video: SavedVideo) {
        videoToDelete = video
        showDeleteAlert = true
    }
    
    func handleDeleteConfirmation(confirmed: Bool) {
        if confirmed, let video = videoToDelete {
            deleteVideo(video)
        }
        videoToDelete = nil
        showDeleteAlert = false
    }
    
    // Remove the regenerateAllThumbnails method as it's causing issues
    // If you need thumbnail regeneration, handle it in the SavedVideoCardView instead
}

// Extension to help with debugging
extension SavedVideo {
    func validateFiles() -> (videoExists: Bool, thumbnailExists: Bool) {
        let fileManager = FileManager.default
        let videoExists = fileManager.fileExists(atPath: videoURL.path)
        let thumbnailExists = thumbnailURL.map { fileManager.fileExists(atPath: $0.path) } ?? false
        return (videoExists, thumbnailExists)
    }
}
