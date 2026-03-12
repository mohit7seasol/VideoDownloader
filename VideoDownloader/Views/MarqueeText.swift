//
//  MarqueeText.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 12/03/26.
//

import SwiftUI

struct MarqueeText: View {
    
    let text: String
    var font: Font
    
    @State private var animate = false
    
    var body: some View {
        
        GeometryReader { geo in
            
            let width = geo.size.width
            
            Text(text)
                .font(font)
                .foregroundColor(.white)
                .lineLimit(1)
                .offset(x: animate ? -width : width)
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 6)
                            .repeatForever(autoreverses: false)
                    ) {
                        animate = true
                    }
                }
        }
        .clipped()
    }
}
