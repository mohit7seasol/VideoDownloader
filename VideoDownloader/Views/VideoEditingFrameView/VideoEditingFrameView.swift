//
//  VideoEditingFrameView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 23/04/26.
//

import SwiftUI
import AVKit
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Combine

// MARK: - Filter Model
struct VideoFilter: Identifiable {
    let id = UUID()
    let name: String
    let displayName: String
    let filter: CIFilter?
    let iconName: String
    
    init(name: String, displayName: String, filter: CIFilter? = nil, iconName: String = "camera.filters") {
        self.name = name
        self.displayName = displayName
        self.filter = filter
        self.iconName = iconName
    }
}

// MARK: - VideoPlayerManager
class VideoPlayerManager: ObservableObject {
    @Published var videoPlayer = AVPlayer()
    @Published var isPlaying: Bool = false
    private var timeObserver: Any?
    private var playerItem: AVPlayerItem?
    
    deinit {
        if let timeObserver = timeObserver {
            videoPlayer.removeTimeObserver(timeObserver)
        }
    }
    
    func loadVideo(from url: URL) {
        playerItem = AVPlayerItem(url: url)
        videoPlayer = AVPlayer(playerItem: playerItem)
        startTimer()
    }
    
    func play() {
        videoPlayer.play()
        isPlaying = true
    }
    
    func pause() {
        videoPlayer.pause()
        isPlaying = false
    }
    
    private func startTimer() {
        let interval = CMTimeMake(value: 1, timescale: 10)
        timeObserver = videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.isPlaying = self?.videoPlayer.timeControlStatus == .playing
        }
    }
    
    func setFilters(mainFilter: CIFilter?, colorCorrection: Any? = nil) {
        guard let mainFilter = mainFilter, let currentItem = videoPlayer.currentItem else { return }
        pause()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let composition = currentItem.asset.setFilter(mainFilter)
            DispatchQueue.main.async {
                self?.videoPlayer.currentItem?.videoComposition = composition
            }
        }
    }
    
    func removeFilter() {
        pause()
        videoPlayer.currentItem?.videoComposition = nil
    }
}

// MARK: - Video Editing Frame View
struct VideoEditingFrameView: View {
    @Environment(\.dismiss) var dismiss
    let videoAsset: VideoAsset
    
    @StateObject private var videoPlayerManager = VideoPlayerManager()
    @State private var isLoading = true
    @State private var videoURL: URL?
    @State private var showSuccessAlert = false
    @State private var navigateToHome = false
    
    // Filter settings
    @State private var availableFilters: [VideoFilter] = []
    @State private var selectedFilterName: String?
    
    private let filterThumbnailSize: CGFloat = 70
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 0)
                
                Spacer()
                
                // Video Preview
                videoPreviewView
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Filters Section Only
                filtersView
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupVideo()
            setupFilters()
        }
        .onDisappear {
            videoPlayerManager.pause()
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                navigateToHome = true
            }
        } message: {
            Text("Video saved successfully!")
        }
        .background(
            NavigationLink(destination: HomeSegmentView(), isActive: $navigateToHome) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Edit Video")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                applySettingsAndSave()
            }) {
                Text("Apply")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    // MARK: - Video Preview View
    private var videoPreviewView: some View {
        ZStack {
            if let url = videoURL {
                VideoPlayer(player: videoPlayerManager.videoPlayer)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    .cornerRadius(12)
                    .onTapGesture {
                        togglePlayPause()
                    }
                    .overlay(
                        Group {
                            if !videoPlayerManager.isPlaying && !isLoading {
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
                            Text("Loading video...")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    )
            }
        }
    }
    
    // MARK: - Filters View
    private var filtersView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "camera.filters")
                    .foregroundColor(.blue)
                Text("Filters")
                    .font(.custom("Urbanist-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                if selectedFilterName != nil && selectedFilterName != "original" {
                    Button(action: {
                        applyFilter(availableFilters.first(where: { $0.name == "original" })!)
                    }) {
                        Text("Reset")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Filters ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(availableFilters) { filter in
                        FilterThumbnailCell(
                            filter: filter,
                            isSelected: selectedFilterName == filter.name,
                            size: filterThumbnailSize
                        ) {
                            applyFilter(filter)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
            .frame(height: 120)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FFFFFF").opacity(0.05), Color(hex: "#FFFFFF").opacity(0.10)]),
                startPoint: .leading,
                endPoint: .trailing
            )
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
                        self.videoPlayerManager.loadVideo(from: url)
                        self.videoPlayerManager.play()
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
        
        // Remove existing file if it exists
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
                switch exportSession.status {
                case .completed:
                    completion(tempURL)
                case .failed, .cancelled:
                    print("Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                default:
                    completion(nil)
                }
            }
        }
    }
    
    private func togglePlayPause() {
        if videoPlayerManager.isPlaying {
            videoPlayerManager.pause()
        } else {
            videoPlayerManager.play()
        }
    }
    
    private func setupFilters() {
        availableFilters = [
            VideoFilter(name: "original", displayName: "Original", filter: nil, iconName: "nosign"),
            VideoFilter(name: "CIPhotoEffectMono", displayName: "Mono", filter: CIFilter.photoEffectMono(), iconName: "camera.filters"),
            VideoFilter(name: "CIPhotoEffectNoir", displayName: "Noir", filter: CIFilter.photoEffectNoir(), iconName: "camera.filters"),
            VideoFilter(name: "CIPhotoEffectFade", displayName: "Fade", filter: CIFilter.photoEffectFade(), iconName: "camera.filters"),
            VideoFilter(name: "CISepiaTone", displayName: "Sepia", filter: CIFilter.sepiaTone(), iconName: "camera.filters"),
            VideoFilter(name: "CIColorMonochrome", displayName: "Monochrome", filter: CIFilter.colorMonochrome(), iconName: "camera.filters"),
            VideoFilter(name: "CIColorInvert", displayName: "Invert", filter: CIFilter.colorInvert(), iconName: "camera.filters"),
            VideoFilter(name: "CIComicEffect", displayName: "Comic", filter: CIFilter.comicEffect(), iconName: "camera.filters"),
            VideoFilter(name: "CIBloom", displayName: "Bloom", filter: CIFilter.bloom(), iconName: "camera.filters"),
            VideoFilter(name: "CIVignette", displayName: "Vignette", filter: CIFilter.vignette(), iconName: "camera.filters")
        ]
    }
    
    private func applyFilter(_ filter: VideoFilter) {
        selectedFilterName = filter.name
        
        if filter.name == "original" {
            removeVideoFilter()
        } else {
            applyFilterToVideo(filter.filter)
        }
    }
    
    private func applyFilterToVideo(_ filter: CIFilter?) {
        guard let filter = filter else { return }
        videoPlayerManager.setFilters(mainFilter: filter)
    }
    
    private func removeVideoFilter() {
        videoPlayerManager.removeFilter()
    }
    
    private func applySettingsAndSave() {
        // Save the video with applied filter
        guard let currentItem = videoPlayerManager.videoPlayer.currentItem,
              let asset = currentItem.asset as? AVURLAsset else {
            dismiss()
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(Int(timestamp))_filtered.mp4")
        
        // Remove existing file
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            dismiss()
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = currentItem.videoComposition
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    ImageSaveManager.shared.saveVideo(from: outputURL) { success in
                        if success {
                            try? FileManager.default.removeItem(at: outputURL)
                            showSuccessAlert = true
                        }
                    }
                } else {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Filter Thumbnail Cell
struct FilterThumbnailCell: View {
    let filter: VideoFilter
    let isSelected: Bool
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: size, height: size)
                    
                    if filter.name == "original" {
                        Image(systemName: filter.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: filter.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                
                Text(filter.displayName)
                    .font(.custom("Urbanist-Medium", size: 11))
                    .foregroundColor(isSelected ? .blue : .white)
                    .lineLimit(1)
            }
        }
    }
}
