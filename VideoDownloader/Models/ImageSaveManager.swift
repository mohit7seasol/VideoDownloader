//
//  ImageSaveManager.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 17/04/26.
//

import UIKit
import SwiftUI

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
    
    func saveImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        // Generate unique filename with timestamp
        let timestamp = Date().timeIntervalSince1970
        let filename = "\(Int(timestamp)).jpg"
        let fileURL = savedImagesPath.appendingPathComponent(filename)
        
        // Compress and save image
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
}
