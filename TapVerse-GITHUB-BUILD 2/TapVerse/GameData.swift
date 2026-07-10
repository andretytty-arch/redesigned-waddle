import Foundation

enum GameData {
    static let upgrades: [UpgradeDefinition] = [
        .init(id: "tapPower", title: "Сила касания", subtitle: "+45% монет за клик", icon: "hand.tap.fill", category: .tap, baseCost: 25, growth: 1.55),
        .init(id: "critical", title: "Критический шанс", subtitle: "+1.5% шанс x10", icon: "bolt.fill", category: .tap, baseCost: 180, growth: 1.72),
        .init(id: "combo", title: "Комбо-движок", subtitle: "Комбо дольше и сильнее", icon: "flame.fill", category: .tap, baseCost: 350, growth: 1.68),
        .init(id: "autoMiner", title: "Авто-майнер", subtitle: "+1.2 монеты в секунду", icon: "gearshape.2.fill", category: .automation, baseCost: 80, growth: 1.58),
        .init(id: "drone", title: "Дрон-кликер", subtitle: "+12% к авто-доходу", icon: "paperplane.fill", category: .automation, baseCost: 600, growth: 1.66),
        .init(id: "offline", title: "Офлайн-хранилище", subtitle: "+1 час офлайн-дохода", icon: "moon.stars.fill", category: .automation, baseCost: 900, growth: 1.78),
        .init(id: "fever", title: "Режим перегрева", subtitle: "Дольше работает множитель x5", icon: "sparkles", category: .boost, baseCost: 1_200, growth: 1.8),
        .init(id: "prestige", title: "Звёздный резонанс", subtitle: "+5% к бонусу престижа", icon: "star.fill", category: .boost, baseCost: 4_000, growth: 2.1)
    ]

    static let missions: [MissionDefinition] = [
        .init(id: "daily_taps", title: "Сделай 150 кликов", icon: "hand.tap", metric: .taps, target: 150, rewardGems: 12),
        .init(id: "daily_earn", title: "Заработай 5K монет", icon: "circle.hexagongrid.fill", metric: .earned, target: 5_000, rewardGems: 18),
        .init(id: "daily_upgrade", title: "Купи 4 улучшения", icon: "arrow.up.circle.fill", metric: .upgrades, target: 4, rewardGems: 15),
        .init(id: "daily_combo", title: "Достигни комбо x30", icon: "flame.fill", metric: .combo, target: 30, rewardGems: 20)
    ]

    static let achievements: [AchievementDefinition] = [
        .init(id: "tap_1k", title: "Пальцы-молнии", subtitle: "1 000 нажатий", icon: "hand.tap.fill", metric: .lifetimeTaps, target: 1_000, rewardGems: 35),
        .init(id: "tap_25k", title: "Машина кликов", subtitle: "25 000 нажатий", icon: "bolt.circle.fill", metric: .lifetimeTaps, target: 25_000, rewardGems: 120),
        .init(id: "coin_1m", title: "Первый миллион", subtitle: "Заработать 1M монет", icon: "banknote.fill", metric: .lifetimeCoins, target: 1_000_000, rewardGems: 100),
        .init(id: "combo_100", title: "Без остановки", subtitle: "Комбо x100", icon: "flame.circle.fill", metric: .maxCombo, target: 100, rewardGems: 80),
        .init(id: "prestige_3", title: "Новая галактика", subtitle: "3 перезапуска престижа", icon: "star.circle.fill", metric: .prestige, target: 3, rewardGems: 160)
    ]
}
