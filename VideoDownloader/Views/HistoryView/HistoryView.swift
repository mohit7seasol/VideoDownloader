//
//  HistoryView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 16/03/26.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = HistoryViewModel()
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    private let columns: [GridItem] = {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let count = isIPad ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }()
    
    var body: some View {
        ZStack {
            // Background
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
                    
                    Text("Soundtrack History".localized(self.language))
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .frame(height: 100)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Spacer()
                } else if viewModel.savedVideos.isEmpty {
                    // Empty state
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("No Videos Yet".localized(self.language))
                            .font(.custom("Urbanist-Bold", size: 20))
                            .foregroundColor(.white)
                        
                        Text("Your edited videos will appear here".localized(self.language))
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    // Video Grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.savedVideos) { video in
                                HistoryCardView(video: video) {
                                    viewModel.confirmDelete(video)
                                }
                                .onTapGesture {
                                    // Navigate to watch video
                                    // You can add navigation here if needed
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Delete Video".localized(self.language), isPresented: $viewModel.showDeleteAlert) {
            Button("Cancel".localized(self.language), role: .cancel) {
                viewModel.handleDeleteConfirmation(confirmed: false)
            }
            Button("Delete".localized(self.language), role: .destructive) {
                viewModel.handleDeleteConfirmation(confirmed: true)
            }
        } message: {
            if let video = viewModel.videoToDelete {
                Text("\("Are you sure you want to delete".localized(self.language)) \"\(video.musicName ?? ("this video".localized(self.language)))\"?")
            } else {
                Text("Are you sure you want to delete this video?".localized(self.language))
            }
        }
        .onAppear {
            viewModel.loadVideos()
        }
    }
}
