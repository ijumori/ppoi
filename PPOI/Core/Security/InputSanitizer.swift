import Foundation

enum InputSanitizer {
    static let maxReflectionLength = 500

    /// 共有テキスト用: 制御文字除去・長さ制限・Unicode 正規化
    static func sanitizeReflection(_ input: String) -> String {
        let normalized = input.precomposedStringWithCanonicalMapping
        let filtered = normalized.unicodeScalars.filter { scalar in
            if scalar.value == 0x0A || scalar.value == 0x0D { return true }
            return !CharacterSet.controlCharacters.contains(scalar)
        }
        let cleaned = String(String.UnicodeScalarView(filtered))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.count <= maxReflectionLength { return cleaned }
        return String(cleaned.prefix(maxReflectionLength))
    }
}
