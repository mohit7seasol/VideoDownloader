//
//  SplashView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI
import Lottie

struct SplashView: View {
    
    @AppStorage(SessionKeys.isLanguageDone) var isLanguageDone = false
    @AppStorage(SessionKeys.isOnboardingDone) var isOnboardingDone = false
    @AppStorage(SessionKeys.isOneTimeDone) var isOneTimeDone = true
    
    @StateObject private var vm = SplashViewModel()
    
    @State private var isShowOnboarding = false
    @State private var isShowHomeView = false
    @State private var isLottiePlaying = true
    
    var body: some View {
        
        VStack {
            if isShowHomeView {
                TabBarView()
            } else {
                SplashContent(isLottiePlaying: $isLottiePlaying)
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $isShowOnboarding) {
            OnBoardingView()
        }
        .onAppear {
            handleStartupFlow()
        }
    }
    
    private func handleStartupFlow() {
        
        // Start API call (same as reference)
        vm.fetchSplashData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            // Stop animation if needed
            isLottiePlaying = false
            
            if !isLanguageDone || !isOnboardingDone {
                
                isShowOnboarding = true
                isOneTimeDone = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowHomeView = true
                }
                
            } else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowHomeView = true
                }
            } 
        }
    }
}

struct SplashContent: View {
    
    @Binding var isLottiePlaying: Bool
    
    // Detect device type for adaptive sizing
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    private var isIpad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        
        ZStack {
            Image("Splash_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                Text("VideoFetch")
                    .font(.custom("Unlock-Regular", size: 30))
                    .foregroundColor(.white) // Adjust color as needed
                    .multilineTextAlignment(.center)
                
                Text("Save Your Favorite Videos in One Tap")
                    .font(.custom("Urbanist-Regular", size: 18))
                    .foregroundColor(.white.opacity(0.8)) // Adjust color as needed
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Image("app_icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: isIpad ? 200 : 150,
                           height: isIpad ? 200 : 150)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                Spacer()
                
                MyLottieView(
                    animationFileName: "Loading Dots",
                    loopMode: .loop
                )
                .frame(width: 120, height: 80)
                .padding(.bottom, 10)
            }
        }
    }
}

// MARK: - Lottie View Component
struct MyLottieView: UIViewRepresentable {
    
    let animationFileName: String
    let loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: animationFileName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Keep the animation playing
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            animationView.play()
        }
    }
}
#Preview {
    SplashView()
}
