//
//  WatchVideoView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 14/03/26.
//

import SwiftUI
import AVKit
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
    @State private var isSaving = false
    @State private var timeObserver: Any?
    @State private var thumbnailImage: UIImage?
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    // Calculate dynamic video height
    private var videoHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let navigationBarHeight: CGFloat = 100
        let bottomSectionHeight: CGFloat = 180
        let bottomSpacing: CGFloat = 30
        
        return screenHeight - navigationBarHeight - bottomSectionHeight - bottomSpacing - 100
    }
    
    var body: some View {
        if Device.isIpad {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Background Image
                    Image("app_bg_image")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                    
                    VStack(spacing: 0) {
                        // MARK: - Fixed Header (Not Scrollable)
                        VStack(spacing: 0) {
                            // Navigation Bar
                            HStack {
                                Button {
                                    player?.pause()
                                    dismiss()
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: Device.isIpad ? 24 : 20, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.leading, Device.isIpad ? 8 : 0)
                                }
                                
                                Text("Soundtrack".localized(self.language))
                                    .font(.custom("Poppins-Black", size: Device.isIpad ? 24 : 20))
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                
                                Spacer()
                            }
                            .padding(.horizontal, Device.isIpad ? 32 : 24)
                            .padding(.top, UIApplication.shared.safeAreaTop + 20)
                            .padding(.bottom, Device.isIpad ? 30 : 20)
                        }
                        .background(Color.clear)
                        
                        // MARK: - Scrollable Content
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                // Video Preview
                                ZStack {
                                    if let player = player {
                                        VideoPlayerController(player: player)
                                            .cornerRadius(Device.isIpad ? 32 : 24)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Device.isIpad ? 32 : 24)
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
                                                .frame(width: Device.isIpad ? 90 : 70, height: Device.isIpad ? 90 : 70)
                                            
                                            Image(isPlaying ? "pause_ic" : "play_ic")
                                                .resizable()
                                                .frame(width: Device.isIpad ? 50 : 40, height: Device.isIpad ? 50 : 40)
                                        }
                                    }
                                }
                                .frame(height: Device.isIpad ? geometry.size.height * 0.5 : geometry.size.height * 0.4)
                                .padding(.horizontal, Device.isIpad ? 32 : 24)
                                .padding(.top, Device.isIpad ? 20 : 10)
                                .padding(.bottom, Device.isIpad ? 30 : 20)
                                
                                // Bottom Section - Music Info and Download Button
                                VStack(spacing: Device.isIpad ? 30 : 20) {
                                    // Music Info (if selected)
                                    if let music = musicTrack {
                                        HStack(spacing: Device.isIpad ? 16 : 12) {
                                            // Music Icon
                                            RoundedRectangle(cornerRadius: Device.isIpad ? 12 : 8)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: Device.isIpad ? 70 : 50, height: Device.isIpad ? 70 : 50)
                                                .overlay(
                                                    Image(systemName: "music.note")
                                                        .font(.system(size: Device.isIpad ? 28 : 20))
                                                        .foregroundColor(.white)
                                                )
                                            
                                            VStack(alignment: .leading, spacing: Device.isIpad ? 8 : 4) {
                                                Text(music.name)
                                                    .font(.custom("Urbanist-Bold", size: Device.isIpad ? 20 : 16))
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                
                                                if let artist = music.artist {
                                                    Text(artist)
                                                        .font(.custom("Urbanist-Medium", size: Device.isIpad ? 16 : 14))
                                                        .foregroundColor(.white.opacity(0.6))
                                                        .lineLimit(1)
                                                } else {
                                                    Text("\(formatTime(musicStartTime)) - \(formatTime(musicEndTime))")
                                                        .font(.custom("Urbanist-Medium", size: Device.isIpad ? 16 : 14))
                                                        .foregroundColor(Color(hex: "1973E8"))
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, Device.isIpad ? 32 : 24)
                                    }
                                    
                                    // Download Button
                                    Button {
                                        saveVideoToLocalStorage()
                                    } label: {
                                        HStack {
                                            Text("Save".localized(self.language))
                                                .font(.custom("Urbanist-Bold", size: Device.isIpad ? 22 : 18))
                                            Image("download_ic")
                                                .resizable()
                                                .frame(width: Device.isIpad ? 20 : 16, height: Device.isIpad ? 22 : 18)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, Device.isIpad ? 20 : 16)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(Device.isIpad ? 40 : 30)
                                        .shadow(color: Color(hex: "1973E8").opacity(0.3), radius: 10, x: 0, y: 5)
                                    }
                                    .padding(.horizontal, Device.isIpad ? 32 : 24)
                                }
                                
                                // Bottom padding
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: UIApplication.shared.safeAreaBottom + (Device.isIpad ? 60 : 45))
                            }
                        }
                    }
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
            .alert("Success".localized(self.language), isPresented: $showSaveSuccess) {
                Button("OK".localized(self.language)) {
                    // ✅ Navigate to root view (HomeSegmentView) like VideoTrimView
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.dismiss(animated: true) {
                            // Navigate to home or pop to root
                            if let navController = rootVC as? UINavigationController {
                                navController.popToRootViewController(animated: true)
                            }
                        }
                    }
                    dismiss()
                }
            } message: {
                Text("Video saved successfully!".localized(self.language))
            }
            .overlay {
                if isSaving {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(Device.isIpad ? 2.0 : 1.5)
                                .tint(.white)
                            
                            Text("Saving video...".localized(self.language))
                                .font(.custom("Urbanist-Medium", size: Device.isIpad ? 18 : 16))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .ignoresSafeArea()
        } else {
            // iPhone Layout
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
                        
                        Text("Soundtrack".localized(self.language))
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
                            saveVideoToLocalStorage()
                        } label: {
                            HStack {
                                Text("Save".localized(self.language))
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
            .alert("Success".localized(self.language), isPresented: $showSaveSuccess) {
                Button("OK".localized(self.language)) {
                    // ✅ Navigate to root view (HomeSegmentView) like VideoTrimView
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.dismiss(animated: true) {
                            // Navigate to home or pop to root
                            if let navController = rootVC as? UINavigationController {
                                navController.popToRootViewController(animated: true)
                            }
                        }
                    }
                    dismiss()
                }
            } message: {
                Text("Video saved successfully!".localized(self.language))
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
                            
                            Text("Saving video...".localized(self.language))
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white)
                        }
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
    }
    
    private func saveVideoToLocalStorage() {
        isSaving = true
        
        // ✅ SAVE ONLY TO LOCAL STORAGE - NOT TO PHOTO GALLERY
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedVideosPath = documentsPath.appendingPathComponent("SavedVideos")
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: savedVideosPath.path) {
            do {
                try FileManager.default.createDirectory(at: savedVideosPath, withIntermediateDirectories: true)
                print("📁 Created SavedVideos directory")
            } catch {
                print("❌ Error creating SavedVideos directory: \(error)")
                isSaving = false
                return
            }
        }
        
        // Create unique filename with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "video_\(timestamp).mp4"
        let destinationURL = savedVideosPath.appendingPathComponent(filename)
        
        // Copy video from temporary location to SavedVideos folder
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: videoURL, to: destinationURL)
            
            print("✅ Video saved to local storage: \(destinationURL.path)")
            print("📱 This video is NOT in your device's Photos app")
            
            // Save to history with new URL
            saveToHistory(with: destinationURL)
            
            isSaving = false
            
            // ✅ Show success alert instead of directly navigating
            showSaveSuccess = true
            
        } catch {
            print("❌ Error saving video: \(error)")
            isSaving = false
        }
    }
    
    private func saveToHistory(with savedVideoURL: URL) {
        // Save thumbnail to Application Support directory
        var thumbnailURL: URL? = nil
        if let thumbnail = thumbnailImage {
            guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                return
            }
            
            try? FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
            
            var thumbnailPath = appSupportDir.appendingPathComponent("thumb_\(UUID().uuidString).jpg")
            
            if let data = thumbnail.jpegData(compressionQuality: 0.7) {
                do {
                    try data.write(to: thumbnailPath)
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try thumbnailPath.setResourceValues(resourceValues)
                    thumbnailURL = thumbnailPath
                    print("✅ Thumbnail saved at: \(thumbnailPath.path)")
                } catch {
                    print("Error saving thumbnail: \(error)")
                }
            }
        }
        
        // Create saved video model with the new local URL
        let savedVideo = SavedVideo(
            videoURL: savedVideoURL,
            thumbnailURL: thumbnailURL,
            musicTrack: musicTrack,
            musicStartTime: musicStartTime,
            musicEndTime: musicEndTime
        )
        
        // Save to UserDefaults
        SavedVideosManager.shared.saveVideo(savedVideo)
        print("✅ Video added to history")
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
}
