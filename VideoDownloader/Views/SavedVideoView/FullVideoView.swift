//
//  FullVideoView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI
import AVKit
import Photos

struct FullVideoView: View {
    let video: SavedVideo
    let onDelete: (() -> Void)?
    @Environment(\.dismiss) var dismiss
    @State private var player = AVPlayer()
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false
    @State private var showDownloadAlert = false
    @State private var downloadMessage = ""
    @State private var isDownloading = false
    @State private var isPlayerReady = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    init(video: SavedVideo, onDelete: (() -> Void)? = nil) {
        self.video = video
        self.onDelete = onDelete
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Custom Navigation Bar
            HStack {
                Button {
                    player.pause()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .padding(.leading, 16)
                }
                
                Spacer()
                
                // Video Info
                VStack(spacing: 4) {
                    if let musicName = video.musicName {
                        Text(musicName)
                            .font(.custom("Urbanist-Bold", size: 18))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    
                    if let artist = video.musicArtist {
                        Text(artist)
                            .font(.custom("Urbanist-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Download Button
                Button(action: {
                    downloadVideoToGallery()
                }) {
                    if isDownloading {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 16)
                    } else {
                        Image(systemName: "arrow.down.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                            .padding(.trailing, 16)
                    }
                }
                .disabled(isDownloading)
            }
            .padding(.top, UIApplication.shared.safeAreaTop)
            .padding(.bottom, 10)
            .background(Color.clear)
            .zIndex(1)
            
            // Content starts from top (below custom nav bar)
            VStack(spacing: 0) {
                // Spacer for custom nav bar height
                Color.clear
                    .frame(height: UIApplication.shared.safeAreaTop + 44)
                
                // Video Player Container
                ZStack {
                    // Custom Video Player
                    CustomVideoPlayer(player: player, isReady: $isPlayerReady)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.45)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    
                    // Loading Overlay
                    if !isPlayerReady {
                        VStack {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                            
                            Text("Preparing video...".localized(self.language))
                                .font(.custom("Urbanist-Medium", size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.45)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
                
                // Bottom Buttons
                HStack(spacing: 20) {
                    // Share Button
                    Button(action: {
                        showShareSheet = true
                    }) {
                        HStack(spacing: 12) {
                            Image("share_ic")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            
                            Text("Share".localized(self.language))
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#1973E8"), Color(hex: "#0E4082")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color(hex: "#1973E8").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // Delete Button
                    Button(action: {
                        player.pause()
                        showDeleteAlert = true
                    }) {
                        HStack(spacing: 12) {
                            Image("delete_ic")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            
                            Text("Delete".localized(self.language))
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#1973E8"), Color(hex: "#0E4082")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color(hex: "#1973E8").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .top)
        .alert("Delete Video".localized(self.language), isPresented: $showDeleteAlert) {
            Button("Cancel".localized(self.language), role: .cancel) { }
            Button("Delete".localized(self.language), role: .destructive) {
                deleteCurrentVideo()
            }
        } message: {
            Text("Are you sure you want to delete this video?".localized(self.language))
        }
        .alert("Download".localized(self.language), isPresented: $showDownloadAlert) {
            Button("OK".localized(self.language), role: .cancel) { }
        } message: {
            Text(downloadMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            if FileManager.default.fileExists(atPath: video.videoURL.path) {
                ShareSheet(items: [video.videoURL])
            }
        }
        .onAppear {
            setupPlayer()
            hideTabBar()
        }
        .onDisappear {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
    }
    
    private func setupPlayer() {
        guard FileManager.default.fileExists(atPath: video.videoURL.path) else {
            print("❌ Video file not found at path: \(video.videoURL.path)")
            return
        }
        
        let playerItem = AVPlayerItem(url: video.videoURL)
        player.replaceCurrentItem(with: playerItem)
        
        // Auto-play when ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.player.play()
        }
        
        // Loop video using NotificationCenter (this doesn't require NSObject)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }
    
    private func deleteCurrentVideo() {
        SavedVideosManager.shared.deleteVideo(video)
        onDelete?()
        dismiss()
    }
    
    private func downloadVideoToGallery() {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: video.videoURL.path) else {
            downloadMessage = "Video file not found".localized(self.language)
            showDownloadAlert = true
            return
        }
        
        // Check permission status
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            performVideoDownload()
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        performVideoDownload()
                    } else {
                        showPermissionDeniedAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            showPermissionDeniedAlert()
            
        @unknown default:
            break
        }
    }
    
    private func performVideoDownload() {
        isDownloading = true
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: video.videoURL)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                isDownloading = false
                
                if success {
                    downloadMessage = "Video saved to gallery successfully!".localized(self.language)
                } else {
                    downloadMessage = "Failed to save video: \(error?.localizedDescription ?? "Unknown error")"
                }
                
                showDownloadAlert = true
            }
        }
    }
    
    private func showPermissionDeniedAlert() {
        downloadMessage = "Please grant photo library access in Settings to save videos.".localized(self.language)
        showDownloadAlert = true
    }
    
    private func hideTabBar() {
        NotificationCenter.default.post(name: NSNotification.Name("HideTabBar"), object: nil)
    }
}

// MARK: - Custom Video Player
struct CustomVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    @Binding var isReady: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerView()
        view.player = player
        view.backgroundColor = .black
        view.videoGravity = .resizeAspect
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerView = uiView as? PlayerView {
            playerView.player = player
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isReady: $isReady)
    }
    
    class Coordinator: NSObject {
        @Binding var isReady: Bool
        
        init(isReady: Binding<Bool>) {
            _isReady = isReady
            super.init()
        }
    }
}


// MARK: - PlayerView (UIView subclass)
// MARK: - PlayerView (UIView subclass with play/pause button)
class PlayerView: UIView {
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    weak var delegate: CustomVideoPlayer.Coordinator?
    
    // Play/Pause Button
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "play_ic"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        return button
    }()
    
    var player: AVPlayer? {
        get { return playerLayer?.player }
        set {
            if let layer = playerLayer {
                layer.player = newValue
            } else {
                let layer = AVPlayerLayer(player: newValue)
                layer.videoGravity = videoGravity
                layer.frame = self.bounds
                self.layer.addSublayer(layer)
                self.playerLayer = layer
            }
            
            // Bring button to front
            bringSubviewToFront(playPauseButton)
            
            // Add observer for player status
            if let player = newValue {
                // Observe when player is ready
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(playerItemDidReady),
                    name: .AVPlayerItemNewAccessLogEntry,
                    object: player.currentItem
                )
                
                // Add time observer to update button state
                addPeriodicTimeObserver()
                
                // Check player status
                checkPlayerStatus()
            }
        }
    }
    
    var videoGravity: AVLayerVideoGravity = .resizeAspect
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .black
        setupPlayPauseButton()
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupPlayPauseButton() {
        addSubview(playPauseButton)
        
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 70),
            playPauseButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Initially show button
        playPauseButton.alpha = 1
        
        // Auto-hide after 3 seconds
        perform(#selector(hidePlayPauseButton), with: nil, afterDelay: 3.0)
    }
    
    private func addPeriodicTimeObserver() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] _ in
            self?.updatePlayPauseButtonState()
        }
    }
    
    private func updatePlayPauseButtonState() {
        guard let player = player else { return }
        
        let imageName = player.timeControlStatus == .playing ? "pause_ic" : "play_ic"
        playPauseButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc private func togglePlayPause() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
        
        updatePlayPauseButtonState()
        
        // Show button when toggled
        UIView.animate(withDuration: 0.3) {
            self.playPauseButton.alpha = 1
        }
        
        // Auto-hide after 2 seconds when playing
        if player.timeControlStatus == .playing {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hidePlayPauseButton), object: nil)
            perform(#selector(hidePlayPauseButton), with: nil, afterDelay: 2.0)
        }
    }
    
    @objc private func handleTap() {
        // Show button on tap
        UIView.animate(withDuration: 0.3) {
            self.playPauseButton.alpha = 1
        }
        
        // Auto-hide after 3 seconds
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hidePlayPauseButton), object: nil)
        perform(#selector(hidePlayPauseButton), with: nil, afterDelay: 3.0)
    }
    
    @objc private func hidePlayPauseButton() {
        UIView.animate(withDuration: 0.3) {
            self.playPauseButton.alpha = 0
        }
    }
    
    @objc private func playerItemDidReady() {
        DispatchQueue.main.async {
            self.delegate?.isReady = true
        }
    }
    
    private func checkPlayerStatus() {
        // Check status after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if self?.player?.currentItem?.status == .readyToPlay {
                self?.delegate?.isReady = true
                self?.player?.play()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

