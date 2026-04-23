//
//  SoundTrackView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 13/03/26.
//

import SwiftUI

// MARK: - SoundTrackView
struct SoundTrackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navigateToVideoChoose = false
    @State private var shouldNavigateToSelf = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        if Device.isIpad {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Custom nav bar spacer
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: UIApplication.shared.safeAreaTop + 44)
                    
                    // Main Content
                    VStack(spacing: Device.isIpad ? 30 : 20) {
                        // Lottie Animation
                        LottieView(name: "Music Note Add")
                            .frame(width: Device.isIpad ? 200 : 140,
                                   height: Device.isIpad ? 200 : 140)
                            .background(Color.clear)
                            .padding(.top, Device.isIpad ? 40 : 0)
                        
                        // Title Label
                        Text("Enhance Video with Music".localized(self.language))
                            .font(.custom("Poppins-Black", size: Device.isIpad ? 32 : 22))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Device.isIpad ? 60 : 40)
                        
                        // Subtitle Label
                        Text("Enhance your video experience with the right music.".localized(self.language))
                            .font(.custom("Urbanist-Medium", size: Device.isIpad ? 22 : 18))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, Device.isIpad ? 80 : 50)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Device.isIpad ? 60 : 0)
                    
                    // Spacer to push button to bottom
                    Spacer(minLength: Device.isIpad ? 100 : 0)
                    
                    // Bottom Button
                    Button {
                        navigateToVideoChoose = true
                    } label: {
                        Text("Add Soundtrack".localized(self.language))
                            .font(.custom("Urbanist-Bold", size: Device.isIpad ? 22 : 18))
                            .foregroundColor(.white)
                            .frame(width: Device.isIpad ? UIScreen.main.bounds.width / 2.5 : UIScreen.main.bounds.width / 2)
                            .frame(height: Device.isIpad ? 64 : 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "1973E8"),
                                        Color(hex: "0E4082")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(Device.isIpad ? 32 : 28)
                            .shadow(
                                color: Color(hex: "1973E8").opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .padding(.bottom, Device.isIpad ? 60 : 50)
                    
                    // ✅ Critical bottom padding to ensure button is visible
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: UIApplication.shared.safeAreaBottom + 20)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
            .background(
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .overlay(alignment: .top) {
                // Custom Navigation Bar as overlay
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: Device.isIpad ? 24 : 20, weight: .semibold))
                            .padding(.leading, Device.isIpad ? 20 : 16)
                    }
                    
                    Spacer()
                    
                    Text("Soundtrack".localized(self.language))
                        .font(.custom("Poppins-Black", size: Device.isIpad ? 24 : 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: Device.isIpad ? 50 : 40, height: Device.isIpad ? 50 : 40)
                }
                .padding(.top, UIApplication.shared.safeAreaTop)
                .padding(.bottom, 10)
                .padding(.horizontal, Device.isIpad ? 20 : 16)
                .background(Color.clear)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToVideoChoose) {
                VideoChooseView(selectionType: .AddMusicToVideoView)
            }
        } else {
            ZStack {
                // Background Image
                Image("app_bg_image")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Soundtrack".localized(self.language))
                            .font(.custom("Poppins-Black", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        // Empty view for balance
                        Color.clear
                            .frame(width: 20, height: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, UIApplication.shared.connectedScenes
                                .compactMap { $0 as? UIWindowScene }
                                .first?.windows
                                .first?.safeAreaInsets.top ?? 0)
                    
                    Spacer()
                    
                    // Vertically Centered Content
                    VStack(spacing: 20) {
                        // Lottie Animation
                        LottieView(name: "Music Note Add")
                            .frame(width: 140, height: 140)
                            .background(Color.clear)
                        
                        // Title Label
                        Text("Enhance Video with Music".localized(self.language))
                            .font(.custom("Poppins-Black", size: 22))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Subtitle Label
                        Text("Enhance your video experience with the right music.".localized(self.language))
                            .font(.custom("Urbanist-Medium", size: 18))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 50)
                    }
                    
                    Spacer()
                    
                    // Bottom Button with screen width/3
                    Button {
                        navigateToVideoChoose = true
                    } label: {
                        Text("Add Soundtrack".localized(self.language))
                            .font(.custom("Urbanist-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "1973E8"),
                                        Color(hex: "0E4082")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(28)
                            .shadow(
                                color: Color(hex: "1973E8").opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .padding(.bottom, 50)
                    .ignoresSafeArea()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToVideoChoose) {
                VideoChooseView(selectionType: .AddMusicToVideoView)
            }
        }
    }
}

// MARK: - AddMusicView
struct AddMusicView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        ZStack {
            // Background Image
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
                    
                    Spacer()
                    
                    Text("Add Music".localized(self.language))
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
                
                // Placeholder content for AddMusicView
                VStack(spacing: 20) {
                    LottieView(name: "Link")
                        .frame(width: 100, height: 100)
                    
                    Text("Choose a Soundtrack".localized(self.language))
                        .font(.custom("Poppins-Black", size: 24))
                        .foregroundColor(.white)
                    
                    Text("Select from your library or browse our collection".localized(self.language))
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
#Preview {
    SoundTrackView()
}
