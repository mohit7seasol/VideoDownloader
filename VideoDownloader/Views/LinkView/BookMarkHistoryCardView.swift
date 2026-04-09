//
//  BookMarkHistoryCardView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 09/04/26.
//

import SwiftUI
import SafariServices

struct BookMarkHistoryCardView: View {
    let url: String
    let onDelete: () -> Void
    @State private var isPressed = false
    @State private var showSafari = false
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Bookmark Icon on left
            Image(systemName: "bookmark.fill")
                .font(.system(size: isIpad ? 22 : 18))
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 16)
            
            // URL Label with marquee effect (horizontal scrolling)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Text(url)
                        .font(Font.custom("Urbanist-Regular", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Add spacing for smooth scrolling
                    Spacer(minLength: 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Delete Button on right
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDelete()
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: isIpad ? 18 : 16))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.trailing, 16)
            }
        }
        .frame(height: isIpad ? 80 : 60)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#541834"),
                    Color(hex: "#302555")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            // Open URL in browser
            openURLInBrowser()
        }
    }
    
    // Function to open URL in browser
    private func openURLInBrowser() {
        guard let validURL = URL(string: url) else { return }
        
        // Check if URL has http/https scheme, if not add https
        var urlToOpen = validURL
        if urlToOpen.scheme == nil {
            urlToOpen = URL(string: "https://\(url)") ?? validURL
        }
        
        // Open in Safari
        UIApplication.shared.open(urlToOpen) { success in
            if !success {
                print("Failed to open URL: \(url)")
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        BookMarkHistoryCardView(url: "https://www.instagram.com/p/Cxample123456789") {
            print("Delete tapped")
        }
        BookMarkHistoryCardView(url: "https://www.youtube.com/watch?v=example123456") {
            print("Delete tapped")
        }
        BookMarkHistoryCardView(url: "https://www.tiktok.com/@user/video/123456789") {
            print("Delete tapped")
        }
    }
    .padding()
    .background(Color.black)
}
