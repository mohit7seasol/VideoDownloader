import Foundation

extension Array {
    var isNotEmpty : Bool {
        !isEmpty
    }
}


extension Array where Element == Int {
    func toCommaSeparatedString() -> String {
        self.map { String($0) }.joined(separator: ",")
    }
}

// MARK: - Safe Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
