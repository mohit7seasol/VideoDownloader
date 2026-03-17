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
            title: "Fast Video Downloader",
            subtitle: "Download your favorite videos quickly and easily.",
            topImageName: "on2"
        ),
        OnboardingItem(
            title: "Fast Video Downloader",
            subtitle: "Download your favorite videos quickly and easily.",
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
                    
                    // ✅ 4. Custom Page Indicator
                    HStack(spacing: 6) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentIndex ? Color(hex: "#FC466B") : Color(hex: "#55495E"))
                                .frame(width: index == currentIndex ? 20 : 8, height: 6)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    // ✅ 3. Title
                    Text(pages[currentIndex].title.localized(language))
                        .font(.custom("Unlock-Regular", size: 22))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // ✅ Subtitle
                    Text(pages[currentIndex].subtitle.localized(language))
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 30)
                        .padding(.top, 6)
                    
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
                                width: UIScreen.main.bounds.width / 2.5,
                                height: isIpad ? 66 : 56
                            )
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#1973E8").opacity(0.3),
                                        Color(hex: "#0E4082")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(30)
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

struct OnboardingItem {
    let title: String
    let subtitle: String
    let topImageName: String
}

#Preview {
    OnBoardingView()
}
