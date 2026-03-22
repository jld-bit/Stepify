import SwiftUI

enum GoalPalette: String, CaseIterable, Identifiable {
    case sunrise
    case nebula
    case electric

    var id: String { rawValue }

    var colors: [Color] {
        switch self {
        case .sunrise:
            return [Color(hex: 0xFF8A00), Color(hex: 0xFF4D6D), Color(hex: 0x8B5CF6)]
        case .nebula:
            return [Color(hex: 0x7C3AED), Color(hex: 0x2563EB), Color(hex: 0x38BDF8)]
        case .electric:
            return [Color(hex: 0xF97316), Color(hex: 0xA855F7), Color(hex: 0x0EA5E9)]
        }
    }

    var title: String {
        switch self {
        case .sunrise: "Sunrise Boost"
        case .nebula: "Nebula Flow"
        case .electric: "Electric Lift"
        }
    }
}

extension Color {
    init(hex: UInt64, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
