//
//  TabBarView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI
import Lottie

struct TabBarView: View {
    
    @State private var selectedIndex: Int = 1
    
    var body: some View {
        ZStack {
            
            // MARK: Screens
            Group {
                switch selectedIndex {
                case 0:
                    HomeView()
                case 1:
                    LinkView()
                case 2:
                    SavedVideoView()
                default:
                    LinkView()
                }
            }
            
            VStack {
                Spacer()
                CustomTabBar(selectedIndex: $selectedIndex)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Custom Tabbar
struct CustomTabBar: View {
    
    @Binding var selectedIndex: Int
    
    var body: some View {
        
        ZStack {
            
            // Background
            TabBarCurve()
                .fill(
                    LinearGradient(
                        colors: [
                            Color("TabbarGradient1"),
                            Color("TabbarGradient2")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 95)
                .ignoresSafeArea()
            
            // Left + Right Tabs
            HStack {
                
                // Home
                Button {
                    selectedIndex = 0
                } label: {
                    VStack(spacing: 4) {
                        
                        Image(selectedIndex == 0 ? "home_selected" : "home_unselected")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22,height: 22)
                        
                        Text("Home")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Save
                Button {
                    selectedIndex = 2
                } label: {
                    VStack(spacing: 4) {
                        
                        Image(selectedIndex == 2 ? "save_selected" : "save_unselected")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22,height: 22)
                        
                        Text("Save")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 60)
            .padding(.bottom, 20)   // ⬅️ pushes icons down like design
            .frame(height: 95)
            
            
            // Center Button
            Button {
                selectedIndex = 1
            } label: {
                
                ZStack {
                    
                    Image("link_bg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())     // makes it perfectly circular
                        .shadow(radius: 6)
                    
                    LottieView(name: "Link")
                        .frame(width: 40, height: 40)
                }
            }
            .offset(y: -42)
        }
    }
}
struct TabBarCurve: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        let center = rect.width / 2
        
        return Path { path in
            
            path.move(to: CGPoint(x: 0, y: 0))
            
            path.addLine(to: CGPoint(x: center - 80, y: 0))
            
            path.addCurve(
                to: CGPoint(x: center, y: 45),
                control1: CGPoint(x: center - 40, y: 0),
                control2: CGPoint(x: center - 35, y: 45)
            )
            
            path.addCurve(
                to: CGPoint(x: center + 80, y: 0),
                control1: CGPoint(x: center + 35, y: 45),
                control2: CGPoint(x: center + 40, y: 0)
            )
            
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}
// MARK: - Tabbar Shape
struct CustomTabShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        
        path.addLine(to: CGPoint(x: rect.width * 0.35, y: 0))
        
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.65, y: 0),
            control: CGPoint(x: rect.width * 0.5, y: -40)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Lottie View
struct LottieView: UIViewRepresentable {
    
    var name: String
    
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = .loop
        animationView.play()
        animationView.contentMode = .scaleAspectFit
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    TabBarView()
}
