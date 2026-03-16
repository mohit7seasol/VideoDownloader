//
//  LinkView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI

struct LinkView: View {
    @StateObject private var viewModel = LinkViewModel()
    @EnvironmentObject var tabManager: TabSelectionManager
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.endEditing(true)
                }
            
            VStack(spacing: 20) {
                // 1️⃣ Top View (Reuse)
                TopHomeView()
                
                Text("Instant Video Download")
                    .font(Font.custom("Unlock-Regular", size: 22))
                    .foregroundColor(.white)
                
                Text("Paste the link and enjoy fast, hassle-free video downloads")
                    .font(Font.custom("Urbanist-Medium", size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 40)
                
                // Post Link View
                PostLinkView(
                    postLink: $viewModel.postLink,
                    pasteAction: viewModel.handlePaste
                )
                .frame(height: isIpad ? 80 : 60)
                .padding(.horizontal, 30)
                
                // 8️⃣ Download Button
                Button {
                    viewModel.downloadVideo()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 14)
                    } else {
                        Text("Download")
                            .font(Font.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 14)
                    }
                }
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
                .clipShape(Capsule())
                .shadow(
                    color: Color(hex: "#1973E8").opacity(0.3),
                    radius: 10,
                    x: 0,
                    y: 6
                )
                .disabled(viewModel.isLoading)
                .padding(.top, 10)
                
                // 9️⃣ Bottom Image
                Image("link_bottom_ic")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 30)
                
                Spacer()
            }
            .padding(.top, UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first?.safeAreaInsets.top ?? 0)
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {
                // Navigate to history tab (index 2) when user taps OK
                tabManager.navigateToHistory()
            }
        }
        .onAppear {
            viewModel.setTabManager(tabManager)
        }
    }
}

// MARK: - PostLinkView
struct PostLinkView: View {
    @Binding var postLink: String
    var pasteAction: () -> Void
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Link Icon
            Image("link_ic")
                .resizable()
                .scaledToFit()
                .frame(
                    width: isIpad ? 20 : 16,
                    height: isIpad ? 20 : 16
                )
            
            // TextField with placeholder
            ZStack(alignment: .leading) {
                if postLink.isEmpty {
                    Text("Enter Insta post link")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 15))
                }
                
                TextField("", text: $postLink)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Paste Button
            Button {
                pasteAction()
            } label: {
                Image("paste_ic")
                    .resizable()
                    .frame(
                        width: isIpad ? 50 : 40,
                        height: isIpad ? 50 : 40
                    )
            }
        }
        .padding(.horizontal, 16)
        .frame(height: isIpad ? 80 : 60)
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
    }
}

#Preview {
    LinkView()
}
