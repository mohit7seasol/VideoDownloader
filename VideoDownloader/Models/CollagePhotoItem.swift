//
//  CollagePhotoItem.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 16/04/26.
//

import SwiftUI
import PhotosUI

// MARK: - Grid Types
enum GridType: String, CaseIterable {
    case single = "Single"
    case double = "Double"
    case grid2x2 = "2x2 Grid"
    case grid3x3 = "3x3 Grid"
    case oneTwo = "1+2"
    case twoOne = "2+1"
    
    var icon: String {
        switch self {
        case .single: return "square"
        case .double: return "rectangle.split.2x1"
        case .grid2x2: return "square.grid.2x2"
        case .grid3x3: return "square.grid.3x3"
        case .oneTwo: return "rectangle.split.1x2"
        case .twoOne: return "rectangle.split.2x1"
        }
    }
    
    var displayName: String {
        switch self {
        case .single: return "Single"
        case .double: return "Double"
        case .grid2x2: return "2x2"
        case .grid3x3: return "3x3"
        case .oneTwo: return "1+2"
        case .twoOne: return "2+1"
        }
    }
    
    var layout: [CGRect] {
        switch self {
        case .single:
            return [CGRect(x: 0, y: 0, width: 1, height: 1)]
        case .double:
            return [
                CGRect(x: 0, y: 0, width: 0.5, height: 1),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 1)
            ]
        case .grid2x2:
            return [
                CGRect(x: 0, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0, y: 0.5, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
            ]
        case .grid3x3:
            var layouts: [CGRect] = []
            for row in 0..<3 {
                for col in 0..<3 {
                    layouts.append(CGRect(x: CGFloat(col)/3, y: CGFloat(row)/3, width: 1/3, height: 1/3))
                }
            }
            return layouts
        case .oneTwo:
            return [
                CGRect(x: 0, y: 0, width: 0.5, height: 1),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
            ]
        case .twoOne:
            return [
                CGRect(x: 0, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0, y: 0.5, width: 1, height: 0.5)
            ]
        }
    }
}

// MARK: - Photo Item Model
struct CollagePhotoItem: Identifiable {
    let id = UUID()
    var image: UIImage?
    var isPlaceholder: Bool
    var frame: CGRect
}
