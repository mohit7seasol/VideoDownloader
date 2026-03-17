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
            topImageName: "on1"
        ),
        OnboardingItem(
            title: "Add Music to Your Video",
            subtitle: "Easily add your favorite songs and make videos more engaging.",
            topImageName: "on2"
        ),
        OnboardingItem(
            title: "Add Trending Hashtags",
            subtitle: "Boost your reach with popular hashtags for every post.",
            topImageName: "on3"
        )
    ]
    
    var body: some View {
        
        if !isLanguageDone {
            LanguageView()
        }
        else if !isOnboardingDone {
            
            ZStack {
                
                // ✅ 1. Background Image
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // ✅ 5. Top Image
                    Image(pages[currentIndex].topImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height * 0.55)
                        .frame(maxWidth: .infinity)
                        .padding(.top, UIApplication.shared.safeAreaTop)
                    
                    Spacer()
                    
                    // ✅ Text Content View (Page Indicator + Title + Subtitle)
                    OnboardingTextView(
                        currentIndex: $currentIndex,
                        pages: pages,
                        language: language
                    )
                    
                    Spacer()
                    
                    // ✅ 2. Next Button
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
                                height: isIpad ? 66 : 56
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
                    .padding(.bottom,
                        10 + (UIApplication.shared.connectedScenes
                                .compactMap { $0 as? UIWindowScene }
                                .first?.windows
                                .first?.safeAreaInsets.bottom ?? 0)
                    )
                    
                }
            }
            .ignoresSafeArea()
            
            // ✅ 6. Swipe Gesture
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

// MARK: - Onboarding Text Content View
struct OnboardingTextView: View {
    @Binding var currentIndex: Int
    let pages: [OnboardingItem]
    let language: Language
    
    var body: some View {
        VStack(spacing: 16) {
            // ✅ 4. Custom Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? Color(hex: "#FC466B") : Color(hex: "#55495E"))
                        .frame(width: index == currentIndex ? 24 : 8, height: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                }
            }
            .padding(.bottom, 4)
            
            // ✅ 3. Title
            Text(pages[currentIndex].title.localized(language))
                .font(.custom("Unlock-Regular", size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // ✅ Subtitle
            Text(pages[currentIndex].subtitle.localized(language))
                .font(.custom("Urbanist-Medium", size: 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 35)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.clear) // Transparent background
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
