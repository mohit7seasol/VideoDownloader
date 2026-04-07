//
//  OnBoardingView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI

struct OnBoardingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage(SessionKeys.isLanguageDone) var isLanguageDone = false
    @AppStorage(SessionKeys.isOnboardingDone) var isOnboardingDone = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    @State private var currentIndex = 0
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private let pages: [OnboardingItem] = [
        OnboardingItem(
            title: "Fast Video Downloader",
            subtitle: "Download your favorite videos quickly and easily.",
            topImageName: Device.isIpad ? "ion1" : "on1"
        ),
        OnboardingItem(
            title: "Add Music to Your Video",
            subtitle: "Easily add your favorite songs and make videos more engaging.",
            topImageName: Device.isIpad ? "ion2" : "on2"
        ),
        OnboardingItem(
            title: "Add Trending Hashtags",
            subtitle: "Boost your reach with popular hashtags for every post.",
            topImageName: Device.isIpad ? "ion3" : "on3"
        )
    ]
    
    var body: some View {
        
        if !isLanguageDone {
            LanguageView()
        }
        else if !isOnboardingDone {
            if isIpad {
                // iPad Layout - Fixed
                GeometryReader { geo in
                    ZStack {
                        // Background Image
                        Image("app_bg_image")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            // Top Image
                            Image(pages[currentIndex].topImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: geo.size.width * 0.8,
                                    height: geo.size.height * 0.6
                                )
                                .padding(.top, geo.safeAreaInsets.top + 40)
                            
                            // Flexible space to push content
                            Spacer()
                            
                            // Text Content
                            OnboardingTextView(
                                currentIndex: $currentIndex,
                                pages: pages,
                                language: language,
                                isIpad: true
                            )
                            .frame(width: geo.size.width * 0.92)
                            
                            Button {
                                if currentIndex < pages.count - 1 {
                                    withAnimation {
                                        currentIndex += 1
                                    }
                                } else {
                                    isOnboardingDone = true
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } label: {
                                Text(currentIndex == pages.count - 1 ? "Done".localized(language) : "Next".localized(language))
                                    .font(.custom("Urbanist-Bold", size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 260, height: 64)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#1973E8"),
                                                Color(hex: "#0E4082")
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(32)
                                    .shadow(
                                        color: Color(hex: "#1973E8").opacity(0.3),
                                        radius: 10,
                                        x: 0,
                                        y: 6
                                    )
                            }
                            
                            // Flexible space before button
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            if value.translation.width < -50 {
                                if currentIndex < pages.count - 1 {
                                    withAnimation {
                                        currentIndex += 1
                                    }
                                }
                            } else if value.translation.width > 50 {
                                if currentIndex > 0 {
                                    withAnimation {
                                        currentIndex -= 1
                                    }
                                }
                            }
                        }
                )
            } else {
                // iPhone Layout (unchanged)
                ZStack {
                    // Background Image
                    Image("app_bg_image")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        Spacer(minLength: 0)
                        
                        // Top Image
                        Image(pages[currentIndex].topImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: UIScreen.main.bounds.height * 0.55
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.top, UIApplication.shared.safeAreaTop)
                        
                        Spacer(minLength: 0)
                        
                        // Text Content
                        OnboardingTextView(
                            currentIndex: $currentIndex,
                            pages: pages,
                            language: language,
                            isIpad: false
                        )
                        .frame(maxWidth: .infinity)
                        
                        Spacer(minLength: 20)
                        
                        // Next Button
                        Button {
                            if currentIndex < pages.count - 1 {
                                withAnimation {
                                    currentIndex += 1
                                }
                            } else {
                                isOnboardingDone = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text(currentIndex == pages.count - 1 ? "Done".localized(language) : "Next".localized(language))
                                .font(.custom("Urbanist-Bold", size: 18))
                                .foregroundColor(.white)
                                .frame(
                                    width: UIScreen.main.bounds.width / 3.0,
                                    height: 56
                                )
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#1973E8"),
                                            Color(hex: "#0E4082")
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(
                                    color: Color(hex: "#1973E8").opacity(0.3),
                                    radius: 10,
                                    x: 0,
                                    y: 6
                                )
                        }
                        .padding(.bottom, max(UIApplication.shared.safeAreaBottom, 20))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            if value.translation.width < -50 {
                                if currentIndex < pages.count - 1 {
                                    withAnimation {
                                        currentIndex += 1
                                    }
                                }
                            } else if value.translation.width > 50 {
                                if currentIndex > 0 {
                                    withAnimation {
                                        currentIndex -= 1
                                    }
                                }
                            }
                        }
                )
            }
        }
    }
}

// MARK: - Onboarding Text Content View
struct OnboardingTextView: View {
    @Binding var currentIndex: Int
    let pages: [OnboardingItem]
    let language: Language
    let isIpad: Bool
    
    var body: some View {
        VStack(spacing: isIpad ? 24 : 16) {
            // Custom Page Indicator
            HStack(spacing: isIpad ? 12 : 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? Color(hex: "#FC466B") : Color(hex: "#55495E"))
                        .frame(width: index == currentIndex ? (isIpad ? 32 : 24) : (isIpad ? 12 : 8),
                               height: isIpad ? 8 : 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                }
            }
            .padding(.bottom, isIpad ? 8 : 4)
            
            // Title
            Text(pages[currentIndex].title.localized(language))
                .font(.custom("Unlock-Regular", size: isIpad ? 32 : 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, isIpad ? 40 : 30)
                .lineSpacing(isIpad ? 4 : 2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Subtitle
            Text(pages[currentIndex].subtitle.localized(language))
                .font(.custom("Urbanist-Medium", size: isIpad ? 20 : 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, isIpad ? 50 : 35)
                .lineSpacing(isIpad ? 6 : 4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, isIpad ? 30 : 20)
        .frame(maxWidth: .infinity)
        .background(Color.clear)
    }
}

struct OnboardingItem {
    let title: String
    let subtitle: String
    let topImageName: String
}

#Preview {
    OnBoardingView()
}
