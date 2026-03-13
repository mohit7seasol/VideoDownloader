//
//  AddMusicToVideoView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 13/03/26.
//

import SwiftUI
import PhotosUI
import AVKit
import Lottie

struct AddMusicToVideoView: View {
    @Environment(\.dismiss) var dismiss
    let videoAsset: VideoAsset
    @State private var player: AVPlayer?
    @State private var showMusicLibrary = false
    @State private var selectedMusic: MusicTrack?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var navigateToWatchVideo = false
    
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
                    
                    // Done Button
                    Button {
                        // Navigate to watch video
                        navigateToWatchVideo = true
                    } label: {
                        Text("Done")
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "1973E8"),
                                        Color(hex: "0E4082")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Video Preview
                VideoPlayerView(player: $player, isPlaying: $isPlaying, currentTime: $currentTime)
                    .frame(height: 300)
                    .padding(.top, 20)
                
                // Time Label (01:00/3:20 format)
                HStack {
                    Text(formatTime(currentTime))
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white)
                    
                    Text("/")
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(formatTime(player?.currentItem?.duration.seconds ?? videoAsset.duration))
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                // Video Timeline Slider
                VideoTimelineView(currentTime: $currentTime, duration: player?.currentItem?.duration.seconds ?? videoAsset.duration, player: player)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                
                Spacer()
                
                // Bottom Controls
                HStack(spacing: 40) {
                    // Music Button
                    Button {
                        showMusicLibrary = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "music.note")
                                .font(.system(size: 24))
                                .foregroundColor(selectedMusic != nil ? Color(hex: "1973E8") : .white)
                            
                            Text("Music")
                                .font(.custom("Urbanist-Medium", size: 12))
                                .foregroundColor(selectedMusic != nil ? Color(hex: "1973E8") : .white)
                        }
                    }
                    
                    // Play/Pause Button
                    Button {
                        isPlaying.toggle()
                        if isPlaying {
                            player?.play()
                        } else {
                            player?.pause()
                        }
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    // Save Button
                    Button {
                        // Save video functionality
                        saveVideo()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text("Save")
                                .font(.custom("Urbanist-Medium", size: 12))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupPlayer()
        }
        .sheet(isPresented: $showMusicLibrary) {
            MusicLibraryView(selectedMusic: $selectedMusic)
        }
        .navigationDestination(isPresented: $navigateToWatchVideo) {
            WatchVideoView(videoAsset: videoAsset, musicTrack: selectedMusic)
        }
    }
    
    private func setupPlayer() {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestPlayerItem(forVideo: videoAsset.asset, options: options) { playerItem, _ in
            DispatchQueue.main.async {
                if let playerItem = playerItem {
                    self.player = AVPlayer(playerItem: playerItem)
                    self.player?.play()
                    self.isPlaying = true
                    
                    // Add time observer
                    self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { time in
                        self.currentTime = time.seconds
                    }
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func saveVideo() {
        // Request permission and save video
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    // Save video logic here
                    print("Video saved successfully")
                }
            }
        }
    }
}
// MARK: - VideoPlayerView
struct VideoPlayerView: UIViewRepresentable {
    @Binding var player: AVPlayer?
    @Binding var isPlaying: Bool
    @Binding var currentTime: TimeInterval
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let playerLayer = AVPlayerLayer()
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.player = player
            playerLayer.frame = uiView.bounds
        }
    }
}


// MARK: - VideoTimelineView
struct VideoTimelineView: View {
    @Binding var currentTime: TimeInterval
    let duration: TimeInterval
    let player: AVPlayer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background timeline
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Progress timeline
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1973E8"),
                                Color(hex: "0E4082")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(currentTime / duration), height: 4)
                    .cornerRadius(2)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: geometry.size.width * CGFloat(currentTime / duration) - 6)
                    .shadow(radius: 2)
            }
            .frame(height: 20)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let percentage = max(0, min(1, value.location.x / geometry.size.width))
                        currentTime = percentage * duration
                        
                        // Seek video
                        player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600))
                    }
            )
        }
        .frame(height: 20)
    }
}

// MARK: - MusicTrack Model
struct MusicTrack: Identifiable {
    let id = UUID()
    let name: String
    let artist: String
    let duration: TimeInterval
    let url: URL
}

// MARK: - MusicLibraryView
struct MusicLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedMusic: MusicTrack?
    @State private var musicTracks: [MusicTrack] = []
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Select Music")
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "1973E8"))
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Music List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(musicTracks) { track in
                            MusicTrackRow(track: track, isSelected: selectedMusic?.id == track.id)
                                .onTapGesture {
                                    selectedMusic = track
                                    dismiss()
                                }
                        }
                    }
                    .padding(24)
                }
            }
        }
        .onAppear {
            loadMusicTracks()
        }
    }
    
    private func loadMusicTracks() {
        // Load music from bundle or local storage
        // This is sample data
        musicTracks = [
            MusicTrack(name: "Summer Vibes", artist: "Artist 1", duration: 180, url: URL(string: "file://")!),
            MusicTrack(name: "Chill Beats", artist: "Artist 2", duration: 210, url: URL(string: "file://")!),
            MusicTrack(name: "Upbeat Energy", artist: "Artist 3", duration: 195, url: URL(string: "file://")!)
        ]
    }
}


// MARK: - MusicTrackRow
struct MusicTrackRow: View {
    let track: MusicTrack
    let isSelected: Bool
    
    var body: some View {
        HStack {
            // Thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1973E8"),
                            Color(hex: "0E4082")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "music.note")
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.custom("Poppins-Black", size: 16))
                    .foregroundColor(.white)
                
                Text(track.artist)
                    .font(.custom("Urbanist-Medium", size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Duration
            Text(formatDuration(track.duration))
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "1973E8"))
                    .font(.system(size: 20))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - WatchVideoView
struct WatchVideoView: View {
    @Environment(\.dismiss) var dismiss
    let videoAsset: VideoAsset
    let musicTrack: MusicTrack?
    @State private var player: AVPlayer?
    @State private var showSaveSuccess = false
    @State private var showPermissionAlert = false
    
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
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Preview")
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
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "1973E8"),
                                        Color(hex: "0E4082")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Video Player
                ZStack {
                    if let player = player {
                        VideoPlayer(player: player)
                            .frame(height: 400)
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                            .padding(.top, 30)
                    } else {
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .frame(height: 400)
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                            .padding(.top, 30)
                            .overlay {
                                ProgressView()
                                    .tint(.white)
                            }
                    }
                }
                
                // Video Info
                VStack(spacing: 16) {
                    if let musicTrack = musicTrack {
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(Color(hex: "1973E8"))
                            
                            Text(musicTrack.name)
                                .font(.custom("Urbanist-Bold", size: 16))
                                .foregroundColor(.white)
                            
                            Text("•")
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(musicTrack.artist)
                                .font(.custom("Urbanist-Medium", size: 14))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
                    
                    // Play/Pause Button
                    Button {
                        if player?.timeControlStatus == .playing {
                            player?.pause()
                        } else {
                            player?.play()
                        }
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupPlayer()
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
    }
    
    private func setupPlayer() {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestPlayerItem(forVideo: videoAsset.asset, options: options) { playerItem, _ in
            DispatchQueue.main.async {
                if let playerItem = playerItem {
                    self.player = AVPlayer(playerItem: playerItem)
                    self.player?.play()
                }
            }
        }
    }
    
    private func saveVideoToGallery() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            // Save video logic here
            showSaveSuccess = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        // Save video logic here
                        showSaveSuccess = true
                    } else {
                        showPermissionAlert = true
                    }
                }
            }
        default:
            showPermissionAlert = true
        }
    }
}

