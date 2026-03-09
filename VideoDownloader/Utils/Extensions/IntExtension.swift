import Foundation

extension Int {
    func asClockFormat() -> String {
            let hours = self / 3600
            let minutes = (self % 3600) / 60
            let seconds = self % 60

            if hours > 0 {
                return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        }
    
    func asReadableTime() -> String {
            let hours = self / 3600
            let minutes = (self % 3600) / 60
            let seconds = self % 60

            var components: [String] = []

            if hours > 0 {
                components.append("\(hours) hr")
            }
            if minutes > 0 {
                components.append("\(minutes) min")
            }
            if seconds > 0 || components.isEmpty {
                components.append("\(seconds) sec")
            }

            return components.joined(separator: " ")
        }
}


extension Double {
    /// Returns a string with fixed number of decimal places
    func formatted(_ decimals: Int = 1) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}

import Foundation

extension Int {
    /// Formats the integer using the US-style grouping (e.g., 1,234,567)
    var formattedWithCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
