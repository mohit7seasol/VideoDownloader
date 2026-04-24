//
//  ImageSaveManager.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 17/04/26.
//

import UIKit
import SwiftUI
import AVFoundation

class ImageSaveManager {
    static let shared = ImageSaveManager()
    
    private let fileManager = FileManager.default
    
    private var savedImagesPath: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedImagesPath = documentsPath.appendingPathComponent("SavedImages")
        
        if !fileManager.fileExists(atPath: savedImagesPath.path) {
            try? fileManager.createDirectory(at: savedImagesPath, withIntermediateDirectories: true)
        }
        
        return savedImagesPath
    }
    
    private var savedVideosPath: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedVideosPath = documentsPath.appendingPathComponent("SavedVideos")
        
        if !fileManager.fileExists(atPath: savedVideosPath.path) {
            try? fileManager.createDirectory(at: savedVideosPath, withIntermediateDirectories: true)
        }
        
        return savedVideosPath
    }
    
    // MARK: - Image Methods
    func saveImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        let timestamp = Date().timeIntervalSince1970
        let filename = "\(Int(timestamp)).jpg"
        let fileURL = savedImagesPath.appendingPathComponent(filename)
        
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            do {
                try imageData.write(to: fileURL)
                completion(true)
            } catch {
                print("Error saving image: \(error)")
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    func getAllSavedImages() -> [UIImage] {
        var images: [UIImage] = []
        
        do {
            let imageFiles = try fileManager.contentsOfDirectory(at: savedImagesPath, includingPropertiesForKeys: nil)
            for file in imageFiles {
                if let image = UIImage(contentsOfFile: file.path) {
                    images.append(image)
                }
            }
        } catch {
            print("Error loading images: \(error)")
        }
        
        return images
    }
    
    func deleteImage(at index: Int) {
        do {
            let imageFiles = try fileManager.contentsOfDirectory(at: savedImagesPath, includingPropertiesForKeys: nil)
            if index < imageFiles.count {
                try fileManager.removeItem(at: imageFiles[index])
            }
        } catch {
            print("Error deleting image: \(error)")
        }
    }
    
    // MARK: - Video Methods
    func saveVideo(from url: URL, completion: @escaping (Bool) -> Void) {
        let timestamp = Date().timeIntervalSince1970
        let filename = "\(Int(timestamp)).mp4"
        let destinationURL = savedVideosPath.appendingPathComponent(filename)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: url, to: destinationURL)
            completion(true)
        } catch {
            print("Error saving video: \(error)")
            completion(false)
        }
    }
    
    func getAllSavedVideos() -> [URL] {
        var videos: [URL] = []
        
        do {
            let videoFiles = try fileManager.contentsOfDirectory(at: savedVideosPath, includingPropertiesForKeys: nil)
            for file in videoFiles {
                if file.pathExtension.lowercased() == "mp4" {
                    videos.append(file)
                }
            }
        } catch {
            print("Error loading videos: \(error)")
        }
        
        return videos
    }
    
    func deleteVideo(at index: Int) {
        do {
            let videoFiles = try fileManager.contentsOfDirectory(at: savedVideosPath, includingPropertiesForKeys: nil)
            let mp4Files = videoFiles.filter { $0.pathExtension.lowercased() == "mp4" }
            if index < mp4Files.count {
                try fileManager.removeItem(at: mp4Files[index])
            }
        } catch {
            print("Error deleting video: \(error)")
        }
    }
    
    func getVideoThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let cgImage = try assetGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
}
