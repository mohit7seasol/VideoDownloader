//
//  WatchVideoView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 14/03/26.
//

import SwiftUI
import AVKit
import Photos
import AVFoundation

struct WatchVideoView: View {
    let videoURL: URL
    let musicTrack: MusicTrack?
    let musicStartTime: Double
    let musicEndTime: Double
    
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showSaveSuccess = false
    @State private var showPermissionAlert = false
    @State private var isSaving = false
    @State private var timeObserver: Any?
    @State private var thumbnailImage: UIImage?
    
    // Calculate dynamic video height
    private var videoHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let navigationBarHeight: CGFloat = 100
        let bottomSectionHeight: CGFloat = 180 // Height for music info + download button + spacing
        let bottomSpacing: CGFloat = 30
        
        return screenHeight - navigationBarHeight - bottomSectionHeight - bottomSpacing - 100
    }
    
    var body: some View {
        ZStack {
            // Background Image
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button {
                        player?.pause()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Soundtrack")
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .frame(height: 100)
                
                // Video Preview
                ZStack {
                    if let player = player {
                        VideoPlayerController(player: player)
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Center Play/Pause Button
                    Button {
                        togglePlay()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 70, height: 70)
                            
                            Image(isPlaying ? "pause_ic" : "play_ic")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .frame(height: videoHeight)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                Spacer(minLength: 20)
                
                // Bottom Section - Music Info and Download Button
                VStack(spacing: 20) {
                    // Music Info (if selected)
                    if let music = musicTrack {
                        HStack(spacing: 12) {
                            // Music Icon
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(music.name)
                                    .font(.custom("Urbanist-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                if let artist = music.artist {
                                    Text(artist)
                                        .font(.custom("Urbanist-Medium", size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                        .lineLimit(1)
                                } else {
                                    Text("\(formatTime(musicStartTime)) - \(formatTime(musicEndTime))")
                                        .font(.custom("Urbanist-Medium", size: 14))
                                        .foregroundColor(Color(hex: "1973E8"))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Download Button - Positioned at bottom
                    Button {
                        saveVideoToGallery()
                    } label: {
                        HStack {
                            Text("Save")
                                .font(.custom("Urbanist-Bold", size: 18))
                            Image("download_ic")
                                .resizable()
                                .frame(width: 16, height: 18)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: Color(hex: "1973E8").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 45)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupPlayer()
            generateThumbnail()
        }
        .onDisappear {
            cleanupPlayer()
        }
        .alert("Video Saved", isPresented: $showSaveSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your video has been saved to gallery and history")
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please grant photo library access to save videos")
        }
        .overlay {
            if isSaving {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Saving video...")
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        
        // Ensure audio plays even when device is on silent
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // Add observer for when video ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            isPlaying = false
            player?.seek(to: .zero)
        }
        
        player?.play()
        isPlaying = true
        
        // Add time observer to track playback state
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { _ in
            isPlaying = player?.rate != 0
        }
    }
    
    private func cleanupPlayer() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player?.pause()
        player = nil
    }
    
    private func togglePlay() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        // isPlaying will be updated by the time observer
    }
    
    private func saveVideoToGallery() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            saveVideo()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        saveVideo()
                    } else {
                        showPermissionAlert = true
                    }
                }
            }
        default:
            showPermissionAlert = true
        }
    }
    
    private func saveVideo() {
        isSaving = true
        
        // First save to photo library
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
            DispatchQueue.main.async {
                isSaving = false
                if success {
                    // Save to UserDefaults
                    saveToHistory()
                    showSaveSuccess = true
                } else {
                    print("Error saving video: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func generateThumbnail() {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 300, height: 300)
        
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            thumbnailImage = UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
        }
    }
    
    private func saveToHistory() {
        // Save thumbnail to Application Support directory (permanent storage)
        var thumbnailURL: URL? = nil
        if let thumbnail = thumbnailImage {
            guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                print("Could not access app support directory")
                return
            }
            
            // Create directory if needed
            try? FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
            
            var thumbnailPath = appSupportDir.appendingPathComponent("thumb_\(UUID().uuidString).jpg")
            
            if let data = thumbnail.jpegData(compressionQuality: 0.7) {
                do {
                    try data.write(to: thumbnailPath)
                    
                    // Exclude from iCloud backup
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try thumbnailPath.setResourceValues(resourceValues)
                    
                    thumbnailURL = thumbnailPath
                    print("Thumbnail saved permanently at: \(thumbnailPath.path)")
                    
                    // Verify file was written
                    if FileManager.default.fileExists(atPath: thumbnailPath.path) {
                        print("✅ Thumbnail file verified at path")
                    } else {
                        print("❌ Thumbnail file not found after writing!")
                    }
                } catch {
                    print("Error saving thumbnail: \(error)")
                }
            }
        }
        
        // Create saved video model
        let savedVideo = SavedVideo(
            videoURL: videoURL,
            thumbnailURL: thumbnailURL,
            musicTrack: musicTrack,
            musicStartTime: musicStartTime,
            musicEndTime: musicEndTime
        )
        
        // Save to UserDefaults
        SavedVideosManager.shared.saveVideo(savedVideo)
    }
}
