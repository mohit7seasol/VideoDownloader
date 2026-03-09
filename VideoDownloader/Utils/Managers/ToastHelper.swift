//
//  ToastHelper.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 09/03/26.
//

import Foundation
import SwiftUI
import Toasts

enum ToastIconType {
    case success
    case warning
    case error
    
    var icon: Image {
        switch self {
        case .success:
            return Image(systemName: "checkmark.circle.fill")
        case .warning:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .error:
            return Image(systemName: "xmark.octagon.fill")
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .warning: return .yellow
        case .error:   return .red
        }
    }
}

struct ToastHelper {
    @MainActor
    static func show(_ message: String,
                     type: ToastIconType? = nil,
                     button: ToastButton? = nil,
                     using present: PresentToastAction) {
        
        let toast: ToastValue
        if let type = type {
            toast = ToastValue(
                icon: type.icon.foregroundColor(type.color),
                message: message,
                button: button
            )
        } else {
            toast = ToastValue(message: message, button: button)
        }
        
        present(toast) // ✅ now allowed
    }
}

