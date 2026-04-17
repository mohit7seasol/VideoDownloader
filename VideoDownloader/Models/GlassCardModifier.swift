//
//  GlassCardModifier.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 17/04/26.
//

import Foundation
import SwiftUI

struct GlassCardModifier: ViewModifier {
    
    var cornerRadius: CGFloat = 30
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(.white.opacity(0.1))
                .cornerRadius(cornerRadius)
                .glassEffect(
                    .clear.interactive(),
                    in: RoundedRectangle(cornerRadius: cornerRadius)
                )
        } else {
            content
                .background(Blur())
                .background(Color.white.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
