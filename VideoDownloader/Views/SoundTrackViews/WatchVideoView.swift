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
    
    // Calculate dynamic video height
    private var videoHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let navigationBarHeight: CGFloat = 100
        let musicInfoHeight: CGFloat = musicTrack != nil ? 80 : 0
        let bottomSpacing: CGFloat = 50
        
        return screenHeight - navigationBarHeight - musicInfoHeight - bottomSpacing - 150
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
                    
                    Spacer()
                    
                    Text("Soundtrack")
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    // Save Button
                    Button {
                        saveVideoToGallery()
                    } label: {
                        Text("Save")
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer(minLength: 20)
                
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
                    
                    // Center Play/Pause Button (60x60)
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
                            
                            if let artist = music.artist {
                                Text(artist)
                                    .font(.custom("Urbanist-Medium", size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            } else {
                                // Show selected time range
                                Text("\(formatTime(musicStartTime)) - \(formatTime(musicEndTime))")
                                    .font(.custom("Urbanist-Medium", size: 14))
                                    .foregroundColor(Color(hex: "1973E8"))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                
                Spacer(minLength: 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
        .alert("Video Saved", isPresented: $showSaveSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your video has been saved to gallery")
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
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
            DispatchQueue.main.async {
                isSaving = false
                if success {
                    showSaveSuccess = true
                } else {
                    // Handle error
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
}
