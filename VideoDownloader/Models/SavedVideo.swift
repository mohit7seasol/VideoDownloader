//
//  SavedVideo.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 16/03/26.
//

import Foundation
import SwiftUI

struct SavedVideo: Identifiable, Codable, Equatable {
    let id: UUID
    let videoURL: URL
    let thumbnailURL: URL?
    let musicName: String?
    let musicArtist: String?
    let musicStartTime: Double
    let musicEndTime: Double
    let createdAt: Date
    let videoFileName: String
    
    init(videoURL: URL, thumbnailURL: URL? = nil, musicTrack: MusicTrack?, musicStartTime: Double, musicEndTime: Double) {
        self.id = UUID()
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.musicName = musicTrack?.name
        self.musicArtist = musicTrack?.artist
        self.musicStartTime = musicStartTime
        self.musicEndTime = musicEndTime
        self.createdAt = Date()
        self.videoFileName = videoURL.lastPathComponent
    }
}

// UserDefaults Manager for Saved Videos
class SavedVideosManager {
    static let shared = SavedVideosManager()
    private let savedVideosKey = "savedVideos"
    
    func saveVideo(_ video: SavedVideo) {
        var videos = getSavedVideos()
        videos.insert(video, at: 0) // Add new video at the beginning
        saveVideos(videos)
    }
    
    func getSavedVideos() -> [SavedVideo] {
        guard let data = UserDefaults.standard.data(forKey: savedVideosKey) else {
            return []
        }
        
        do {
            let videos = try JSONDecoder().decode([SavedVideo].self, from: data)
            return videos
        } catch {
            print("Error decoding saved videos: \(error)")
            return []
        }
    }
    
    func deleteVideo(_ video: SavedVideo) {
        var videos = getSavedVideos()
        videos.removeAll { $0.id == video.id }
        saveVideos(videos)
        
        // Optionally delete the actual video file
        try? FileManager.default.removeItem(at: video.videoURL)
        if let thumbnailURL = video.thumbnailURL {
            try? FileManager.default.removeItem(at: thumbnailURL)
        }
    }
    
    private func saveVideos(_ videos: [SavedVideo]) {
        do {
            let data = try JSONEncoder().encode(videos)
            UserDefaults.standard.set(data, forKey: savedVideosKey)
        } catch {
            print("Error encoding saved videos: \(error)")
        }
    }
}
