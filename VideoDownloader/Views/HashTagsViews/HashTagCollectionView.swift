//
//  HashTagCollectionView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 12/03/26.
//

import SwiftUI
import Shimmer

struct HashTagCollectionView: View {
    let category: String
    @StateObject private var viewModel = HashtagViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedHashtag: HashtagModel.Hashtag?
    @State private var showCopyAlert = false
    @State private var copiedText = ""
    @State private var mappedTitle: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Image - Fixed
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
                
                Text(category)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                Spacer()
                
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.top, UIApplication.shared.safeAreaTop)
            .padding(.bottom, 10)
            .background(Color.clear) // Clear background
            .zIndex(1)
            
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: UIApplication.shared.safeAreaTop + 44)
                
                if viewModel.isLoading {
                    // Shimmer Loading Cards
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(0..<5, id: \.self) { _ in
                                HashTagCollectionCardShimmer()
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Error loading hashtags")
                            .font(.custom("Urbanist-Bold", size: 18))
                            .foregroundColor(.white)
                        Text(error)
                            .font(.custom("Urbanist-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            viewModel.fetchHashtags(for: category)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(8)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.getHashtagsForCategory(mappedTitle), id: \.id) { hashtag in
                                HashTagCollectionCard(
                                    hashtag: hashtag,
                                    onCopy: { text in
                                        copiedText = text
                                        showCopyAlert = true
                                    }
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .top)
        .background(Color.clear) // Ensure clear background
        .onAppear {
            mappedTitle = mapCategoryTitle(category)
            viewModel.fetchHashtags(for: mappedTitle)
        }
        .alert(isPresented: $showCopyAlert) {
            Alert(
                title: Text("Copied!"),
                message: Text("Hashtags copied to clipboard"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    func mapCategoryTitle(_ category: String) -> String {
        switch category {
        case "Weather":
            return "Weather/Seasons"
        case "People":
            return "Social/People"
        case "Holidays":
            return "Holidays / Celebrations"
        case "Photography":
            return "Art/Photography"
        case "Follow":
            return "Follow/Shoutout/Like/Comment"
        case "Travel":
            return "Travel/Active/Sports"
        case "Text":
            return "Text Art"
        default:
            return category
        }
    }
}
struct HashTagCollectionCard: View {
    let hashtag: HashtagModel.Hashtag
    let onCopy: (String) -> Void
    
    @State private var showCopyAlert = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    private var buttonHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 54 : 48
    }
    
    private var buttonWidth: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 110 : 94
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title Label
            Text(hashtag.tag_name ?? "")
                .font(.custom("Urbanist-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Subtitle Label (tag_name_detail)
            Text(hashtag.tag_name_detail ?? "")
                .font(.custom("Urbanist-Regular", size: 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Buttons (Copy and Share)
            HStack(spacing: 10) {
                Button(action: {
                    copyToClipboard()
                }) {
                    HStack {
                        Image("copy_ic")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                        
                        Text("Copy".localized(self.language))
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
            // Linear Gradient from top to bottom with specified opacity
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FFFFFF").opacity(0.05), // 5% opacity at top
                    Color(hex: "#FFFFFF").opacity(0.10)  // 10% opacity at bottom
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
        .background(Color.clear) // Ensure clear background
        .alert(isPresented: $showCopyAlert) {
            Alert(
                title: Text("Copied!"),
                message: Text("Hashtags copied to clipboard"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func copyToClipboard() {
        let textToCopy = hashtag.tag_name_detail ?? ""
        UIPasteboard.general.string = textToCopy
        onCopy(textToCopy)
        showCopyAlert = true
    }
    
    private func shareContent() {
        let contentToShare = hashtag.tag_name_detail ?? ""
        let activityViewController = UIActivityViewController(
            activityItems: [contentToShare],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popoverController = activityViewController.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                popoverController.sourceView = rootViewController.view
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        // Present the activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            
            topViewController.present(activityViewController, animated: true)
        }
    }
}
struct HashTagCollectionCardShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title shimmer
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.1))
                .frame(height: 24)
                .frame(width: UIScreen.main.bounds.width * 0.4)
                .shimmering()
            
            // Subtitle shimmer (3 lines)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 16)
                    .shimmering()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 16)
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .shimmering()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 16)
                    .frame(width: UIScreen.main.bounds.width * 0.6)
                    .shimmering()
            }
            
            // Buttons shimmer
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 94, height: 48)
                    .shimmering()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 94, height: 48)
                    .shimmering()
                
                Spacer()
            }
            .padding(.top, 4)
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
    }
}
