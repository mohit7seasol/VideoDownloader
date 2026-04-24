//
//  VideoTrimView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 24/04/26.
//

import SwiftUI
import AVKit
import PhotosUI

struct VideoTrimView: View {
    let videoAsset: VideoAsset
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    @State private var videoURL: URL?
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var currentTime: Double = 0
    @State private var rangeDuration: ClosedRange<Double> = 0...1
    @State private var originalDuration: Double = 0
    @State private var thumbnailsImages: [UIImage] = []
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
                
                // Video Preview
                videoPreviewView
                    .frame(height: UIScreen.main.bounds.height * 0.45)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
                
                // Thumbnails Slider Section
                thumbnailsSliderSection
                    .padding(.bottom, 40)
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
            
            Text("Trim Video".localized(self.language))
                .font(.custom("Poppins-Black", size: isIpad ? 28 : 20))
                .foregroundColor(.white)
                .padding(.leading, 10)
            
            Spacer()
            
            Button(action: {
                applyTrim()
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
    
    // MARK: - Thumbnails Slider Section
    private var thumbnailsSliderSection: some View {
        VStack(spacing: 16) {
            // Duration text
            Text(formatDuration(rangeDuration.upperBound - rangeDuration.lowerBound))
                .font(.custom("Urbanist-Bold", size: 18))
                .foregroundColor(.white)
            
            // Thumbnails Slider
            GeometryReader { proxy in
                ZStack {
                    // Thumbnails
                    HStack(spacing: 0) {
                        ForEach(0..<thumbnailsImages.count, id: \.self) { index in
                            if index < thumbnailsImages.count {
                                Image(uiImage: thumbnailsImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: proxy.size.width / CGFloat(thumbnailsImages.count),
                                           height: 70)
                                    .clipped()
                            }
                        }
                    }
                    .cornerRadius(8)
                    
                    // Ranged Slider Overlay
                    RangedSliderView(
                        value: $rangeDuration,
                        bounds: 0...originalDuration,
                        onEndChange: {
                            seekToTime(rangeDuration.upperBound)
                        }
                    ) {
                        Rectangle()
                            .fill(Color.clear)
                    }
                }
                .frame(width: proxy.size.width, height: 70)
            }
            .frame(height: 70)
            .padding(.horizontal, 20)
            
            // Trim buttons
            HStack(spacing: 20) {
                Button(action: {
                    resetTrim()
                }) {
                    Text("Reset".localized(self.language))
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.3))
                        .cornerRadius(20)
                }
            }
            .padding(.top, 10)
        }
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
                
                self.originalDuration = avAsset.duration.seconds
                self.rangeDuration = 0...self.originalDuration
                
                self.exportVideoToURL(avAsset: avAsset) { url in
                    if let url = url {
                        self.videoURL = url
                        self.player = AVPlayer(url: url)
                        self.generateThumbnails(from: avAsset)
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
    
    private func generateThumbnails(from avAsset: AVAsset) {
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        let numberOfThumbnails = 10
        let duration = avAsset.duration.seconds
        var images: [UIImage] = []
        
        for i in 0..<numberOfThumbnails {
            let time = CMTime(seconds: (duration / Double(numberOfThumbnails)) * Double(i), preferredTimescale: 600)
            
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                images.append(UIImage(cgImage: cgImage))
            } catch {
                print("Error generating thumbnail: \(error)")
            }
        }
        
        DispatchQueue.main.async {
            self.thumbnailsImages = images
        }
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
            isPlaying = false
        } else {
            // Seek to current range start if needed
            if player.currentTime().seconds < rangeDuration.lowerBound ||
               player.currentTime().seconds > rangeDuration.upperBound {
                seekToTime(rangeDuration.lowerBound)
            }
            player.play()
            isPlaying = true
        }
    }
    
    private func seekToTime(_ time: Double) {
        let clampedTime = min(max(time, rangeDuration.lowerBound), rangeDuration.upperBound)
        player?.seek(to: CMTime(seconds: clampedTime, preferredTimescale: 600))
        currentTime = clampedTime
    }
    
    private func resetTrim() {
        rangeDuration = 0...originalDuration
        seekToTime(0)
    }
    
    private func applyTrim() {
        // Apply trim and save
        player?.pause()
        dismiss()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Ranged Slider View
struct RangedSliderView<Overlay: View>: View {
    @Binding var value: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let onEndChange: () -> Void
    let overlay: Overlay
    
    @State private var startDragging = false
    @State private var endDragging = false
    
    init(value: Binding<ClosedRange<Double>>,
         bounds: ClosedRange<Double>,
         onEndChange: @escaping () -> Void,
         @ViewBuilder overlay: () -> Overlay) {
        self._value = value
        self.bounds = bounds
        self.onEndChange = onEndChange
        self.overlay = overlay()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                overlay
                
                // Left thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .position(x: thumbPosition(value.lowerBound, in: geometry),
                              y: geometry.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = valueFromPosition(gesture.location.x, in: geometry)
                                let clampedValue = min(max(newValue, bounds.lowerBound), value.upperBound - 0.1)
                                value = clampedValue...value.upperBound
                                startDragging = true
                            }
                            .onEnded { _ in
                                startDragging = false
                                onEndChange()
                            }
                    )
                
                // Right thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .position(x: thumbPosition(value.upperBound, in: geometry),
                              y: geometry.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = valueFromPosition(gesture.location.x, in: geometry)
                                let clampedValue = min(max(newValue, value.lowerBound + 0.1), bounds.upperBound)
                                value = value.lowerBound...clampedValue
                                endDragging = true
                            }
                            .onEnded { _ in
                                endDragging = false
                                onEndChange()
                            }
                    )
                
                // Selected range overlay
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: rangeWidth(in: geometry),
                           height: geometry.size.height)
                    .position(x: rangeCenter(in: geometry),
                              y: geometry.size.height / 2)
            }
        }
    }
    
    private func thumbPosition(_ value: Double, in geometry: GeometryProxy) -> CGFloat {
        let percent = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return percent * geometry.size.width
    }
    
    private func rangeWidth(in geometry: GeometryProxy) -> CGFloat {
        let startPercent = (value.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        let endPercent = (value.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return (endPercent - startPercent) * geometry.size.width
    }
    
    private func rangeCenter(in geometry: GeometryProxy) -> CGFloat {
        let startPercent = (value.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        let endPercent = (value.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        let centerPercent = (startPercent + endPercent) / 2
        return centerPercent * geometry.size.width
    }
    
    private func valueFromPosition(_ position: CGFloat, in geometry: GeometryProxy) -> Double {
        let percent = position / geometry.size.width
        return bounds.lowerBound + percent * (bounds.upperBound - bounds.lowerBound)
    }
}
