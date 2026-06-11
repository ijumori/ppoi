import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case minimal
    case pop
    case darkPremium
    case zenGold
    // Premium-only themes
    case midnight
    case sakura

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .minimal: "和風ミニマル"
        case .pop: "モダン・ポップ"
        case .darkPremium: "ダーク・プレミア"
        case .zenGold: "禅・ゴールド"
        case .midnight: "ミッドナイト・ブルー"
        case .sakura: "桜・ブロッサム"
        }
    }

    /// ストリーク報酬で解放されるテーマ
    var isStreakReward: Bool {
        self == .zenGold
    }

    /// プレミアム購入で解放されるテーマ
    var isPremiumOnly: Bool {
        self == .midnight || self == .sakura
    }

    var colors: ThemeColors {
        switch self {
        case .minimal:
            ThemeColors(
                background: Color(hex: 0xFFFFFF),
                primaryText: Color(hex: 0x1A1A1A),
                accent: Color(hex: 0x666666),
                button: Color(hex: 0x333333),
                gradient: nil
            )
        case .pop:
            ThemeColors(
                background: Color(hex: 0xFFF5F0),
                primaryText: Color(hex: 0x2D2D2D),
                accent: Color(hex: 0xFF6B6B),
                button: Color(hex: 0xFF6B6B),
                gradient: LinearGradient(
                    colors: [Color(hex: 0xFFF5F0), Color(hex: 0xF0FFF4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .darkPremium:
            ThemeColors(
                background: Color(hex: 0x0A0A0A),
                primaryText: Color(hex: 0xF5F0E8),
                accent: Color(hex: 0xC9A962),
                button: Color(hex: 0xC9A962),
                gradient: nil
            )
        case .zenGold:
            ThemeColors(
                background: Color(hex: 0x1A1520),
                primaryText: Color(hex: 0xF0E6D2),
                accent: Color(hex: 0xD4AF37),
                button: Color(hex: 0xD4AF37),
                gradient: LinearGradient(
                    colors: [Color(hex: 0x1A1520), Color(hex: 0x2D1B3D)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .midnight:
            ThemeColors(
                background: Color(hex: 0x0D1B2A),
                primaryText: Color(hex: 0xE0E1DD),
                accent: Color(hex: 0x778DA9),
                button: Color(hex: 0x415A77),
                gradient: LinearGradient(
                    colors: [Color(hex: 0x0D1B2A), Color(hex: 0x1B2838)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .sakura:
            ThemeColors(
                background: Color(hex: 0xFFF0F5),
                primaryText: Color(hex: 0x3D2B3D),
                accent: Color(hex: 0xD4739D),
                button: Color(hex: 0xC75B8F),
                gradient: LinearGradient(
                    colors: [Color(hex: 0xFFF0F5), Color(hex: 0xFFE4EE)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct ThemeColors {
    let background: Color
    let primaryText: Color
    let accent: Color
    let button: Color
    let gradient: LinearGradient?
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
