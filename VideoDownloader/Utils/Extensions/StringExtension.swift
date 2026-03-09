import Foundation

extension String {
    func toIntArray(separator: Character = ",") -> [Int] {
        self.split(separator: separator)
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    }

    func toStringArray(separator: Character = ",") -> [String] {
        self.split(separator: separator)
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }
}


