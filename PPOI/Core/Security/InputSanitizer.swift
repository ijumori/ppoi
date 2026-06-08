import Foundation

enum InputSanitizer {
    static let maxReflectionLength = 500

    /// 入力中の制限（制御文字除去 + 長さ制限のみ、trimはしない）
    static func limitReflection(_ input: String) -> String {
        let normalized = input.precomposedStringWithCanonicalMapping
        let filtered = normalized.unicodeScalars.filter { scalar in
            if scalar.value == 0x0A || scalar.value == 0x0D { return true }
            return !CharacterSet.controlCharacters.contains(scalar)
        }
        let cleaned = String(String.UnicodeScalarView(filtered))
        if cleaned.count <= maxReflectionLength { return cleaned }
        return String(cleaned.prefix(maxReflectionLength))
    }

    /// 送信時の完全サニタイズ（trim + 制御文字除去 + 長さ制限）
    static func sanitizeReflection(_ input: String) -> String {
        limitReflection(input).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
