//
//  CaptionContentView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 12/03/26.
//

import SwiftUI
import UIKit

struct CaptionContentView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    // Selected category from CaptionBoxView
    var selectedCategoryId: Int
    var categoryTitle: String
    
    @State private var captionContents: [CaptionContent] = []
    @State private var isLoading = true
    
    init(viewModel: CategoryViewModel, selectedCategoryId: Int, categoryTitle: String) {
        self.viewModel = viewModel
        self.selectedCategoryId = selectedCategoryId
        self.categoryTitle = categoryTitle
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Custom Navigation Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .padding(.leading, 16)
                }
                
                Spacer()
                
                Text(categoryTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                Spacer()
                
                // Empty view for balance
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.top, UIApplication.shared.safeAreaTop)
            .padding(.bottom, 10)
            .background(Color.clear)
            .zIndex(1)
            
            // Content starts from top (below custom nav bar)
            VStack(spacing: 0) {
                // Spacer for custom nav bar height
                Color.clear
                    .frame(height: UIApplication.shared.safeAreaTop + 44)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                } else if captionContents.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "text.quote")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.5))
                        Text("No captions available".localized(self.language))
                            .foregroundColor(.white.opacity(0.7))
                            .font(.custom("Urbanist-Regular", size: 18))
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(captionContents, id: \.id) { content in
                                CaptionContentCardView(content: content.content)
                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 15 : 15)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            loadCaptionContents()
            hideTabBar()
        }
    }
    
    private func loadCaptionContents() {
        print("Loading contents for category ID: \(selectedCategoryId)")
        
        // First, ensure we have loaded contents
        if viewModel.captionContents.isEmpty {
            viewModel.loadCaptionContents()
        }
        
        // Filter contents by selected category id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.captionContents = self.viewModel.getContents(for: self.selectedCategoryId)
            self.isLoading = false
            print("Found \(self.captionContents.count) contents for category \(self.selectedCategoryId)")
        }
    }
    
    private func hideTabBar() {
        NotificationCenter.default.post(name: NSNotification.Name("HideTabBar"), object: nil)
    }
}

struct CaptionContentCardView: View {
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    let content: String
    @State private var showCopyAlert = false
    
    private var buttonHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 54 : 48
    }
    
    private var buttonWidth: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 110 : 94
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            // Caption text (dynamic height)
            Text(content)
                .foregroundColor(.white)
                .font(.custom("Urbanist-Regular", size: 16))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Buttons
            HStack(spacing: 10) {
                
                Button(action: {
                    copyToClipboard()
                }) {
                    HStack {
                        Image("copy_ic")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                        
                        Text("Copy")
                            .font(.custom("Urbanist-Regular", size: 16))
                    }
                    .foregroundColor(.white)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    shareContent()
                }) {
                    HStack {
                        Image("share_ic")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                        
                        Text("Share".localized(self.language))
                            .font(.custom("Urbanist-Regular", size: 16))
                    }
                    .foregroundColor(.white)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FFFFFF").opacity(0.05),
                    Color(hex: "#FFFFFF").opacity(0.10)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .alert(isPresented: $showCopyAlert) {
            Alert(
                title: Text("Copied!".localized(language)),
                message: Text("Caption copied to clipboard"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = content
        showCopyAlert = true
    }
    
    private func shareContent() {
        // Create the activity view controller with the content
        let activityViewController = UIActivityViewController(
            activityItems: [content],
            applicationActivities: nil
        )
        
        // For iPad support - set popover presentation style
        if let popoverController = activityViewController.popoverPresentationController {
            // Find the source view for the popover
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                // Set the source view and rect for the popover
                popoverController.sourceView = rootViewController.view
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        // Present the activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            // Find the top-most presented view controller
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            
            topViewController.present(activityViewController, animated: true)
        }
    }
}

