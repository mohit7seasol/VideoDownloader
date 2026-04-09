//
//  BookMarkHistoryView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 09/04/26.
//

import SwiftUI

struct BookMarkHistoryView: View {
    @ObservedObject var viewModel: LinkViewModel
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @State private var showDeleteAllAlert = false
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Line Separator Image at top with height 0 (as requested)
            Image("history_line_ic")
                .resizable()
                .frame(height: 0)
                .hidden() // Hidden but maintains the reference
            
            // Title Section
            HStack {
                Text("Bookmark History")
                    .font(Font.custom("Poppins-Black.ttf", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Delete All Button (only show if there are bookmarks)
                if !viewModel.failedURLs.isEmpty {
                    Button(action: {
                        showDeleteAllAlert = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            Text("Clear All")
                                .font(Font.custom("Urbanist-Medium", size: 14))
                        }
                        .foregroundColor(.red.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Bookmark List
            if viewModel.failedURLs.isEmpty {
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: isIpad ? 60 : 50))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No bookmarks yet")
                        .font(Font.custom("Urbanist-Medium", size: isIpad ? 18 : 16))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Failed downloads will appear here")
                        .font(Font.custom("Urbanist-Regular", size: isIpad ? 16 : 14))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                .padding(.bottom, 60)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.failedURLs, id: \.self) { url in
                            BookMarkHistoryCardView(url: url) {
                                withAnimation {
                                    viewModel.removeFailedURL(url)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.clear)
        .alert("Clear All Bookmarks?", isPresented: $showDeleteAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                withAnimation {
                    viewModel.failedURLs.removeAll()
                    UserDefaults.standard.removeObject(forKey: "FailedVideoURLs")
                }
            }
        } message: {
            Text("This will remove all your saved bookmark URLs. This action cannot be undone.")
        }
    }
}

#Preview {
    let viewModel = LinkViewModel()
    viewModel.failedURLs = [
        "https://www.instagram.com/p/Cxample123456789",
        "https://www.youtube.com/watch?v=example123456",
        "https://www.tiktok.com/@user/video/123456789"
    ]
    
    return ZStack {
        Color.black.ignoresSafeArea()
        BookMarkHistoryView(viewModel: viewModel)
    }
}
