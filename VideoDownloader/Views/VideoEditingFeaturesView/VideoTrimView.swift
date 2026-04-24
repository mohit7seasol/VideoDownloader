//
//  VideoTrimView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 24/04/26.
//

import SwiftUI

struct VideoTrimView: View {
    let videoAsset: VideoAsset
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Trim Video")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Coming Soon")
                    .foregroundColor(.gray)
                Button("Back") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
    }
}
