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
    
    // Custom coding keys to handle file URLs properly
    enum CodingKeys: String, CodingKey {
        case id, videoURL, thumbnailURL, musicName, musicArtist, musicStartTime, musicEndTime, createdAt, videoFileName
    }
    
    // Custom encoding to handle file URLs
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(videoURL, forKey: .videoURL)
        try container.encode(thumbnailURL, forKey: .thumbnailURL)
        try container.encode(musicName, forKey: .musicName)
        try container.encode(musicArtist, forKey: .musicArtist)
        try container.encode(musicStartTime, forKey: .musicStartTime)
        try container.encode(musicEndTime, forKey: .musicEndTime)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(videoFileName, forKey: .videoFileName)
    }
    
    // Custom decoding to handle file URLs
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        videoURL = try container.decode(URL.self, forKey: .videoURL)
        thumbnailURL = try container.decodeIfPresent(URL.self, forKey: .thumbnailURL)
        musicName = try container.decodeIfPresent(String.self, forKey: .musicName)
        musicArtist = try container.decodeIfPresent(String.self, forKey: .musicArtist)
        musicStartTime = try container.decode(Double.self, forKey: .musicStartTime)
        musicEndTime = try container.decode(Double.self, forKey: .musicEndTime)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        videoFileName = try container.decode(String.self, forKey: .videoFileName)
    }
    
    static func == (lhs: SavedVideo, rhs: SavedVideo) -> Bool {
        return lhs.id == rhs.id
    }
}

// UserDefaults Manager for Saved Videos
class SavedVideosManager {
    static let shared = SavedVideosManager()
    private let savedVideosKey = "savedVideos"
    private let fileManager = FileManager.default
    
    func saveVideo(_ video: SavedVideo) {
        var videos = getSavedVideos()
        videos.insert(video, at: 0)
        saveVideos(videos)
        print("Video saved successfully. Total videos: \(videos.count)")
        
        // Verify thumbnail was saved
        if let thumbnailURL = video.thumbnailURL {
            let exists = fileManager.fileExists(atPath: thumbnailURL.path)
            print("Thumbnail saved at: \(thumbnailURL.path), exists: \(exists)")
        }
    }
    
    func getSavedVideos() -> [SavedVideo] {
        guard let data = UserDefaults.standard.data(forKey: savedVideosKey) else {
            return []
        }
        
        do {
            let videos = try JSONDecoder().decode([SavedVideo].self, from: data)
            print("Loaded \(videos.count) videos from UserDefaults")
            
            // Verify thumbnails exist and clean up if needed
            var validVideos: [SavedVideo] = []
            for video in videos {
                // Check if video file exists
                if !fileManager.fileExists(atPath: video.videoURL.path) {
                    print("Video file missing: \(video.videoURL.lastPathComponent)")
                    continue
                }
                
                // Check if thumbnail exists (if it should)
                if let thumbnailURL = video.thumbnailURL {
                    if !fileManager.fileExists(atPath: thumbnailURL.path) {
                        print("Thumbnail missing for video: \(video.id), will regenerate")
                        // Keep video but thumbnail will be regenerated on demand
                    }
                }
                
                validVideos.append(video)
            }
            
            if validVideos.count != videos.count {
                print("Removed \(videos.count - validVideos.count) invalid videos")
                saveVideos(validVideos) // Save cleaned up list
            }
            
            return validVideos
        } catch {
            print("Error decoding saved videos: \(error)")
            return []
        }
    }
    
    func deleteVideo(_ video: SavedVideo) {
        var videos = getSavedVideos()
        videos.removeAll { $0.id == video.id }
        saveVideos(videos)
        
        // Delete the actual video file
        try? fileManager.removeItem(at: video.videoURL)
        if let thumbnailURL = video.thumbnailURL {
            try? fileManager.removeItem(at: thumbnailURL)
        }
        print("Video deleted successfully. Remaining videos: \(videos.count)")
    }
    
    private func saveVideos(_ videos: [SavedVideo]) {
        do {
            let data = try JSONEncoder().encode(videos)
            UserDefaults.standard.set(data, forKey: savedVideosKey)
            UserDefaults.standard.synchronize() // Force save
            print("Saved \(videos.count) videos to UserDefaults")
        } catch {
            print("Error encoding saved videos: \(error)")
        }
    }
}
