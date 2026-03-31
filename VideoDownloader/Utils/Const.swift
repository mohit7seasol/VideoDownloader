//
//  Const.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 09/03/26.
//

import Foundation
import SwiftUI

/**
 Account :  Carter Reel
 App name : Clipfusion
 Bundle id : com.clip.fusion
 appid : 6761417669
 JSONURL : https://7seasol-application.s3.amazonaws.com/admin_prod/pbz-pyvc-shfvba.json
 privacy policy : https://carterreelssprt.blogspot.com/2025/11/privacypolicy.html
 TERMS & CONDITIONS : https://carterreelssprt.blogspot.com/2025/11/term.html
 Eula : https://carterreelssprt.blogspot.com/2025/11/eula.html
 */

var appName             = "Clipfusion"
let privacyPolicy       = "https://carterreelssprt.blogspot.com/2025/11/privacypolicy.html"
let termsOfUse          = "https://carterreelssprt.blogspot.com/2025/11/term.html"
let eula                = "https://carterreelssprt.blogspot.com/2025/11/eula.html"
let REVIEW_LINK         = "https://itunes.apple.com/in/app/id\(APP_ID)?mt=8"
let shareApp            = "https://apps.apple.com/app/id\(APP_ID)"
var APP_ID              = "6761417669"
var myMail              = "kishanlakkad999@gmail.com"


//MARK: - live json
let getJSON : String = "https://7seasol-application.s3.amazonaws.com/admin_prod/pbz-pyvc-shfvba.json"

//MARK: - test json
//let getJSON : String = "https://7seasol-application.s3.amazonaws.com/admin_prod/grfg.json"


public let ACCESS = "AKIA2FCATE7MLGSZBHML"
public let SECRET = "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"


struct WebService {
    static let apiPrefixUrl: String = "api-pexels.7seasol.in/api/images/by-category?category="
    
    static let categories: [String] = [
        "coolwallpaper",
        "landscape",
        "forests",
        "garden",
        "hills",
        "wildlife",
        "beaches",
        "birds",
        "lord",
        "clouds",
        "architecture",
        "bikes",
        "minimalist",
        "galaxy",
        "planets",
        "magic",
        "cartoons",
        "romance",
        "esports",
        "digitalart",
        "festival",
        "cute",
        "rain",
        "plant",
        "wallpaper3d",
        "wallpaper4k",
        "wallpaper8k",
        "wallpaper32k",
        "livewallpaper",
        "trending"
    ]
}


import UIKit

struct Device {
    static var topSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
    }
    
    static var bottomSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.bottom ?? 0
    }
    
    private static var nativeScale: CGFloat {
        UIScreen.main.nativeScale
    }
    
    static var portraitWidth: CGFloat {
        let screen = UIScreen.main
        return screen.nativeBounds.width / nativeScale
    }
    
    static var portraitHeight: CGFloat {
        let screen = UIScreen.main
        return screen.nativeBounds.height / nativeScale
    }
    
    static var width: CGFloat {
        currentSize.width
    }
    
    static var height: CGFloat {
        currentSize.height
    }
    
    static var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isPortrait: Bool {
        let orientation = UIDevice.current.orientation
        return orientation == .portrait || orientation == .portraitUpsideDown
    }
    
    static var isLandscape: Bool {
        let orientation = UIDevice.current.orientation
        return orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    static var currentSize: CGSize {
        let portraitW = portraitWidth
        let portraitH = portraitHeight
        let isLandscape = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        if isIpad && isLandscape {
            return CGSize(width: portraitH, height: portraitW)
        } else {
            return CGSize(width: portraitW, height: portraitH)
        }
    }
}

struct SessionKeys {
    static var language = "language"
    static var isLanguageDone = "isLanguageDone"
    static var isOnboardingDone = "isOnboardingDone"
    static var interAdId = "interAdId"
    static var afterClick = "afterClick"
    static var isRated = "isRated"
    static var isHomeScreenLoaded = "isHomeScreenLoaded"
    static var isPro = "isPro"
    static var isProViewOpen = "isProViewOpen"
    static var isUserGoneBackGround = "isUserGoneBackGround"
    static var isOneTimeDone = "isOneTimeDone"
}

struct Constant {
    static var commonBlueGradient = LinearGradient(colors: [Color.gradientOne, Color.gradientTwo], startPoint: .top, endPoint: .bottom)
    static var previewBlueGradient = LinearGradient(colors: [Color.gradientThree, Color.gradientFour], startPoint: .topLeading, endPoint: .bottomTrailing)
}


extension View {
    func addBackGround() -> some View {
        modifier(BackgroundModifier())
    }
}

struct BackgroundModifier: ViewModifier {
    @StateObject private var orientationObserver = OrientationObserver()
    
    private var portraitSize: CGSize {
        CGSize(width: Device.portraitWidth, height: Device.portraitHeight)
    }
    
    private var currentSize: CGSize {
        let orientation = orientationObserver.orientation
        let isLandscape = orientation == .landscapeLeft || orientation == .landscapeRight
        if Device.isIpad && isLandscape {
            return CGSize(width: portraitSize.height, height: portraitSize.width)
        } else {
            return portraitSize
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                Image.appBg
                    .resizeFillTo(width: currentSize.width, height: currentSize.height)
                    .ignoresSafeArea()
            )
            .onChange(of: orientationObserver.orientation) { newValue in
                print("🔄 Orientation changed: \(newValue.rawValue)")
                print("📏 New size: \(currentSize.width)x\(currentSize.height)")
            }
            .animation(.easeInOut(duration: 0.3), value: orientationObserver.orientation)
    }
}

import SwiftUI
import Combine

final class OrientationObserver: ObservableObject {
    @Published var orientation = UIDevice.current.orientation {
        didSet {
            switch orientation {
            case .portrait:
                print("📱 Orientation: Portrait")
            case .portraitUpsideDown:
                print("📱 Orientation: Portrait Upside Down")
            case .landscapeLeft, .landscapeRight:
                print("📺 Orientation: Landscape")
            default:
                print("🤷 Orientation: Unknown (\(orientation.rawValue))")
            }
        }
    }
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { _ in UIDevice.current.orientation }
            .filter { $0 != .faceUp && $0 != .faceDown && $0 != .unknown }
            .receive(on: RunLoop.main)
            .assign(to: \.orientation, on: self)
    }
}


//struct Device {
//    static var topSafeArea: CGFloat {
//        UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .flatMap { $0.windows }
//            .first { $0.isKeyWindow }?
//            .safeAreaInsets.top ?? 0
//    }
//
//    static var bottomSafeArea: CGFloat {
//        UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .flatMap { $0.windows }
//            .first { $0.isKeyWindow }?
//            .safeAreaInsets.bottom ?? 0
//    }
//
//    static var width: CGFloat {
//        UIScreen.main.bounds.width
//    }
//
//    static var height: CGFloat {
//        UIScreen.main.bounds.height
//    }
//
//    static var isIpad: Bool {
//        UIDevice.current.userInterfaceIdiom == .pad
//    }
//
//    static var isPortrait: Bool {
//        return UIScreen.main.bounds.height >= UIScreen.main.bounds.width
//    }
//
//    static var isLandscape: Bool {
//        return !isPortrait
//    }
//}
