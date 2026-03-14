//
//  MusicLibraryView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 14/03/26.
//

import SwiftUI
import MediaPlayer 

struct MusicTrack: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let artist: String?
    let url: URL
    let duration: TimeInterval
    
    static func == (lhs: MusicTrack, rhs: MusicTrack) -> Bool {
        lhs.id == rhs.id
    }
}

struct MusicLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedMusic: MusicTrack?
    
    @State private var tracks: [MusicTrack] = []
    @State private var isLoading = true
    @State private var hasPermission = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        NavigationView {
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
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                        Spacer()
                    } else if !hasPermission {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Music Access Required")
                                .font(.custom("Poppins-Black", size: 18))
                                .foregroundColor(.white)
                            
                            Text("Please grant access to your music library to add soundtracks")
                                .font(.custom("Urbanist-Medium", size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button("Grant Access") {
                                requestMusicLibraryPermission()
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "1973E8"), Color(hex: "0E4082")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        Spacer()
                    } else if tracks.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "music.note")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No Music Found")
                                .font(.custom("Poppins-Black", size: 18))
                                .foregroundColor(.white)
                            
                            Text("Add songs to your Apple Music library to see them here")
                                .font(.custom("Urbanist-Medium", size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    } else {
                        // Music List
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(tracks) { track in
                                    MusicTrackRow(track: track, isSelected: selectedMusic?.id == track.id)
                                        .onTapGesture {
                                            selectedMusic = track
                                            dismiss()
                                        }
                                        .padding(.horizontal, 24)
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            checkMusicLibraryPermission()
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please grant access to your music library in Settings to add soundtracks")
        }
    }
    
    private func checkMusicLibraryPermission() {
        let status = MPMediaLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            hasPermission = true
            loadMusicTracks()
        case .notDetermined:
            requestMusicLibraryPermission()
        case .denied, .restricted:
            hasPermission = false
            showPermissionAlert = true
            isLoading = false
        @unknown default:
            hasPermission = false
            isLoading = false
        }
    }
    
    private func requestMusicLibraryPermission() {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    hasPermission = true
                    loadMusicTracks()
                default:
                    hasPermission = false
                    isLoading = false
                }
            }
        }
    }
    
    private func loadMusicTracks() {
        isLoading = true
        
        let query = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(
            value: false,
            forProperty: MPMediaItemPropertyIsCloudItem,
            comparisonType: .equalTo
        )
        query.addFilterPredicate(predicate)
        
        guard let items = query.items, !items.isEmpty else {
            DispatchQueue.main.async {
                self.tracks = []
                self.isLoading = false
            }
            return
        }
        
        var musicTracks: [MusicTrack] = []
        
        for item in items.prefix(50) { // Limit to 50 songs for performance
            guard let assetURL = item.assetURL else { continue }
            
            let track = MusicTrack(
                name: item.title ?? "Unknown",
                artist: item.artist,
                url: assetURL,
                duration: item.playbackDuration
            )
            musicTracks.append(track)
        }
        
        DispatchQueue.main.async {
            self.tracks = musicTracks
            self.isLoading = false
        }
    }
}

struct MusicTrackRow: View {
    let track: MusicTrack
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Album Art or Placeholder
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
                
                Image(systemName: "music.note")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.custom("Urbanist-Bold", size: 16))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let artist = track.artist {
                    Text(artist)
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Duration
            Text(formatDuration(track.duration))
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.white.opacity(0.5))
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "1973E8"))
                    .font(.system(size: 20))
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
