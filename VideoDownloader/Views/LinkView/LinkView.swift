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
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var bottomImageOffset: CGFloat = 0
    @StateObject private var folderSelectionManager = FolderSelectionManager()
    @State private var showCreateFolderAlert = false
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.endEditing(true)
                        isTextFieldFocused = false
                    }
                
                VStack(spacing: 0) {
                    // Top View (Reuse) - Fixed at top
                    TopHomeView()
                        .padding(.top, UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows
                            .first?.safeAreaInsets.top ?? 0)
                    
                    Spacer(minLength: 0)
                    
                    // Main content - Centered vertically
                    VStack(spacing: 20) {
                        Text("Instant Video Download".localized(self.language))
                            .font(Font.custom("Unlock-Regular", size: 22))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Paste the link and enjoy fast, hassle-free video downloads".localized(self.language))
                            .font(Font.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 40)
                        
                        // Post Link View
                        PostLinkView(
                            postLink: $viewModel.postLink,
                            pasteAction: viewModel.handlePaste,
                            isTextFieldFocused: _isTextFieldFocused
                        )
                        .frame(height: isIpad ? 80 : 60)
                        .padding(.horizontal, 30)
                        
                        // Download Button
                        Button {
                            // Hide keyboard when download button is pressed
                            UIApplication.shared.endEditing(true)
                            isTextFieldFocused = false
                            
                            // Small delay to ensure keyboard is dismissed before download starts
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                viewModel.downloadVideo()
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.horizontal, 50)
                                    .padding(.vertical, 14)
                            } else {
                                Text("Download".localized(language))
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
                    }
                    
                    Spacer(minLength: 0)
                    
                    // Bottom Image - Fixed at bottom with proper spacing
                    VStack {
                        Image("link_bottom_ic")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width - 40)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, UIApplication.shared.safeAreaBottom + 20)
                    .opacity(1)
                }
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK".localized(language), role: .cancel) {
                if viewModel.didDownloadSuccessfully {
                    tabManager.navigateToHistory()
                    viewModel.didDownloadSuccessfully = false
                } else {
                    // Clear the text field when alert is dismissed after failure
                    DispatchQueue.main.async {
                        viewModel.postLink = ""
                        isTextFieldFocused = false
                    }
                }
            }
        }
        .onAppear {
            viewModel.setTabManager(tabManager)
            setupKeyboardNotifications()
            // Set the linkViewModel reference in folderSelectionManager
            folderSelectionManager.linkViewModel = viewModel
        }
        .onDisappear {
            removeKeyboardNotifications()
        }
        .sheet(isPresented: $folderSelectionManager.showFolderSelection) {
            FolderSelectionView(
                folderManager: folderSelectionManager.folderManager,
                onFolderSelected: { folder in
                    folderSelectionManager.saveToSelectedFolder(folderId: folder.id)
                },
                onCreateNewFolder: {
                    folderSelectionManager.showFolderSelection = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCreateFolderAlert = true
                    }
                }
            )
        }
        .createFolderAlert(isPresented: $showCreateFolderAlert) { folderName in
            folderSelectionManager.createNewFolder(name: folderName)
        }
        .onReceive(NotificationCenter.default.publisher(for: .showFolderSelection)) { notification in
            if let videoURL = notification.userInfo?["videoURL"] as? URL,
               let sourceURL = notification.userInfo?["sourceURL"] as? String {
                let thumbnailURL = notification.userInfo?["thumbnailURL"] as? URL
                folderSelectionManager.handleDownloadedVideo(
                    videoURL: videoURL,
                    thumbnailURL: thumbnailURL,
                    sourceURL: sourceURL
                )
            }
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - PostLinkView
struct PostLinkView: View {
    @Binding var postLink: String
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    var pasteAction: () -> Void
    @FocusState var isTextFieldFocused: Bool
    
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
                    Text("Enter Insta post link".localized(self.language))
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 15))
                }
                
                TextField("", text: $postLink)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isTextFieldFocused = false
                    }
                    .onTapGesture {
                        // Clear the text field when tapped
                        if !postLink.isEmpty {
                            postLink = ""
                        }
                    }
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
