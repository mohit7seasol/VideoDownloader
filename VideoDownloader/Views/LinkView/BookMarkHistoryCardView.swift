//
//  BookMarkHistoryCardView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 09/04/26.
//

import SwiftUI

struct BookMarkHistoryCardView: View {
    let url: String
    let onDelete: () -> Void
    @State private var isPressed = false
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Link Icon
            Image(systemName: "bookmark.fill")
                .font(.system(size: isIpad ? 24 : 20))
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 16)
            
            // URL Label with marquee effect
            ScrollView(.horizontal, showsIndicators: false) {
                Text(url)
                    .font(Font.custom("Urbanist-Regular", size: 16))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Delete Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDelete()
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: isIpad ? 20 : 16))
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
            // Copy URL to clipboard
            UIPasteboard.general.string = url
            // You can add a toast notification here if needed
        }
    }
}

#Preview {
    VStack {
        BookMarkHistoryCardView(url: "https://www.instagram.com/p/example123") {
            print("Delete tapped")
        }
        BookMarkHistoryCardView(url: "https://www.youtube.com/watch?v=example456") {
            print("Delete tapped")
        }
    }
    .padding()
    .background(Color.black)
}
