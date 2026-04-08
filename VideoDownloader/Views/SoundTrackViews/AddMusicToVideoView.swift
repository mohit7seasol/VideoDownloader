//
//  AddMusicToVideoView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 13/03/26.
//

import SwiftUI
import AVKit
import Photos
import AVFoundation

// MARK: - AddMusicToVideoView
struct AddMusicToVideoView: View {
    @Environment(\.dismiss) var dismiss
    let videoAsset: VideoAsset
    
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @State private var timeObserver: Any?
    @State private var assetGenerator: AVAssetImageGenerator?
    
    @State private var isPlaying = false
    @State private var isMuted = false
    @State private var showVolumeButton = true
    
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1
    
    @State private var selectedMusic: MusicTrack?
    @State private var showMusicLibrary = false
    @State private var showWaveform = false
    
    // Music range selection properties
    @State private var musicStartTime: Double = 0
    @State private var musicEndTime: Double = 30 // Default 30 seconds
    @State private var musicDuration: Double = 0
    @State private var isDraggingStartHandle = false
    @State private var isDraggingEndHandle = false
    
    @State private var exportURL: URL?
    @State private var navigateToWatch = false
    @State private var isExporting = false
    
    @State private var videoFrames: [UIImage] = []
    @State private var thumbnails: [UIImage] = []
    @State private var thumbnailSize: CGSize = .zero
    
    // Add this to track video audio status
    @State private var isVideoAudioAvailable = false
    
    @State private var navigateToPreview = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    // Fixed heights for other components to calculate video preview height
    private let navigationBarHeight: CGFloat = 100 // Top bar + padding
    private let timelineHeight: CGFloat = 40 // Slider height with padding
    private let playControlHeight: CGFloat = 50 // Play controls height
    private let videoFrameHeight: CGFloat = 100 // Video frame row height with padding
    private let musicRowHeight: CGFloat = 100 // Music row height with padding (increased for waveform)
    private let bottomPadding: CGFloat = 20 // Bottom safe area padding
    
    // Calculate video preview height based on screen size
    private var videoPreviewHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let totalFixedHeight = navigationBarHeight + timelineHeight +
                               playControlHeight + videoFrameHeight +
                               musicRowHeight + bottomPadding
        
        // Ensure minimum height of 200 and maximum of 400
        let calculatedHeight = screenHeight - totalFixedHeight - 50 // Extra padding
        return min(max(calculatedHeight, 200), 400)
    }
    
    var body: some View {
        if Device.isIpad {
            GeometryReader { geometry in
                ZStack {
                    // Background Image
                    Image("app_bg_image")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                    
                    VStack(spacing: 0) {
                        // Navigation Bar - Fixed at top
                        navigationBar
                            .padding(.bottom, 10)
                        
                        // Video Preview with fixed calculated height
                        videoPreview
                            .frame(height: videoPreviewHeight)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 10)
                        
                        // Timeline Slider
                        timelineSlider
                            .padding(.horizontal, 24)
                            .padding(.bottom, 10)
                        
                        // Play Controls
                        playControl
                            .padding(.horizontal, 24)
                            .padding(.bottom, 15)
                        
                        // Video Frame Row
                        videoFrameRow
                            .padding(.horizontal, 24)
                            .padding(.bottom, 15)
                        
                        // Music Row - Fixed at bottom with waveform
                        musicRow
                            .padding(.horizontal, 24)
                            .padding(.bottom, 10)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showMusicLibrary) {
                    MusicLibraryView(selectedMusic: $selectedMusic)
                }
                .navigationDestination(isPresented: $navigateToWatch) {
                    if let url = exportURL {
                        WatchVideoView(videoURL: url, musicTrack: selectedMusic,
                                      musicStartTime: musicStartTime,
                                      musicEndTime: musicEndTime)
                    }
                }
                .overlay {
                    if isExporting {
                        ZStack {
                            Color.black.opacity(0.7)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 20) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                
                                Text("Exporting video...".localized(self.language))
                                    .font(.custom("Urbanist-Medium", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .onAppear {
                    setupPlayer()
                    generateThumbnails()
                }
                .onDisappear {
                    cleanupPlayer()
                }
                .onChange(of: selectedMusic) { newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showWaveform = newValue != nil
                        
                        if let music = newValue {
                            let asset = AVAsset(url: music.url)
                            musicDuration = asset.duration.seconds
                            
                            // ✅ FIX: set range based on VIDEO duration
                            let videoDuration = duration
                            let defaultRange = min(videoDuration, musicDuration)
                            
                            musicStartTime = 0
                            musicEndTime = defaultRange
                        }
                    }
                }
                .onChange(of: isMuted) { newValue in
                    player?.isMuted = newValue
                }
            }
            .ignoresSafeArea()
        } else {
            ZStack {
                // Background Image
                Image("app_bg_image")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                
                VStack(spacing: 0) {
                    // Navigation Bar - Fixed at top
                    navigationBar
                        .padding(.bottom, 10)
                    
                    // Video Preview with fixed calculated height
                    videoPreview
                        .frame(height: videoPreviewHeight)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)
                    
                    // Timeline Slider
                    timelineSlider
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)
                    
                    // Play Controls
                    playControl
                        .padding(.horizontal, 24)
                        .padding(.bottom, 15)
                    
                    // Video Frame Row
                    videoFrameRow
                        .padding(.horizontal, 24)
                        .padding(.bottom, 15)
                    
                    // Music Row - Fixed at bottom with waveform
                    musicRow
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showMusicLibrary) {
                MusicLibraryView(selectedMusic: $selectedMusic)
            }
            .navigationDestination(isPresented: $navigateToWatch) {
                if let url = exportURL {
                    WatchVideoView(videoURL: url, musicTrack: selectedMusic,
                                  musicStartTime: musicStartTime,
                                  musicEndTime: musicEndTime)
                }
            }
            .overlay {
                if isExporting {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            
                            Text("Exporting video...".localized(self.language))
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onAppear {
                setupPlayer()
                generateThumbnails()
            }
            .onDisappear {
                cleanupPlayer()
            }
            .onChange(of: selectedMusic) { newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    showWaveform = newValue != nil
                    
                    if let music = newValue {
                        let asset = AVAsset(url: music.url)
                        musicDuration = asset.duration.seconds
                        
                        // ✅ FIX: set range based on VIDEO duration
                        let videoDuration = duration
                        let defaultRange = min(videoDuration, musicDuration)
                        
                        musicStartTime = 0
                        musicEndTime = defaultRange
                    }
                }
            }
            .onChange(of: isMuted) { newValue in
                player?.isMuted = newValue
            }
        }
    }
}

extension AddMusicToVideoView {
    var navigationBar: some View {
        HStack {
            Button {
                cleanupPlayer()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Soundtrack".localized(self.language))
                .font(.custom("Poppins-Black", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            Spacer()
            
            if selectedMusic != nil {
                Button {
                    // Stop video playback before exporting
                    player?.pause()
                    isPlaying = false
                    exportVideo()
                } label: {
                    Text("Done".localized(self.language))
                        .font(.custom("Urbanist-Bold", size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }
            } else {
                Color.clear
                    .frame(width: 60)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .frame(height: 100)
    }
}

extension AddMusicToVideoView {
    var videoPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            if let player = player {
                VideoPlayerController(player: player)
                    .cornerRadius(16)
                    .onAppear {
                        // Ensure video audio is enabled by default
                        player.isMuted = isMuted
                    }
            } else {
                ProgressView()
                    .tint(.white)
            }
            
            // Center Play Button (only when paused)
            if !isPlaying {
                Button {
                    togglePlay()
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
    }
}

extension AddMusicToVideoView {
    var playControl: some View {
        HStack {
            // Play/Pause Button
            Button {
                togglePlay()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Duration Label
            Text("\(formatTime(currentTime))/\(formatTime(duration))")
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            // Full Screen Button
            Button {
                // Pause video before going full screen
                player?.pause()
                isPlaying = false
                // Trigger full screen navigation
                navigateToPreview = true
            } label: {
                Image("")// "video_full_screen_ic"
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
            }
        }
    }
}

extension AddMusicToVideoView {
    var timelineSlider: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Progress Track
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(currentTime / max(duration, 1)), height: 4)
                    .cornerRadius(2)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .offset(x: geometry.size.width * CGFloat(currentTime / max(duration, 1)) - 8)
                    .shadow(radius: 2)
            }
            .frame(height: 20)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let percentage = max(0, min(1, value.location.x / geometry.size.width))
                        currentTime = percentage * duration
                        player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600))
                    }
            )
        }
        .frame(height: 30)
    }
}

extension AddMusicToVideoView {
    var videoFrameRow: some View {
        HStack(spacing: 12) {
            // Volume Button
            Button {
                isMuted.toggle()
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
            }
            .frame(width: 30)
            
            // Video Frame Thumbnails Row
            if !thumbnails.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<thumbnails.count, id: \.self) { index in
                            Image(uiImage: thumbnails[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55 * 16/9, height: 55)
                                .clipped()
                                .cornerRadius(0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
            } else {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 60)
    }
}

extension AddMusicToVideoView {
    var musicRow: some View {
        HStack(spacing: 12) {
            // Music Button
            Button {
                showMusicLibrary = true
            } label: {
                Image("music_ic")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
            }
            .frame(width: 30)
            
            // Music Content with Waveform
            if showWaveform, let music = selectedMusic {
                VStack(alignment: .leading, spacing: 8) {
                    // Music name and duration info
                    HStack {
                        Text(music.name)
                            .font(.custom("Urbanist-Medium", size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(formatTime(musicStartTime)) - \(formatTime(musicEndTime))")
                            .font(.custom("Urbanist-Medium", size: 12))
                            .foregroundColor(Color(hex: "1973E8"))
                    }
                    
                    // Waveform with Range Slider - Takes full width
                    MusicWaveView(
                        audioURL: music.url,
                        startTime: $musicStartTime,
                        endTime: $musicEndTime,
                        duration: musicDuration,
                        isDraggingStart: $isDraggingStartHandle,
                        isDraggingEnd: $isDraggingEndHandle
                    )
                    .frame(height: 50)
                    .frame(maxWidth: .infinity) // ✅ Ensure full width
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity) // ✅ Make VStack take full width
                .onTapGesture {
                    showMusicLibrary = true
                }
            } else {
                // Placeholder when no music selected
                HStack {
                    Spacer()
                    Text("Tap to add music".localized(self.language))
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity) // ✅ Ensure full width
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .onTapGesture {
                    showMusicLibrary = true
                }
            }
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity) // ✅ Make HStack take full width
    }
}

// MARK: - MusicWaveView (Third Party Waveform with Range Slider)
struct MusicWaveView: View {
    let audioURL: URL
    @Binding var startTime: Double
    @Binding var endTime: Double
    let duration: Double
    @Binding var isDraggingStart: Bool
    @Binding var isDraggingEnd: Bool
    
    @State private var samples: [Float] = []
    
    private let minRangeDuration: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let safeDuration = max(duration, 0.1)
            
            let startX = width * CGFloat(startTime / safeDuration)
            let endX   = width * CGFloat(endTime / safeDuration)
            
            // ✅ Dynamic minimum range (IMPORTANT FIX)
            let minAllowedRange = max(minRangeDuration, safeDuration * 0.2)
            
            ZStack(alignment: .leading) {
                
                // Waveform
                waveformView
                    .foregroundColor(Color.white.opacity(0.4))
                    .frame(maxWidth: .infinity) // ✅ Added: Make waveform take full width
                
                // MARK: START HANDLE
                RangeHandle(
                    position: startX,
                    isLeft: true,
                    isDragging: $isDraggingStart,
                    totalHeight: 80
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDraggingStart = true
                            
                            let newX = min(
                                endX - (CGFloat(minAllowedRange / safeDuration) * width),
                                max(0, value.location.x)
                            )
                            
                            var newStart = Double(newX / width) * safeDuration
                            
                            // ✅ Enforce minimum range
                            if (endTime - newStart) < minAllowedRange {
                                newStart = endTime - minAllowedRange
                                newStart = max(0, newStart)
                            }
                            
                            startTime = newStart
                        }
                        .onEnded { _ in
                            isDraggingStart = false
                        }
                )
                
                // MARK: END HANDLE
                RangeHandle(
                    position: endX,
                    isLeft: false,
                    isDragging: $isDraggingEnd,
                    totalHeight: 80
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDraggingEnd = true
                            
                            let newX = max(
                                startX + (CGFloat(minAllowedRange / safeDuration) * width),
                                min(width, value.location.x)
                            )
                            
                            var newEnd = Double(newX / width) * safeDuration
                            
                            // ✅ Enforce minimum range
                            if (newEnd - startTime) < minAllowedRange {
                                newEnd = startTime + minAllowedRange
                                newEnd = min(safeDuration, newEnd)
                            }
                            
                            endTime = newEnd
                        }
                        .onEnded { _ in
                            isDraggingEnd = false
                        }
                )
                
                // MARK: TIME LABELS
                VStack {
                    Spacer()
                    HStack {
                        Text(formatTime(startTime))
                            .font(.custom("Urbanist-Medium", size: 10))
                            .foregroundColor(.white)
                            .offset(x: max(0, min(startX - 20, width - 40)))
                        
                        Spacer()
                        
                        Text(formatTime(endTime))
                            .font(.custom("Urbanist-Medium", size: 10))
                            .foregroundColor(.white)
                            .offset(x: max(0, min(endX - 20, width - 40)))
                    }
                }
            }
            .onAppear {
                generateWaveformSamples()
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity) // ✅ Added: Make MusicWaveView take full width
    }
    
    private var waveformView: some View {
        GeometryReader { geometry in
            let itemWidth = max(2, (geometry.size.width - CGFloat(samples.count) * 2) / CGFloat(min(samples.count, 100)))
            let spacing = max(1, itemWidth * 0.3)
            
            HStack(spacing: spacing) {
                ForEach(0..<min(samples.count, 100), id: \.self) { index in
                    let sample = samples[index]
                    let height = CGFloat(max(4, min(40, abs(sample) * 40)))
                    
                    Capsule()
                        .frame(width: itemWidth, height: height)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func generateWaveformSamples() {
        // Generate more realistic waveform samples based on audio file
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: audioURL)
            let duration = asset.duration.seconds
            
            if duration > 0 {
                // Try to extract actual waveform samples
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                
                // For now, generate semi-random samples that simulate audio
                var generatedSamples: [Float] = []
                for i in 0..<100 {
                    let progress = Float(i) / 100.0
                    // Create a waveform pattern that varies throughout the song
                    let baseValue = sin(progress * .pi * 4) * 0.5 + 0.5
                    let randomVariation = Float.random(in: 0.3...0.7)
                    let sampleValue = min(1.0, max(0.3, baseValue * randomVariation))
                    generatedSamples.append(sampleValue)
                }
                
                DispatchQueue.main.async {
                    self.samples = generatedSamples
                }
            } else {
                // Fallback to random samples
                let randomSamples = (0..<100).map { _ in
                    Float.random(in: 0.3...1.0)
                }
                DispatchQueue.main.async {
                    self.samples = randomSamples
                }
            }
        }
    }
}

// MARK: - RangeHandle
struct RangeHandle: View {
    let position: CGFloat
    let isLeft: Bool
    @Binding var isDragging: Bool
    let totalHeight: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 3)
                .frame(height: totalHeight - 30)
            
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "1973E8"), lineWidth: 2)
                )
                .overlay(
                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "1973E8"))
                )
                .offset(y: isLeft ? -15 : 15)
        }
        .offset(x: position - 1.5, y: -5)
        .scaleEffect(isDragging ? 1.2 : 1.0)
        .animation(.spring(), value: isDragging)
    }
}

// MARK: - VideoPlayerController
struct VideoPlayerController: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.cornerRadius = 16
        playerLayer.masksToBounds = true
        playerLayer.frame = controller.view.bounds
        
        controller.view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiViewController.view.bounds
            context.coordinator.playerLayer?.player = player
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

// MARK: - Helper Functions
extension AddMusicToVideoView {
    func setupPlayer() {
        PHImageManager.default().requestAVAsset(forVideo: videoAsset.asset, options: nil) { avAsset, _, _ in
            guard let asset = avAsset else { return }
            
            DispatchQueue.main.async {
                let item = AVPlayerItem(asset: asset)
                playerItem = item
                player = AVPlayer(playerItem: item)
                
                // Ensure audio is enabled
                player?.isMuted = isMuted
                
                // Check if video has audio track
                isVideoAudioAvailable = !asset.tracks(withMediaType: .audio).isEmpty
                
                duration = asset.duration.seconds
                
                // Add observer for when video ends
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: item,
                    queue: .main
                ) { _ in
                    isPlaying = false
                    currentTime = 0
                    player?.seek(to: .zero)
                }
                
                timeObserver = player?.addPeriodicTimeObserver(
                    forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
                    queue: .main
                ) { time in
                    currentTime = time.seconds
                    isPlaying = player?.rate != 0
                }
            }
        }
    }
    
    func cleanupPlayer() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player = nil
    }
    
    func togglePlay() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
    }
    
    func generateThumbnails() {
        PHImageManager.default().requestAVAsset(forVideo: videoAsset.asset, options: nil) { avAsset, _, _ in
            guard let asset = avAsset else { return }
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 55 * 16/9 * 2, height: 55 * 2)
            
            let duration = asset.duration.seconds
            let interval = duration / 10
            
            var times: [NSValue] = []
            for i in 0..<10 {
                let time = CMTime(seconds: Double(i) * interval, preferredTimescale: 600)
                times.append(NSValue(time: time))
            }
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for time in times {
                group.enter()
                generator.generateCGImagesAsynchronously(forTimes: [time]) { _, image, _, _, _ in
                    if let cgImage = image {
                        let uiImage = UIImage(cgImage: cgImage)
                        images.append(uiImage)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.thumbnails = images
            }
        }
    }
    
    func exportVideo() {
        guard let music = selectedMusic else { return }
        isExporting = true
        
        PHImageManager.default().requestAVAsset(forVideo: videoAsset.asset, options: nil) { avAsset, _, _ in
            guard let videoAsset = avAsset else {
                DispatchQueue.main.async {
                    isExporting = false
                }
                return
            }
            
            let composition = AVMutableComposition()
            
            // Get video duration
            let videoDuration = videoAsset.duration
            
            // Add video track (video only, no audio)
            guard let videoTrack = videoAsset.tracks(withMediaType: .video).first,
                  let compositionVideoTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid) else {
                DispatchQueue.main.async {
                    isExporting = false
                }
                return
            }
            
            // Insert video for its full duration
            do {
                try compositionVideoTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: videoDuration),
                    of: videoTrack,
                    at: .zero)
            } catch {
                print("Error inserting video track: \(error)")
                DispatchQueue.main.async {
                    isExporting = false
                }
                return
            }
            
            // Add ONLY the selected music track (no original video audio)
            let musicAsset = AVAsset(url: music.url)
            if let audioTrack = musicAsset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                
                let musicStartCMTime = CMTime(seconds: musicStartTime, preferredTimescale: 600)
                let musicEndCMTime = CMTime(seconds: musicEndTime, preferredTimescale: 600)
                
                // Calculate music duration to use
                let selectedMusicDuration = CMTimeSubtract(musicEndCMTime, musicStartCMTime)
                
                // Use the minimum of video duration and selected music duration
                let durationToUse = CMTimeMinimum(videoDuration, selectedMusicDuration)
                
                let musicTimeRange = CMTimeRange(start: musicStartCMTime, duration: durationToUse)
                
                do {
                    try compositionAudioTrack.insertTimeRange(
                        musicTimeRange,
                        of: audioTrack,
                        at: .zero)
                } catch {
                    print("Error inserting music track: \(error)")
                }
            }
            
            // IMPORTANT: Do NOT add the original video audio track
            // The code below that added video audio has been completely removed
            
            // Export
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".mov")
            
            // Remove any existing file at that URL
            try? FileManager.default.removeItem(at: outputURL)
            
            guard let exporter = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality) else {
                DispatchQueue.main.async {
                    isExporting = false
                }
                return
            }
            
            exporter.outputURL = outputURL
            exporter.outputFileType = .mov
            
            exporter.exportAsynchronously {
                DispatchQueue.main.async {
                    isExporting = false
                    switch exporter.status {
                    case .completed:
                        exportURL = outputURL
                        navigateToWatch = true
                    case .failed:
                        print("Export failed: \(exporter.error?.localizedDescription ?? "Unknown error")")
                    case .cancelled:
                        print("Export cancelled")
                    default:
                        break
                    }
                }
            }
        }
    }
}

func formatTime(_ time: Double) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}
