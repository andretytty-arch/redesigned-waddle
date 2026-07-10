import Foundation
import SwiftUI

enum UpgradeCategory: String, CaseIterable, Codable, Identifiable {
    case tap
    case automation
    case boost

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tap: "Клик"
        case .automation: "Авто"
        case .boost: "Бусты"
        }
    }
}

struct UpgradeDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let category: UpgradeCategory
    let baseCost: Double
    let growth: Double
}

struct MissionDefinition: Identifiable, Hashable {
    enum Metric: Hashable {
        case taps
        case earned
        case upgrades
        case combo
    }

    let id: String
    let title: String
    let icon: String
    let metric: Metric
    let target: Double
    let rewardGems: Int
}

struct AchievementDefinition: Identifiable, Hashable {
    enum Metric: Hashable {
        case lifetimeTaps
        case lifetimeCoins
        case prestige
        case maxCombo
    }

    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let metric: Metric
    let target: Double
    let rewardGems: Int
}

struct FloatingGain: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isCritical: Bool
    let xOffset: CGFloat
}

struct LeaderboardEntry: Identifiable, Hashable {
    let id = UUID()
    let rank: Int
    let name: String
    let score: Double
    let isCurrentUser: Bool
}

enum AppThemeChoice: String, CaseIterable, Codable, Identifiable {
    case cosmic
    case sunset
    case mint
    case royal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cosmic: "Космос"
        case .sunset: "Закат"
        case .mint: "Мята"
        case .royal: "Royal"
        }
    }

    var icon: String {
        switch self {
        case .cosmic: "sparkles"
        case .sunset: "sun.max.fill"
        case .mint: "leaf.fill"
        case .royal: "crown.fill"
        }
    }

    var unlockCost: Int {
        switch self {
        case .cosmic: 0
        case .sunset: 120
        case .mint: 180
        case .royal: 300
        }
    }

    var colors: [Color] {
        switch self {
        case .cosmic:
            [Color(hex: 0x17132F), Color(hex: 0x4D2D8D), Color(hex: 0xBC4DFF)]
        case .sunset:
            [Color(hex: 0x3B163B), Color(hex: 0xC43B65), Color(hex: 0xFF9B54)]
        case .mint:
            [Color(hex: 0x073B3A), Color(hex: 0x0E7C7B), Color(hex: 0x7AE7C7)]
        case .royal:
            [Color(hex: 0x101B3F), Color(hex: 0x284F9E), Color(hex: 0xE2B857)]
        }
    }
}

enum GameSheet: String, Identifiable {
    case offlineReward
    case dailyReward
    case prestige

    var id: String { rawValue }
}

struct GameState: Codable {
    var coins: Double = 0
    var gems: Int = 35
    var lifetimeCoins: Double = 0
    var lifetimeTaps: Int = 0
    var maxCombo: Int = 0
    var prestigeStars: Int = 0
    var upgradeLevels: [String: Int] = [:]

    var dailyTaps: Int = 0
    var dailyEarned: Double = 0
    var dailyUpgrades: Int = 0
    var dailyBestCombo: Int = 0
    var dailyKey: String = ""
    var claimedMissionIDs: Set<String> = []
    var claimedAchievementIDs: Set<String> = []

    var streakDays: Int = 0
    var lastDailyClaim: Date?
    var lastSavedAt: Date = .now

    var selectedThemeRaw: String = AppThemeChoice.cosmic.rawValue
    var unlockedThemeRaws: Set<String> = [AppThemeChoice.cosmic.rawValue]

    var hapticsEnabled = true
    var notificationsEnabled = false
    var referralCode: String = String(UUID().uuidString.prefix(6)).uppercased()

    var selectedTheme: AppThemeChoice {
        get { AppThemeChoice(rawValue: selectedThemeRaw) ?? .cosmic }
        set { selectedThemeRaw = newValue.rawValue }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension Double {
    var compactGameNumber: String {
        let absolute = abs(self)
        let suffixes: [(Double, String)] = [
            (1_000_000_000_000, "T"),
            (1_000_000_000, "B"),
            (1_000_000, "M"),
            (1_000, "K")
        ]

        for (value, suffix) in suffixes where absolute >= value {
            return String(format: absolute >= value * 100 ? "%.0f%@" : "%.1f%@", self / value, suffix)
        }
        return String(format: absolute >= 100 ? "%.0f" : "%.1f", self)
    }
}
