import Foundation
import SwiftUI

extension Date {
    func formattedAs(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

