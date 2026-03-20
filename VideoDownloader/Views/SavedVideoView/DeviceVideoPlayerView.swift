//
//  DeviceVideoPlayerView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 20/03/26.
//

import SwiftUI
import AVKit

struct DeviceVideoPlayerView: View {
    let video: DeviceVideo
    
    @Environment(\.dismiss) var dismiss
    @State private var player = AVPlayer()
    @State private var showControls = true
    @State private var isPlaying = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?
    
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        ZStack {
            // Beautiful gradient background #471428 to #111637
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#471428"),
                    Color(hex: "#111637")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header (Top Bar)
                if showControls {
                    HStack {
                        Button(action: {
                            player.pause()
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Color.white.opacity(0.15)
                                        .cornerRadius(30)
                                )
                        }
                        .padding(.leading, 10) // Left side 10 spaces from leading
                        .padding(.top, 15) // Top 15 spaces
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    // Add invisible spacer to maintain layout when controls are hidden
                    Color.clear
                        .frame(height: UIApplication.shared.safeAreaTop + 15)
                }
                
                Spacer(minLength: 0)
                
                // MARK: - Video Area
                GeometryReader { geo in
                    ZStack {
                        // Black background for video
                        Color.black
                            .frame(width: geo.size.width, height: geo.size.height)
                            .cornerRadius(20)
                        
                        VideoPlayer(player: player)
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: geo.size.width,
                                height: geo.size.height
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showControls.toggle()
                        }
                        // Auto hide controls after 3 seconds
                        if showControls {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showControls = false
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20) // Left and right padding 20
                .frame(height: UIScreen.main.bounds.height * 0.55) // Fixed height for video area
                
                Spacer(minLength: 0)
                
                // MARK: - Bottom Controls
                if showControls {
                    VStack(spacing: 12) {
                        // Progress Bar
                        VStack(spacing: 8) {
                            // Custom Slider with gradient
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background track
                                    Rectangle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(height: 4)
                                    
                                    // Progress track
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "#FF6B6B"),
                                                    Color(hex: "#FF8E53")
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * CGFloat(currentTime / duration), height: 4)
                                    
                                    // Slider thumb
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 12, height: 12)
                                        .offset(x: geometry.size.width * CGFloat(currentTime / duration) - 6)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newPosition = value.location.x
                                                    let newTime = Double(newPosition / geometry.size.width) * duration
                                                    currentTime = min(max(newTime, 0), duration)
                                                }
                                                .onEnded { _ in
                                                    seekToTime()
                                                }
                                        )
                                }
                            }
                            .frame(height: 20)
                            
                            HStack {
                                Text(formatTime(currentTime))
                                    .font(.custom("Urbanist-Medium", size: 12))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text(formatTime(duration))
                                    .font(.custom("Urbanist-Medium", size: 12))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 10) // Allocate space between video player and slider
                        
                        // Control Buttons
                        HStack(spacing: 40) {
                            // Rewind 10 seconds
                            Button(action: {
                                seekBackward()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "gobackward.10")
                                        .font(.system(size: 24))
                                    Text("10")
                                        .font(.custom("Urbanist-Medium", size: 10))
                                }
                                .foregroundColor(.white)
                            }
                            
                            // Play/Pause Button
                            Button(action: {
                                togglePlayPause()
                            }) {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 5)
                            }
                            
                            // Forward 10 seconds
                            Button(action: {
                                seekForward()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "goforward.10")
                                        .font(.system(size: 24))
                                    Text("10")
                                        .font(.custom("Urbanist-Medium", size: 10))
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Color.white.opacity(0.1)
                                .cornerRadius(30)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, UIApplication.shared.safeAreaBottom + 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Add invisible spacer when controls are hidden
                    Color.clear
                        .frame(height: 100)
                }
            }
        }
        .onAppear {
            setupPlayer()
            setupTimeObserver()
        }
        .onDisappear {
            player.pause()
            timer?.invalidate()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Setup Player
    private func setupPlayer() {
        player = AVPlayer(url: video.videoURL)
        player.play()
        isPlaying = true
        
        // Get video duration
        if let duration = player.currentItem?.asset.duration {
            let seconds = CMTimeGetSeconds(duration)
            if seconds.isFinite {
                self.duration = seconds
            }
        }
        
        // Auto loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
            isPlaying = true
        }
    }
    
    // MARK: - Time Observer
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = CMTimeGetSeconds(time)
        }
    }
    
    // MARK: - Controls Functions
    private func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    private func seekForward() {
        let newTime = min(currentTime + 10, duration)
        let seekTime = CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: seekTime)
    }
    
    private func seekBackward() {
        let newTime = max(currentTime - 10, 0)
        let seekTime = CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: seekTime)
    }
    
    private func seekToTime() {
        let seekTime = CMTime(seconds: currentTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: seekTime)
    }
    
    // MARK: - Format Time
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
