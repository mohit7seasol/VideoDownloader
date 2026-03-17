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
            VideoChooseView()
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
