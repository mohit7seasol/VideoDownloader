//
//  LinkViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 16/03/26.
//

import Foundation
import SwiftUI
import Photos
import Combine
import AVFoundation

enum ContentType {
    case youTube
    case tikTok
    case instagram
    case facebook
    case unknown
}

enum InstagramMediaType: String {
    case reel, post, igtv
}

// MARK: - API Response Models (keep these as they are)
struct FacebookAPIResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: FacebookMediaResponse?
}

struct FacebookMediaResponse: Decodable {
    let description: String?
    let updated_time: String?
    let icon: String?
    let name: String?
    let picture: String?
    let source: String?
    let id: String?
    let message: String?
    let from: FacebookUser?
    let attachments: FacebookAttachments?
}

struct FacebookUser: Decodable {
    let name: String?
    let id: String?
}

struct FacebookAttachments: Decodable {
    let data: [FacebookAttachmentItem]?
}

struct FacebookAttachmentItem: Decodable {
    let media: FacebookAttachmentMedia?
    let subattachments: FacebookSubAttachments?
    let type: String?
}

struct FacebookAttachmentMedia: Decodable {
    let image: FacebookAttachmentImage?
    let source: String?
}

struct FacebookAttachmentImage: Decodable {
    let src: String?
    let width: Int?
    let height: Int?
}

struct FacebookSubAttachments: Decodable {
    let data: [FacebookAttachmentItem]?
}

struct InstagramMediaResponse: Decodable {
    let id: String?
    let shortcode: String?
    let display_url: String?
    let dimensions: Dimensions?
    let video_url: String?
    let is_video: Bool?
    let title: String?
    let caption_is_edited: Bool?
    let edge_sidecar_to_children: MultiPost?
    
    struct Dimensions: Decodable {
        let height: Int?
        let width: Int?
    }
}

struct MultiPost: Decodable {
    let edges: [MultiPostEdges]?
}

struct MultiPostEdges: Decodable {
    let node: MultiPostNode?
}

struct MultiPostNode: Decodable {
    let display_url: String?
}

// MARK: - LinkViewModel
class LinkViewModel: ObservableObject {
    @Published var postLink: String = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSaving = false
    
    private var cancellables = Set<AnyCancellable>()
    private var tabManager: TabSelectionManager?
    
    // API Keys
    private let youtubeAPIToken = "4c8a6959d4mshdda890c244de333p1a9559jsnfa944e297289"
    private let instagramAPIToken = "4c8a6959d4mshdda890c244de333p1a9559jsnfa944e297289"
    private let facebookAPIToken = "4c8a6959d4mshdda890c244de333p1a9559jsnfa944e297289"
    private let tiktokAPIToken = "4c8a6959d4mshdda890c244de333p1a9559jsnfa944e297289"
    
    // Method to set tab manager
    func setTabManager(_ manager: TabSelectionManager) {
        self.tabManager = manager
    }
    
    // MARK: - Public Methods
    func handlePaste() {
        if let clipboard = UIPasteboard.general.string, !clipboard.isEmpty {
            postLink = clipboard
        } else {
            alertMessage = "No copied text found to paste."
            showAlert = true
        }
    }
    
    func downloadVideo() {
        guard !isSaving else {
            print("⛔ Save already in progress – skipped")
            return
        }
        
        // Validate URL
        let webURL = postLink.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !webURL.isEmpty else {
            alertMessage = "URL cannot be empty"
            showAlert = true
            return
        }
        
        guard let validURL = URL(string: webURL),
              ["http", "https"].contains(validURL.scheme?.lowercased()) else {
            alertMessage = "Please enter a valid URL"
            showAlert = true
            return
        }
        
        isSaving = true
        isLoading = true
        
        let lowerURL = webURL.lowercased()
        
        // YouTube
        if lowerURL.contains("youtube.com") || lowerURL.contains("youtu.be") {
            handleYouTubeURL(webURL)
            return
        }
        
        // Instagram
        if isInstagramURL(webURL) {
            handleInstagramURL(webURL)
            return
        }
        
        // Facebook
        if isFacebookURL(webURL) {
            handleFacebookURL(webURL)
            return
        }
        
        // TikTok
        if lowerURL.contains("tiktok.com") || lowerURL.contains("vm.tiktok.com") {
            handleTikTokURL(webURL)
            return
        }
        
        // Simple URL (no media) - Save as bookmark
        saveSimpleURLToHistory(webURL: webURL)
    }
    
    // MARK: - Save to History using SavedVideo model (same as edited videos)
    private func saveToHistory(videoURL: URL, thumbnailURL: URL? = nil, sourceURL: String) {
        
        // Create SavedVideo object - Passing nil for musicTrack since this is a downloaded video
        let savedVideo = SavedVideo(
            videoURL: videoURL,
            thumbnailURL: thumbnailURL,
            musicTrack: nil,  // No music track for downloaded videos
            musicStartTime: 0,
            musicEndTime: 0
        )
        
        // Save to UserDefaults using SavedVideosManager (same as WatchVideoView)
        SavedVideosManager.shared.saveVideo(savedVideo)
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isSaving = false
            self?.postLink = ""
            self?.alertMessage = "Video downloaded and saved to history!"
            self?.showAlert = true
        }
    }
    
    private func saveSimpleURLToHistory(webURL: String) {
        // For simple URLs, create a bookmark entry
        let dummyURL = URL(string: webURL) ?? URL(string: "https://google.com")!
        
        let savedVideo = SavedVideo(
            videoURL: dummyURL,
            thumbnailURL: nil,
            musicTrack: nil,  // No music track for bookmarks
            musicStartTime: 0,
            musicEndTime: 0
        )
        
        SavedVideosManager.shared.saveVideo(savedVideo)
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isSaving = false
            self?.postLink = ""
            self?.alertMessage = "Link saved to history!"
            self?.showAlert = true
        }
    }
    
    // MARK: - Generate Thumbnail from Video
    private func generateThumbnail(from videoURL: URL) -> URL? {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 300, height: 300)
        
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            // Save thumbnail to temporary directory
            let tempDir = FileManager.default.temporaryDirectory
            let thumbnailPath = tempDir.appendingPathComponent("thumbnail_\(UUID().uuidString).jpg")
            
            if let data = thumbnail.jpegData(compressionQuality: 0.7) {
                try data.write(to: thumbnailPath)
                return thumbnailPath
            }
        } catch {
            print("Error generating thumbnail: \(error)")
        }
        
        return nil
    }
    
    // MARK: - YouTube Handling
    private func handleYouTubeURL(_ urlString: String) {
        guard let videoID = extractYouTubeVideoID(from: urlString) else {
            showError("Could not extract video ID")
            return
        }
        
        guard let apiURL = URL(string: "https://youtube-media-downloader.p.rapidapi.com/v2/video/details?videoId=\(videoID)") else {
            showError("Invalid API URL")
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue(youtubeAPIToken, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("youtube-media-downloader.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self?.showError("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let videos = json["videos"] as? [String: Any],
                       let items = videos["items"] as? [[String: Any]],
                       let first = items.first,
                       let urlStr = first["url"] as? String,
                       let videoURL = URL(string: urlStr) {
                        
                        self?.downloadMedia(from: videoURL, sourceURL: urlString)
                    } else {
                        self?.showError("Failed to parse video URL")
                    }
                } catch {
                    self?.showError(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: - Instagram Handling
    private func handleInstagramURL(_ urlString: String) {
        guard let (shortcode, _) = extractInstagramShortcode(from: urlString) else {
            showError("Invalid Instagram URL")
            return
        }
        
        guard let apiURL = URL(string: "https://instagram-scraper-stable-api.p.rapidapi.com/get_media_data_v2.php?media_code=\(shortcode)") else {
            showError("Invalid API URL")
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue(instagramAPIToken, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("instagram-scraper-stable-api.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self?.showError("No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let mediaResponse = try decoder.decode(InstagramMediaResponse.self, from: data)
                    
                    // Get video URL for reels, image URL for posts
                    if let isVideo = mediaResponse.is_video, isVideo,
                       let videoURL = mediaResponse.video_url,
                       let url = URL(string: videoURL) {
                        self?.downloadMedia(from: url, sourceURL: urlString)
                    } else if let imageURL = mediaResponse.display_url,
                              let url = URL(string: imageURL) {
                        self?.downloadMedia(from: url, sourceURL: urlString)
                    } else {
                        self?.showError("No media found in Instagram URL")
                    }
                    
                } catch {
                    self?.showError(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: - Facebook Handling
    private func handleFacebookURL(_ urlString: String) {
        resolveFacebookShareURL(urlString) { [weak self] resolvedURL in
            guard let resolvedURL = resolvedURL else {
                self?.showError("Invalid Facebook URL")
                return
            }
            
            guard let mediaID = self?.extractFacebookMediaID(from: resolvedURL) else {
                self?.showError("Could not extract media ID")
                return
            }
            
            let apiURL = URL(string: "https://facebook-data-api2.p.rapidapi.com/graph/\(mediaID)")!
            var request = URLRequest(url: apiURL)
            request.httpMethod = "GET"
            request.setValue(self?.facebookAPIToken, forHTTPHeaderField: "x-rapidapi-key")
            request.setValue("facebook-data-api2.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showError(error.localizedDescription)
                        return
                    }
                    
                    guard let data = data else {
                        self?.showError("No data received")
                        return
                    }
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(FacebookAPIResponse.self, from: data)
                        
                        guard let mediaInfo = apiResponse.data else {
                            self?.showError("No media info found")
                            return
                        }
                        
                        // Get video URL
                        if let videoURLString = mediaInfo.source,
                           let videoURL = URL(string: videoURLString) {
                            self?.downloadMedia(from: videoURL, sourceURL: urlString)
                        }
                        // Get image URL
                        else if let imageURLString = mediaInfo.picture,
                                let imageURL = URL(string: imageURLString) {
                            self?.downloadMedia(from: imageURL, sourceURL: urlString)
                        }
                        else {
                            self?.showError("No media found in Facebook URL")
                        }
                        
                    } catch {
                        self?.showError(error.localizedDescription)
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - TikTok Handling
    private func handleTikTokURL(_ urlString: String) {
        guard let videoID = extractTikTokVideoID(from: urlString),
              let url = URL(string: "https://tiktok-api23.p.rapidapi.com/api/post/detail?videoId=\(videoID)") else {
            showError("Invalid TikTok URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(tiktokAPIToken, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("tiktok-api23.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self?.showError("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let itemInfo = json["itemInfo"] as? [String: Any],
                       let itemStruct = itemInfo["itemStruct"] as? [String: Any],
                       let video = itemStruct["video"] as? [String: Any],
                       let bitrateInfo = video["bitrateInfo"] as? [[String: Any]],
                       let first = bitrateInfo.first,
                       let playAddr = first["PlayAddr"] as? [String: Any],
                       let urlList = playAddr["UrlList"] as? [String],
                       let lastURL = urlList.last,
                       let videoURL = URL(string: lastURL) {
                        
                        self?.downloadMedia(from: videoURL, sourceURL: urlString)
                    } else {
                        self?.showError("Failed to parse video URL")
                    }
                } catch {
                    self?.showError(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: - Download Helpers
    private func downloadMedia(from url: URL, sourceURL: String) {
        URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
            DispatchQueue.main.async {
                guard let tempURL = tempURL, error == nil else {
                    self?.showError("Download failed: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.saveDownloadedMedia(at: tempURL, sourceURL: sourceURL)
            }
        }.resume()
    }
    
    private func saveDownloadedMedia(at tempURL: URL, sourceURL: String) {
        guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            showError("Could not access app support directory")
            return
        }
        
        try? FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
        
        let fileName = "downloaded_\(Int(Date().timeIntervalSince1970)).mp4"
        var localURL = appSupportDir.appendingPathComponent(fileName)
        
        do {
            try? FileManager.default.removeItem(at: localURL)
            try FileManager.default.moveItem(at: tempURL, to: localURL)
            
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try localURL.setResourceValues(resourceValues)
            
            print("✅ Video saved at: \(localURL.path)")
            
            // Generate thumbnail
            let thumbnailURL = generateThumbnail(from: localURL)
            
            // Save to history using SavedVideo model
            self.saveToHistory(videoURL: localURL, thumbnailURL: thumbnailURL, sourceURL: sourceURL)
            
        } catch {
            showError("Failed to save file: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    private func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isSaving = false
            self?.alertMessage = message
            self?.showAlert = true
        }
    }
    
    func getDomainName(from urlString: String) -> String? {
        if let url = URL(string: urlString), let host = url.host {
            let components = host.components(separatedBy: ".")
            if components.count >= 2 {
                var domainName = components[components.count - 2]
                domainName = domainName.prefix(1).uppercased() + domainName.dropFirst()
                return domainName
            }
        }
        return nil
    }
    
    // MARK: - URL Detection Methods
    private func isInstagramURL(_ urlString: String) -> Bool {
        let lowercasedURL = urlString.lowercased()
        return lowercasedURL.contains("instagram.com/reel") ||
               lowercasedURL.contains("instagram.com/p/") ||
               lowercasedURL.contains("instagram.com/tv/") ||
               lowercasedURL.contains("instagram.com/stories/")
    }
    
    private func isFacebookURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString.lowercased()),
              let host = url.host else {
            return false
        }
        return host.contains("facebook.com") || host.contains("fb.watch")
    }
    
    // MARK: - Extraction Methods
    private func extractYouTubeVideoID(from urlString: String) -> String? {
        let patterns = [
            #"youtu\.be/([A-Za-z0-9_-]{11})"#,
            #"youtube\.com/watch.*v=([A-Za-z0-9_-]{11})"#,
            #"youtube\.com/shorts/([A-Za-z0-9_-]{11})"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: urlString, range: NSRange(urlString.startIndex..., in: urlString)),
               match.numberOfRanges > 1,
               let range = Range(match.range(at: 1), in: urlString) {
                return String(urlString[range])
            }
        }
        return nil
    }
    
    private func extractInstagramShortcode(from urlString: String) -> (String, InstagramMediaType)? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let pathComponents = url.pathComponents
        guard pathComponents.count > 2 else { return nil }
        
        let typeString = pathComponents[1]
        let shortcode = pathComponents[2]
        
        switch typeString {
        case "reel":
            return (shortcode, .reel)
        case "p":
            return (shortcode, .post)
        case "tv":
            return (shortcode, .igtv)
        default:
            return nil
        }
    }
    
    private func extractFacebookMediaID(from url: String) -> String? {
        guard let components = URLComponents(string: url) else {
            return nil
        }
        
        let pathComponents = components.path.split(separator: "/").map { String($0) }
        
        // reels
        if let index = pathComponents.firstIndex(of: "reel"),
           index + 1 < pathComponents.count {
            return pathComponents[index + 1]
        }
        
        // videos
        if let index = pathComponents.firstIndex(of: "videos"),
           index + 1 < pathComponents.count {
            return pathComponents[index + 1]
        }
        
        // posts
        if let index = pathComponents.firstIndex(of: "posts"),
           index + 1 < pathComponents.count {
            return pathComponents[index + 1]
        }
        
        // permalink.php
        if components.path.contains("permalink"),
           let queryItems = components.queryItems,
           let story = queryItems.first(where: { $0.name == "story_fbid" })?.value {
            return story
        }
        
        // numeric fallback
        for part in pathComponents.reversed() {
            if part.allSatisfy({ $0.isNumber }) {
                return part
            }
        }
        
        return nil
    }
    
    private func extractTikTokVideoID(from urlString: String) -> String? {
        let pattern = "/video/(\\d+)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let nsString = urlString as NSString
        let results = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first, match.numberOfRanges > 1 {
            let range = match.range(at: 1)
            return nsString.substring(with: range)
        }
        
        return nil
    }
    
    private func resolveFacebookShareURL(_ urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            let finalURL = (response as? HTTPURLResponse)?.url?.absoluteString
            completion(finalURL)
        }.resume()
    }
}
