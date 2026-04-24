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
                // Header (Same as VideoEditingFrameView)
                headerView
                    .padding(.top, 0)
                
                Spacer()
                
                // Video Preview
                videoPreviewView
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Rotate Controls Section
                rotateControlsSection
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
    
    // MARK: - Header View (Same style as VideoEditingFrameView)
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Flip & Rotate Video".localized(self.language))
                .font(.custom("Poppins-Black", size: isIpad ? 24 : 18))
                .foregroundColor(.white)
            
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
        .padding(.vertical, 10)
    }
    
    // MARK: - Video Preview View
    private var videoPreviewView: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
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
                    .frame(height: UIScreen.main.bounds.height * 0.5)
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
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.blue)
                Text("Rotate & Flip")
                    .font(.custom("Urbanist-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                if rotation != 0 || isMirror {
                    Button(action: {
                        resetTransformations()
                    }) {
                        Text("Reset")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Rotation Slider
            VStack(spacing: 12) {
                Text("Rotation: \(Int(rotation))°")
                    .font(.custom("Urbanist-Medium", size: 16))
                    .foregroundColor(.white)
                
                Slider(value: $rotation, in: 0...360, step: 90)
                    .tint(.blue)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            
            // Rotate and Flip Buttons
            HStack(spacing: 30) {
                // Rotate Button
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
                
                // Flip Button
                Button(action: {
                    toggleMirror()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: isMirror ? "arrow.left.and.right.circle.fill" : "arrow.left.and.right.circle")
                            .font(.system(size: 28))
                            .foregroundColor(isMirror ? .blue : .white)
                        Text("Flip")
                            .font(.custom("Urbanist-Medium", size: 12))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(16)
                }
            }
            .padding(.vertical, 15)
        }
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.7))
                .ignoresSafeArea()
        )
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
        player?.pause()
        dismiss()
    }
}
