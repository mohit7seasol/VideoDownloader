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
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showSaveSuccess = false
    @State private var showPermissionAlert = false
    @State private var isSaving = false
    
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
                
                Spacer()
                
                // Video Preview
                ZStack {
                    if let player = player {
                        VideoPlayerController(player: player)
                            .frame(height: 400)
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
                            
                            Text("Added to video")
                                .font(.custom("Urbanist-Medium", size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
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
        player?.play()
        isPlaying = true
    }
    
    private func togglePlay() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
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
}
