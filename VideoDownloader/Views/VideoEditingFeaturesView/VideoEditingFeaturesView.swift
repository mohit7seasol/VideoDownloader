//
//  VideoEditingFeaturesView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 24/04/26.
//

import SwiftUI

struct VideoEditingFeaturesView: View {
    @State private var navigateToFilterVideo = false
    @State private var navigateToTrimVideo = false
    @State private var navigateToFlipVideo = false
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        if Device.isIpad {
            // iPad Layout
            GeometryReader { geometry in
                ZStack {
                    Image("app_bg_image")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Custom Navigation Bar - Outside ScrollView
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Powerful Video Editing".localized(self.language))
                                .font(.custom("Poppins-Black", size: isIpad ? 28 : 20))
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, UIApplication.shared.safeAreaTop)
                        .padding(.bottom, 10)
                        
                        // ScrollView - Below Navigation Bar
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 24) {
                                VideoFeaturesView(
                                    onFilterVideoTap: {
                                        navigateToFilterVideo = true
                                    },
                                    onTrimVideoTap: {
                                        navigateToTrimVideo = true
                                    },
                                    onFlipVideoTap: {
                                        navigateToFlipVideo = true
                                    }
                                )
                                
                                // Extra bottom space for iPad
                                Spacer()
                                    .frame(height: 720)
                            }
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToFilterVideo) {
                VideoChooseView(selectionType: .AddFramesToVideoView)
            }
            .navigationDestination(isPresented: $navigateToTrimVideo) {
                VideoChooseView(selectionType: .AddTrimToVideoView)
            }
            .navigationDestination(isPresented: $navigateToFlipVideo) {
                VideoChooseView(selectionType: .AddFlipToVideoView)
            }
        } else {
            // iPhone Layout
            ZStack {
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar - Outside ScrollView
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Powerful Video Editing".localized(self.language))
                            .font(.custom("Poppins-Black", size: isIpad ? 28 : 20))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, UIApplication.shared.safeAreaTop)
                    .padding(.bottom, 10)
                    
                    // ScrollView - Below Navigation Bar
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            VideoFeaturesView(
                                onFilterVideoTap: {
                                    navigateToFilterVideo = true
                                },
                                onTrimVideoTap: {
                                    navigateToTrimVideo = true
                                },
                                onFlipVideoTap: {
                                    navigateToFlipVideo = true
                                }
                            )
                            
                            // Extra bottom space for iPhone
                            Spacer()
                                .frame(height: 80)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToFilterVideo) {
                VideoChooseView(selectionType: .AddFramesToVideoView)
            }
            .navigationDestination(isPresented: $navigateToTrimVideo) {
                VideoChooseView(selectionType: .AddTrimToVideoView)
            }
            .navigationDestination(isPresented: $navigateToFlipVideo) {
                VideoChooseView(selectionType: .AddFlipToVideoView)
            }
        }
    }
}

// MARK: - Video Features View
struct VideoFeaturesView: View {
    var onFilterVideoTap: (() -> Void)?
    var onTrimVideoTap: (() -> Void)?
    var onFlipVideoTap: (() -> Void)?

    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 16) {
                // Filter Video Card
                VideoFeaturesCardView(
                    bgImage: "filter_bg",
                    title: "Apply Filters Video".localized(self.language),
                    icon: "h7",
                    buttonColor: "#F86BFF",
                    onTap: onFilterVideoTap
                )
                
                // Trim Video Card
                VideoFeaturesCardView(
                    bgImage: "trim_bg",
                    title: "Trim Video".localized(self.language),
                    icon: "h8",
                    buttonColor: "#45B8FF",
                    onTap: onTrimVideoTap
                )
                
                // Flip Video Card
                VideoFeaturesCardView(
                    bgImage: "flip_bg",
                    title: "Flip Video".localized(self.language),
                    icon: "h9",
                    buttonColor: "#95E57D",
                    onTap: onFlipVideoTap
                )
            }
        }
    }
}

// MARK: - Video Features Card View
struct VideoFeaturesCardView: View {
    let bgImage: String
    let title: String
    let icon: String
    let buttonColor: String
    var onTap: (() -> Void)?
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            Image(bgImage)
                .resizable()
                .scaledToFill()
                .frame(height: isIpad ? 180 : 150)
                .clipped()
                .cornerRadius(16)
            
            // Overlay Gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.6)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(16)
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 5) {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: isIpad ? 40 : 30, height: isIpad ? 40 : 30)
                        
                        Text(title)
                            .font(.custom("Urbanist-Bold", size: isIpad ? 20 : 16))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Try Now button
                    Button(action: {
                        onTap?()
                    }) {
                        Text("Try Now".localized(self.language))
                            .font(.custom("Urbanist-Bold", size: isIpad ? 18 : 14))
                            .foregroundColor(.black)
                            .padding(.horizontal, isIpad ? 24 : 16)
                            .padding(.vertical, isIpad ? 12 : 8)
                            .background(Color(hex: buttonColor))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}
#Preview {
    VideoEditingFeaturesView()
}
