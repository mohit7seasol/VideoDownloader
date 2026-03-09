import Foundation
import SwiftUI

extension Text {
    
    func katibehRegular(_ size : CGFloat = 16) -> some View {
        return self.font(.custom("Katibeh-Regular", size: size))
    }
    
    func tienneBold(_ size : CGFloat = 16) -> some View {
        return self.font(.custom("Tienne-Bold", size: size))
    }
    
    func systemBlack(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .black))
    }
    func systemBold(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .bold))
    }
    func systemLight(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .light))
    }
    func systemMedium(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .medium))
    }
    func systemRegular(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .regular))
    }
    func systemThin(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .thin))
    }
    func systemExtraLight(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .ultraLight))
    }
    func systemSemiBold(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .semibold))
    }
    
}


extension View {
    
    func katibehRegular(_ size : CGFloat = 16) -> some View {
        return self.font(.custom("Katibeh-Regular", size: size))
    }
    
    func tienneBold(_ size : CGFloat = 16) -> some View {
        return self.font(.custom("Tienne-Bold", size: size))
    }
    
    func systemBlack(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .black))
    }
    func systemBold(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .bold))
    }
    func systemLight(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .light))
    }
    func systemMedium(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .medium))
    }
    func systemRegular(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .regular))
    }
    func systemThin(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .thin))
    }
    func systemExtraLight(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .ultraLight))
    }
    func systemSemiBold(_ size : CGFloat = 16) -> some View {
        return self.font(.system(size: size, weight: .semibold))
    }
    
}

