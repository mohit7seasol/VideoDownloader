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
    
    private var buttonSize: CGFloat {
        isIpad ? 80 : 50
    }
    
    private var pageControlWidth: CGFloat {
        isIpad ? 150 : 100
    }
    
    private let pages: [OnboardingItem] = [
        OnboardingItem(
            background: "on1",
            centerImage: "on1_1",
            title: "All Wallpaper You Need"
        ),
        OnboardingItem(
            background: "on2",
            centerImage: "on2_1",
            title: "High Quality Wallpaper Download"
        ),
        OnboardingItem(
            background: "on3",
            centerImage: "on3_1",
            title: "Upgrade Your Lock Screen"
        ),
        OnboardingItem(
            background: "on4",
            centerImage: "on4_1",
            title: "Set Your Favorite Live Wallpaper"
        )
    ]
    
    var body: some View {
        
        // MARK: Language Screen First
        if !isLanguageDone {
            LanguageView()
        }
        
        // MARK: Onboarding Screens
        else if !isOnboardingDone {
            
            ZStack {
                
                // Background
                Image(pages[currentIndex].background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // Dark overlay
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack {
                    
                    Spacer()
                    
                    // Center Image
                    Image(pages[currentIndex].centerImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: isIpad ? 450 : 280)
                        .padding(.bottom, 30)
                    
                    // Title
                    Text(pages[currentIndex].title.localized(language))
                        .font(.custom("Oxanium-SemiBold", size: 32))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Bottom Controls
                    HStack {
                        
                        // Previous Button
                        if currentIndex != 0 {
                            Button {
                                withAnimation {
                                    currentIndex -= 1
                                }
                            } label: {
                                Image("on_previous")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: buttonSize, height: buttonSize)
                            }
                        } else {
                            Spacer()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                        
                        Spacer()
                        
                        // Page Indicator
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .frame(width: pageControlWidth)
                        
                        Spacer()
                        
                        // Next / Done Button
                        Button {
                            
                            if currentIndex < pages.count - 1 {
                                
                                withAnimation {
                                    currentIndex += 1
                                }
                                
                            } else {
                                
                                // MARK: Last Screen Finished
                                isOnboardingDone = true
                                
                                // dismiss onboarding
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                        } label: {
                            Image(currentIndex == pages.count - 1 ? "on_done" : "on_next")
                                .resizable()
                                .scaledToFit()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, isIpad ? 60 : 40)
                }
                .onAppear {
                    if currentIndex == 3 { // 4th screen (index 3)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            if currentIndex == 3 {
                                isOnboardingDone = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
            // MARK: - Swipe Gesture Added (No UI changes)
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        
                        if horizontalAmount < -50 {
                            // Swipe Left - Next
                            if currentIndex < pages.count - 1 {
                                withAnimation {
                                    currentIndex += 1
                                }
                            } else if currentIndex == pages.count - 1 {
                                // On last screen, swipe left to complete
                                isOnboardingDone = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        } else if horizontalAmount > 50 {
                            // Swipe Right - Previous
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
    let background: String
    let centerImage: String
    let title: String
}

#Preview {
    OnBoardingView()
}
