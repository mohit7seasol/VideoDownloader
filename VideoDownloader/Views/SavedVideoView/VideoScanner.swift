//
//  VideoScanner.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 20/03/26.
//

import Foundation
import SwiftUI
import AVFoundation
import Photos
import Combine

class VideoScanner: ObservableObject {
    static let shared = VideoScanner()
    @Published var deviceVideos: [DeviceVideo] = []
    @Published var isLoading = false
    @Published var permissionDenied = false
    @Published var lastScanTime: Date?
    
    // Cache for thumbnails
    private var thumbnailCache: [String: UIImage] = [:]
    private let thumbnailCacheQueue = DispatchQueue(label: "thumbnail.cache.queue")
    
    private init() {}
    
    // Force refresh videos
    func refreshVideos(completion: (() -> Void)? = nil) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            scanVideosFromDevice(completion: completion)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.scanVideosFromDevice(completion: completion)
                    } else {
                        self?.permissionDenied = true
                        completion?()
                    }
                }
            }
        case .denied, .restricted:
            permissionDenied = true
            completion?()
        @unknown default:
            break
        }
    }
    
    private func scanVideosFromDevice(completion: (() -> Void)? = nil) {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            
            let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
            
            var tempVideos: [DeviceVideo] = []
            let dispatchGroup = DispatchGroup()
            
            for i in 0..<fetchResult.count {
                dispatchGroup.enter()
                let asset = fetchResult.object(at: i)
                
                // Get video URL
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .fastFormat
                
                PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                    defer { dispatchGroup.leave() }
                    
                    if let urlAsset = avAsset as? AVURLAsset {
                        let videoURL = urlAsset.url
                        
                        // Get cached thumbnail or generate new one
                        let thumbnail = self.getCachedThumbnail(for: asset.localIdentifier) ?? self.generateThumbnail(from: videoURL)
                        
                        // Cache thumbnail
                        if let thumbnail = thumbnail {
                            self.cacheThumbnail(thumbnail, for: asset.localIdentifier)
                        }
                        
                        let deviceVideo = DeviceVideo(
                            id: asset.localIdentifier,
                            videoURL: videoURL,
                            thumbnail: thumbnail,
                            creationDate: asset.creationDate ?? Date(),
                            duration: asset.duration
                        )
                        tempVideos.append(deviceVideo)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.deviceVideos = tempVideos.sorted { $0.creationDate > $1.creationDate }
                self?.isLoading = false
                self?.lastScanTime = Date()
                print("✅ Scanned \(tempVideos.count) videos from device")
                completion?()
            }
        }
    }
    
    private func getCachedThumbnail(for key: String) -> UIImage? {
        return thumbnailCacheQueue.sync {
            return thumbnailCache[key]
        }
    }
    
    private func cacheThumbnail(_ image: UIImage, for key: String) {
        thumbnailCacheQueue.sync {
            thumbnailCache[key] = image
        }
    }
    
    private func generateThumbnail(from videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 200, height: 200)
        
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
    
    func clearCache() {
        thumbnailCacheQueue.sync {
            thumbnailCache.removeAll()
        }
    }
}

// Device Video Model
struct DeviceVideo: Identifiable {
    let id: String
    let videoURL: URL
    let thumbnail: UIImage?
    let creationDate: Date
    let duration: TimeInterval
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
