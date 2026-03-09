import Foundation
import SDWebImage
import SwiftUI


extension View {
    
    func customCornerRadius(radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
    
    func maxWidth(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func maxFrame(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity,alignment: alignment)
    }
    
    @ViewBuilder
    func hideNavigationbar() -> some View {
        if #available(iOS 16, *) {
            self.toolbar(.hidden, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
        } else {
            self.navigationBarHidden(true)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func onTap(completion: @escaping ()->()) -> some View {
        Button(action: {
            BaseViewModel.shared.haptic()
            completion()
        }, label: {
            self
                .contentShape(Rectangle())
        })
        .buttonStyle(MyButtonStyle())
    }
    func withLinearGradientOverlay(
        colors: [Color] = [Color.black.opacity(0.0), Color.black.opacity(0.6)],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) -> some View {
        self
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
    }
    
    @ViewBuilder
    func swipeAction(editCompletion: @escaping ()->(),deleteCompletion: @escaping ()->()) -> some View {
        if #available(iOS 15, *) {
            self.swipeActions(edge: .trailing){
                Button(action: editCompletion, label: {
                    VStack {
                        Image(systemName: "square.and.pencil")
                        Text("Edit")
                    }
                })
                .tint(.green)
                
                Button(action: deleteCompletion, label: {
                    VStack {
                        Image(systemName: "trash.fill")
                        Text("Delete")
                    }
                })
                .tint(.red)
            }
        } else {
            self
        }
    }
    
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
    
    func dashedBorder<S: Shape>(
        _ shape: S,
        color: Color = .black,
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [6],
        dashPhase: CGFloat = 0
    ) -> some View {
        overlay(
            shape
                .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                           dash: dash,
                                           dashPhase: dashPhase))
                .foregroundColor(color)
        )
    }
}


struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}


extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


extension Date {
    func toString( dateFormat format  : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}



extension View {
    func addBgToAlbumImage() -> some View {
        self.clipShape(Circle())
            .padding(3)
            .background(Color.gray)
            .clipShape(Circle())
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(force)
    }
    func clearMemoryCache() {
        SDImageCache.shared.clearMemory()
    }
}

class Haptics {
    static let shared = Haptics()
    
    private init() { }
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}

extension View {
    @ViewBuilder
    func showLoader(isLoading: Bool) -> some View {
        ZStack {
            self
                .disabled(isLoading)
                .maxFrame()
                .background(Color.appTheme.opacity(0.5).ignoresSafeArea())
//                .blur(radius: isLoading ? 3 : 0)
            
            if isLoading {
                LoaderView()
            }
        }
        .maxFrame()
        .background(Color.appTheme.opacity(0.5).ignoresSafeArea())
        .animation(.default,value: isLoading)
    }
}

struct LoaderView : View {
    var body: some View {
        ZStack {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.yellow)
        }
    }
}

struct CustomCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


extension View {
    func innerShadow<S: Shape>(
        using shape: S,
        color: Color = .black,
        lineWidth: CGFloat = 4,
        blur: CGFloat = 4
    ) -> some View {
        self
            .overlay(
                shape
                    .stroke(color, lineWidth: lineWidth)
                    .blur(radius: blur)
                    .mask(shape)
            )
    }
}



extension View {
    
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .topTrailing,
                endPoint: .bottomLeading)
        )
        .mask(self)
    }
}


extension View {
    /// Applies a linear gradient fill to the view by masking it.
    func foregroundLinearGradient(
        _ gradient: LinearGradient
    ) -> some View {
        gradient.mask(self)
    }
}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
