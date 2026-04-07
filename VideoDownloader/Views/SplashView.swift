//
//  SplashView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

/* import SwiftUI
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
            NavigationStack {
                if isShowHomeView {
                    TabBarView1()
                } else {
                    SplashContent(isLottiePlaying: $isLottiePlaying)
                }
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
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
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
                
                Text("Save Your Favorite Videos in One Tap".localized(self.language))
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
} */
import SwiftUI
import Lottie
import AppTrackingTransparency
import AdSupport

struct SplashView: View {
    
    @AppStorage(SessionKeys.isLanguageDone) var isLanguageDone = false
    @AppStorage(SessionKeys.isOnboardingDone) var isOnboardingDone = false
    @AppStorage(SessionKeys.isOneTimeDone) var isOneTimeDone = true
    @AppStorage("hasRequestedTrackingPermission") var hasRequestedTrackingPermission = false
    
    @StateObject private var vm = SplashViewModel()
    
    @State private var isShowOnboarding = false
    @State private var isShowHomeView = false
    @State private var isLottiePlaying = true
    @State private var isTrackingPermissionChecked = false
    
    var body: some View {
        
        VStack {
            NavigationStack {
                if isShowHomeView {
                    TabBarView1()
                } else {
                    SplashContent(isLottiePlaying: $isLottiePlaying)
                }
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
        
        // Request tracking permission if needed
        requestTrackingPermissionIfNeeded()
        
        // Start API call (same as reference)
        vm.fetchSplashData()
        
        // Wait for tracking permission check to complete
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
    
    // MARK: - Tracking Permission Methods
    private func requestTrackingPermissionIfNeeded() {
        // Check if we're on iOS 14 or later
        if #available(iOS 14, *) {
            // Check if already requested permission
            if !hasRequestedTrackingPermission {
                // Show tracking permission request after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    requestTrackingAuthorization()
                }
            }
        } else {
            // For iOS 13 and below, no permission needed
            hasRequestedTrackingPermission = true
            isTrackingPermissionChecked = true
        }
    }
    
    @available(iOS 14, *)
    private func requestTrackingAuthorization() {
        // Check current authorization status
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        switch status {
        case .notDetermined:
            // Request permission
            ATTrackingManager.requestTrackingAuthorization { [self] status in
                DispatchQueue.main.async {
                    handleTrackingStatus(status)
                }
            }
        case .restricted, .denied:
            // Permission denied or restricted
            handleTrackingStatus(status)
        case .authorized:
            // Permission already granted
            handleTrackingStatus(status)
        @unknown default:
            handleTrackingStatus(.denied)
        }
    }
    
    private func handleTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            print("✅ Tracking permission granted")
            // User granted permission - can track
            let advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            print("Advertising ID: \(advertisingId)")
            
        case .denied:
            print("❌ Tracking permission denied")
            // User denied permission - don't track
            // You can still show non-personalized ads
            
        case .restricted:
            print("⚠️ Tracking permission restricted")
            // Permission restricted (e.g., parental controls)
            
        case .notDetermined:
            print("❓ Tracking permission not determined")
            // Should not happen as we already requested
            
        @unknown default:
            print("Unknown tracking status")
        }
        
        // Mark as requested to avoid showing again
        hasRequestedTrackingPermission = true
        isTrackingPermissionChecked = true
        
        // You can update your analytics/ads SDKs here
        updateTrackingConsent(status == .authorized)
    }
    
    private func updateTrackingConsent(_ isAuthorized: Bool) {
        // Update any analytics or ad SDKs with consent status
        // For example, if using Google Analytics or Firebase:
        // Analytics.setUserProperty(isAuthorized ? "granted" : "denied", forName: "tracking_consent")
        
        // If using Google AdMob:
        if isAuthorized {
            // Enable personalized ads
            // Google Mobile Ads SDK will handle this automatically
            print("Personalized ads enabled")
        } else {
            // Disable personalized ads
            // Google Mobile Ads SDK will handle this automatically
            print("Non-personalized ads only")
        }
    }
}

struct SplashContent: View {
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
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
                
                Text("Save Your Favorite Videos in One Tap".localized(self.language))
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
                .padding(.bottom, Device.isIpad ? 500 : 10)
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
