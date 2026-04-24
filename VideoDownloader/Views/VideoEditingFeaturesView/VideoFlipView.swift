//
//  VideoFlipView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 24/04/26.
//

import SwiftUI
import AVKit
import PhotosUI
import CoreImage

struct VideoFlipView: View {
    let videoAsset: VideoAsset
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    @State private var videoURL: URL?
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var rotation: Double = 0
    @State private var isMirror: Bool = false
    @State private var isPlaying = false
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                customNavigationBar
                
                // Video Preview with Transformations
                videoPreviewView
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
                
                // Rotate Controls Section
                rotateControlsSection
                    .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupVideo()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    // MARK: - Custom Navigation Bar
    private var customNavigationBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Flip & Rotate Video".localized(self.language))
                .font(.custom("Poppins-Black", size: isIpad ? 28 : 20))
                .foregroundColor(.white)
                .padding(.leading, 10)
            
            Spacer()
            
            Button(action: {
                applyTransformations()
            }) {
                Text("Apply".localized(self.language))
                    .font(.custom("Urbanist-Bold", size: 16))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, UIApplication.shared.safeAreaTop)
        .padding(.bottom, 10)
    }
    
    // MARK: - Video Preview View
    private var videoPreviewView: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .cornerRadius(12)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(x: isMirror ? -1 : 1, y: 1)
                    .onTapGesture {
                        togglePlayPause()
                    }
                    .overlay(
                        Group {
                            if !isPlaying && !isLoading {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    )
            } else if isLoading {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.white)
                            Text("Loading video...".localized(self.language))
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    )
            }
        }
    }
    
    // MARK: - Rotate Controls Section
    private var rotateControlsSection: some View {
        VStack(spacing: 30) {
            // Rotation Slider
            VStack(spacing: 12) {
                Text("Rotation: \(Int(rotation))°")
                    .font(.custom("Urbanist-Medium", size: 16))
                    .foregroundColor(.white)
                
                // Custom Slider for rotation
                Slider(value: $rotation, in: 0...360, step: 90)
                    .tint(.blue)
                    .onChange(of: rotation) { newValue in
                        // Update rotation in real-time
                    }
            }
            .padding(.horizontal, 40)
            
            // Rotate and Flip Buttons
            HStack(spacing: 40) {
                // Rotate Button (90 degrees)
                Button(action: {
                    rotateVideo()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        Text("Rotate 90°")
                            .font(.custom("Urbanist-Medium", size: 12))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(16)
                }
                
                // Flip/Mirror Button
                Button(action: {
                    toggleMirror()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: isMirror ? "arrow.left.and.right.circle.fill" : "arrow.left.and.right.circle")
                            .font(.system(size: 28))
                            .foregroundColor(isMirror ? .blue : .white)
                        Text("Flip Horizontal")
                            .font(.custom("Urbanist-Medium", size: 12))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(16)
                }
                
                // Reset Button
                Button(action: {
                    resetTransformations()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.red)
                        Text("Reset")
                            .font(.custom("Urbanist-Medium", size: 12))
                            .foregroundColor(.red)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(16)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    private func setupVideo() {
        isLoading = true
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestAVAsset(forVideo: videoAsset.asset, options: options) { avAsset, _, _ in
            DispatchQueue.main.async {
                guard let avAsset = avAsset else {
                    isLoading = false
                    return
                }
                
                self.exportVideoToURL(avAsset: avAsset) { url in
                    if let url = url {
                        self.videoURL = url
                        self.player = AVPlayer(url: url)
                        self.isLoading = false
                    } else {
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func exportVideoToURL(avAsset: AVAsset, completion: @escaping (URL?) -> Void) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        
        if FileManager.default.fileExists(atPath: tempURL.path) {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = tempURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    completion(tempURL)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    private func rotateVideo() {
        rotation += 90
        if rotation >= 360 {
            rotation = 0
        }
    }
    
    private func toggleMirror() {
        isMirror.toggle()
    }
    
    private func resetTransformations() {
        rotation = 0
        isMirror = false
    }
    
    private func applyTransformations() {
        // Apply transformations and save
        player?.pause()
        dismiss()
    }
}
