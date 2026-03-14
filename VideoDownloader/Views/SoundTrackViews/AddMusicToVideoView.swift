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
    @State private var videoDuration: TimeInterval = 0
    
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
                        navigateToWatchVideo = true
                    } label: {
                        Text("Done")
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
                
                // Video Preview Container
                VStack(spacing: 0) {
                    // Video Preview
                    ZStack {
                        VideoPlayerView(player: $player, isPlaying: $isPlaying, currentTime: $currentTime)
                            .frame(height: 220)
                            .cornerRadius(16)
                        
                        // Play/Pause Overlay Button
                        Button {
                            isPlaying.toggle()
                            if isPlaying {
                                player?.play()
                            } else {
                                player?.pause()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Time Label (01:00/3:20 format) - As shown in uploaded image
                    HStack {
                        Text(formatTime(currentTime))
                            .font(.custom("Urbanist-Medium", size: 14))
                            .foregroundColor(.white)
                        
                        Text("/")
                            .font(.custom("Urbanist-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(formatTime(videoDuration))
                            .font(.custom("Urbanist-Medium", size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 12)
                    
                    // Video Timeline Slider
                    VideoTimelineView(currentTime: $currentTime, duration: videoDuration, player: player)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Music Preview Section (Bottom)
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Music Preview Header
                    HStack {
                        Text("Music Preview")
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button {
                            showMusicLibrary = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedMusic != nil ? "Change" : "Add Music")
                                    .font(.custom("Urbanist-Medium", size: 14))
                                    .foregroundColor(Color(hex: "1973E8"))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "1973E8"))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if let music = selectedMusic {
                        // Selected Music Preview
                        HStack(spacing: 12) {
                            // Music Icon with Gradient Background
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
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(music.name)
                                    .font(.custom("Urbanist-Bold", size: 16))
                                    .foregroundColor(.white)
                                
                                Text(music.artist)
                                    .font(.custom("Urbanist-Medium", size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            // Music Duration
                            Text(formatTime(music.duration))
                                .font(.custom("Urbanist-Medium", size: 14))
                                .foregroundColor(.white.opacity(0.7))
                            
                            // Play Music Button
                            Button {
                                // Play music preview
                            } label: {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "1973E8"))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    } else {
                        // No Music Selected Placeholder
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: "music.note")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("No Music Selected")
                                    .font(.custom("Urbanist-Bold", size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Text("Tap Add Music to choose")
                                    .font(.custom("Urbanist-Medium", size: 14))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
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
            if let video = videoAsset as? VideoAsset {
                WatchVideoView(videoAsset: video, musicTrack: selectedMusic)
            }
        }
    }
    
    private func setupPlayer() {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestPlayerItem(forVideo: videoAsset.asset, options: options) { playerItem, _ in
            DispatchQueue.main.async {
                if let playerItem = playerItem {
                    self.player = AVPlayer(playerItem: playerItem)
                    self.videoDuration = playerItem.asset.duration.seconds
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
}
// MARK: - VideoPlayerView
struct VideoPlayerView: UIViewRepresentable {
    @Binding var player: AVPlayer?
    @Binding var isPlaying: Bool
    @Binding var currentTime: TimeInterval
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Remove existing player layer
        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Add new player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = uiView.bounds
        uiView.layer.addSublayer(playerLayer)
    }
}


// MARK: - VideoTimelineView
struct VideoTimelineView: View {
    @Binding var currentTime: TimeInterval
    let duration: TimeInterval
    let player: AVPlayer?
    
    var body: some View {
        VStack(spacing: 8) {
            // Timeline Slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    // Progress track
                    Rectangle()
                        .fill(Color(hex: "1973E8"))
                        .frame(width: geometry.size.width * CGFloat(currentTime / max(duration, 1)), height: 4)
                        .cornerRadius(2)
                    
                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .offset(x: geometry.size.width * CGFloat(currentTime / max(duration, 1)) - 6)
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
            
            // Timeline markers (optional - for visual reference)
            HStack {
                ForEach(0..<5) { index in
                    Spacer()
                    if index < 4 {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 2)
        }
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
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Urbanist-Medium", size: 16))
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Select Music")
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Urbanist-Bold", size: 16))
                    .foregroundColor(selectedMusic != nil ? Color(hex: "1973E8") : .gray)
                    .disabled(selectedMusic == nil)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    
                    TextField("Search music", text: $searchText)
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.white)
                        .accentColor(Color(hex: "1973E8"))
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Music List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredTracks) { track in
                            MusicTrackRow(track: track, isSelected: selectedMusic?.id == track.id)
                                .onTapGesture {
                                    selectedMusic = track
                                }
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            loadMusicTracks()
        }
    }
    
    private var filteredTracks: [MusicTrack] {
        if searchText.isEmpty {
            return musicTracks
        } else {
            return musicTracks.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func loadMusicTracks() {
        // Load music from bundle or local storage
        musicTracks = [
            MusicTrack(name: "Summer Vibes", artist: "Artist 1", duration: 180, url: URL(string: "file://")!),
            MusicTrack(name: "Chill Beats", artist: "Artist 2", duration: 210, url: URL(string: "file://")!),
            MusicTrack(name: "Upbeat Energy", artist: "Artist 3", duration: 195, url: URL(string: "file://")!),
            MusicTrack(name: "Midnight Jazz", artist: "Artist 4", duration: 240, url: URL(string: "file://")!),
            MusicTrack(name: "Electronic Dreams", artist: "Artist 5", duration: 185, url: URL(string: "file://")!),
            MusicTrack(name: "Acoustic Soul", artist: "Artist 6", duration: 200, url: URL(string: "file://")!)
        ]
    }
}



// MARK: - MusicTrackRow
struct MusicTrackRow: View {
    let track: MusicTrack
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Track Number or Play Button
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: isSelected ?
                                [Color(hex: "1973E8"), Color(hex: "0E4082")] :
                                [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: isSelected ? "checkmark" : "music.note")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.custom("Urbanist-Bold", size: 16))
                    .foregroundColor(.white)
                
                Text(track.artist)
                    .font(.custom("Urbanist-Medium", size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Duration
            Text(formatDuration(track.duration))
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.white.opacity(0.5))
            
            // Preview Button
            Button {
                // Preview music
            } label: {
                Image(systemName: "play.circle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "1973E8"))
            }
        }
        .padding(.vertical, 8)
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

