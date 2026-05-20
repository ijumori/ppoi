import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case minimal
    case pop
    case darkPremium

    var id: String { rawValue }

    var label: String {
        switch self {
        case .minimal: "和風ミニマル"
        case .pop: "モダン・ポップ"
        case .darkPremium: "ダーク・プレミア"
        }
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
