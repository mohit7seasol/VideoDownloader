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
                
                Spacer()
                
                // Empty view for balance
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 47)
            .padding(.bottom, 10)
            .background(Color.clear)
            .zIndex(1)
            
            // Content starts from top (below custom nav bar)
            VStack(spacing: 0) {
                // Spacer for custom nav bar height
                Color.clear
                    .frame(height: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 47) + 44)
                
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
                        Text("No captions available")
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
    let content: String
    @State private var showCopyAlert = false
    
    // Dynamic height based on content
    @State private var contentHeight: CGFloat = 0
    
    // Device specific sizing
    private var cardHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 220 : 180
    }
    
    private var buttonHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 54 : 48
    }
    
    private var buttonWidth: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 110 : 94
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Content Label - Top side
            Text(content)
                .foregroundColor(.white)
                .font(.custom("Urbanist-Regular", size: 16))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.top, 15)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                contentHeight = geometry.size.height
                            }
                    }
                )
            
            Spacer(minLength: 0)
            
            // Bottom buttons - Copy and Share
            HStack(spacing: 10) {
                // Copy Button
                Button(action: {
                    copyToClipboard()
                }) {
                    HStack {
                        Image("copy_ic")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text("Copy")
                            .font(.custom("Urbanist-Regular", size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
                
                // Share Button
                Button(action: {
                    shareContent()
                }) {
                    HStack {
                        Image("share_ic")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text("Share")
                            .font(.custom("Urbanist-Regular", size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 15)
        }
        .frame(height: max(cardHeight, contentHeight + buttonHeight + 40))
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
                title: Text("Copied!"),
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
        let av = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        
        // For iPad, set popover presentation
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                av.popoverPresentationController?.sourceView = rootViewController.view
                av.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                av.popoverPresentationController?.permittedArrowDirections = []
                rootViewController.present(av, animated: true)
            }
        } else {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(av, animated: true)
            }
        }
    }
}

