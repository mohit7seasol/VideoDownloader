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
    
    @State private var exportURL: URL?
    @State private var navigateToWatch = false
    @State private var isExporting = false
    
    @State private var videoFrames: [UIImage] = []
    @State private var thumbnails: [UIImage] = []
    @State private var thumbnailSize: CGSize = .zero
    
    // Calculate available height for video preview
    private var videoPreviewHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let navigationBarHeight: CGFloat = 100 // Top bar + padding
        let playControlHeight: CGFloat = 50
        let timelineHeight: CGFloat = 30
        let videoFrameHeight: CGFloat = 70
        let musicRowHeight: CGFloat = 60
        let bottomSpacing: CGFloat = 40
        let totalFixedHeight = navigationBarHeight + playControlHeight + timelineHeight +
                               videoFrameHeight + musicRowHeight + bottomSpacing
        
        return screenHeight - totalFixedHeight - 100 // Extra padding
    }
    
    var body: some View {
        ZStack {
            // Background Image
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack(spacing: 0) {
                navigationBar
                    .padding(.bottom, 15)
                
                // Video Preview with dynamic height
                videoPreview
                    .frame(height: videoPreviewHeight)
                    .padding(.horizontal, 24)
                
                // Timeline Slider
                timelineSlider
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                
                // Play Controls
                playControl
                    .padding(.horizontal, 24)
                    .padding(.top, 15)
                
                // Video Frame Row
                videoFrameRow
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Music Row
                musicRow
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                
                Spacer(minLength: 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showMusicLibrary) {
            MusicLibraryView(selectedMusic: $selectedMusic)
        }
        .navigationDestination(isPresented: $navigateToWatch) {
            if let url = exportURL {
                WatchVideoView(videoURL: url, musicTrack: selectedMusic)
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
                        
                        Text("Exporting video...")
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
            
            Text("Soundtrack")
                .font(.custom("Poppins-Black", size: 20))
                .foregroundColor(.white)
            
            Spacer()
            
            if selectedMusic != nil {
                Button {
                    exportVideo()
                } label: {
                    Text("Done")
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
    }
}

extension AddMusicToVideoView {
    var videoPreview: some View {
        ZStack {
            // Fixed height container
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if let player = player {
                            VideoPlayerController(player: player)
                                .frame(height: 300)
                                .cornerRadius(16)
                        } else {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                )
            // Removed the center play/pause button
        }
        .frame(height: 300)
        .padding(.horizontal, 24)
    }
}

extension AddMusicToVideoView {
    var playControl: some View {
        HStack {
            // Play/Pause Button (22x22)
            Button {
                togglePlay()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Duration Label (00:05/00:05 format as in your screenshot)
            Text("\(formatTime(currentTime))/\(formatTime(duration))")
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            // Full Screen Button (18x18)
            Button {
                // Full screen action
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}

extension AddMusicToVideoView {
    var timelineSlider: some View {
        // Custom Timeline Slider
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
        .frame(height: 20)
    }
}

extension AddMusicToVideoView {
    var videoFrameRow: some View {
        HStack(spacing: 12) {
            // Volume Button (22x22)
            Button {
                isMuted.toggle()
                player?.isMuted = isMuted
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
            }
            
            // Video Frame Thumbnails Row (Height 55)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(0..<thumbnails.count, id: \.self) { index in
                        if index < thumbnails.count {
                            Image(uiImage: thumbnails[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55 * 16/9, height: 55)
                                .clipped()
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
    }
}

extension AddMusicToVideoView {
    var musicRow: some View {
        HStack(spacing: 12) {
            // Music Button (22x22)
            Button {
                showMusicLibrary = true
            } label: {
                Image("music_ic")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
            }
            
            // Music Wave View (shows only when music selected)
            if showWaveform, let music = selectedMusic {
                HStack {
                    WaveformView(audioURL: music.url)
                        .frame(height: 36)
                    
                    Text(music.name)
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .onTapGesture {
                    showMusicLibrary = true
                }
            } else {
                // Placeholder when no music selected - Make it tappable
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 36)
                        .overlay(
                            Text("Tap to add music")
                                .font(.custom("Urbanist-Medium", size: 14))
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
                .onTapGesture {
                    showMusicLibrary = true
                }
            }
        }
    }
}

// MARK: - VideoPlayerController
struct VideoPlayerController: UIViewControllerRepresentable {
    let player: AVPlayer
    var height: CGFloat = 300
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: height)
        playerLayer.cornerRadius = 16
        playerLayer.masksToBounds = true
        
        controller.view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.playerLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width - 48,
            height: height
        )
        context.coordinator.playerLayer?.player = player
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

// MARK: - WaveformView
struct WaveformView: View {
    let audioURL: URL
    @State private var samples: [Float] = []
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<min(samples.count, Int(geometry.size.width / 4)), id: \.self) { index in
                    let sample = samples[index]
                    let height = CGFloat(max(4, min(36, abs(sample) * 36)))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 3, height: height)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            generateWaveformSamples()
        }
    }
    
    private func generateWaveformSamples() {
        // Generate sample waveform data
        // In production, you'd extract actual audio samples
        samples = (0..<100).map { _ in
            Float.random(in: 0.3...1.0)
        }
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
                
                player?.play()
                isPlaying = true
                
                timeObserver = player?.addPeriodicTimeObserver(
                    forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
                    queue: .main
                ) { time in
                    currentTime = time.seconds
                    // Update isPlaying based on player state
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
        // Don't toggle isPlaying here - let the observer handle it
    }
    
    func generateThumbnails() {
        PHImageManager.default().requestAVAsset(forVideo: videoAsset.asset, options: nil) { avAsset, _, _ in
            guard let asset = avAsset else { return }
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 55 * 16/9 * 2, height: 55 * 2)
            
            let duration = asset.duration.seconds
            let interval = duration / 10 // Generate 10 thumbnails
            
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
            guard let videoAsset = avAsset else { return }
            
            let composition = AVMutableComposition()
            
            // Add video track
            guard let videoTrack = videoAsset.tracks(withMediaType: .video).first,
                  let compositionVideoTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
            
            try? compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: videoTrack,
                at: .zero)
            
            // Add audio track from music
            let musicAsset = AVAsset(url: music.url)
            if let audioTrack = musicAsset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                
                try? compositionAudioTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: videoAsset.duration),
                    of: audioTrack,
                    at: .zero)
            }
            
            // Export
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".mov")
            
            guard let exporter = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality) else { return }
            
            exporter.outputURL = outputURL
            exporter.outputFileType = .mov
            
            exporter.exportAsynchronously {
                DispatchQueue.main.async {
                    isExporting = false
                    if exporter.status == .completed {
                        exportURL = outputURL
                        navigateToWatch = true
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
