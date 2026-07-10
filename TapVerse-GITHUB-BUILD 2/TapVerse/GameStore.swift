import Foundation
import Observation

@MainActor
@Observable
final class GameStore {
    var state: GameState
    var combo = 0
    var feverCharge = 0.0
    var feverSecondsRemaining = 0.0
    var floatingGains: [FloatingGain] = []
    var presentedSheet: GameSheet?
    var pendingOfflineReward = 0.0
    var lastTapWasCritical = false

    private let persistence: PersistenceService
    private var gameLoopTask: Task<Void, Never>?
    private var lastTapAt: Date?
    private var lastTickAt = Date.now
    private var saveAccumulator = 0.0

    init(persistence: PersistenceService = PersistenceService()) {
        self.persistence = persistence
        self.state = persistence.load()
        normalizeDailyProgress()
        calculateOfflineReward()

        if pendingOfflineReward >= 1 {
            presentedSheet = .offlineReward
        } else if canClaimDailyReward {
            presentedSheet = .dailyReward
        }
    }

    deinit {
        gameLoopTask?.cancel()
    }

    var selectedTheme: AppThemeChoice { state.selectedTheme }

    var tapPower: Double {
        let tapLevel = level(for: "tapPower")
        let prestigeLevel = level(for: "prestige")
        let base = pow(1.45, Double(tapLevel))
        let starBonus = 1 + Double(state.prestigeStars) * (0.25 + Double(prestigeLevel) * 0.05)
        return base * starBonus
    }

    var autoPerSecond: Double {
        let minerLevel = level(for: "autoMiner")
        let droneLevel = level(for: "drone")
        let base = Double(minerLevel) * 1.2
        let droneMultiplier = 1 + Double(droneLevel) * 0.12
        let starMultiplier = 1 + Double(state.prestigeStars) * 0.2
        return base * droneMultiplier * starMultiplier
    }

    var criticalChance: Double {
        min(0.5, 0.03 + Double(level(for: "critical")) * 0.015)
    }

    var comboMultiplier: Double {
        let comboLevel = level(for: "combo")
        return 1 + Double(combo) * (0.018 + Double(comboLevel) * 0.0015)
    }

    var feverDuration: Double {
        8 + Double(level(for: "fever")) * 2
    }

    var offlineHours: Double {
        min(24, 4 + Double(level(for: "offline")))
    }

    var prestigeRequirement: Double {
        250_000 * pow(4, Double(state.prestigeStars))
    }

    var prestigeProgress: Double {
        min(1, state.lifetimeCoins / prestigeRequirement)
    }

    var canPrestige: Bool {
        state.lifetimeCoins >= prestigeRequirement
    }

    var canClaimDailyReward: Bool {
        guard let last = state.lastDailyClaim else { return true }
        return !Calendar.current.isDateInToday(last)
    }

    var dailyRewardAmount: Int {
        25 + min(state.streakDays + 1, 14) * 10
    }

    var squadGoalProgress: Double {
        let cycle = state.lifetimeCoins.truncatingRemainder(dividingBy: 2_000_000)
        return cycle / 2_000_000
    }

    var shareText: String {
        "Я строю империю в TAPVERSE 🚀 Мой код: \(state.referralCode). Побьёшь мой результат \(state.lifetimeCoins.compactGameNumber)?"
    }

    func start() {
        guard gameLoopTask == nil else { return }
        lastTickAt = .now
        gameLoopTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                self?.tick()
            }
        }
    }

    func stop() {
        gameLoopTask?.cancel()
        gameLoopTask = nil
        save()
    }

    func handleBecameActive() {
        normalizeDailyProgress()
        if pendingOfflineReward < 1 {
            calculateOfflineReward()
        }
        if pendingOfflineReward >= 1 {
            presentedSheet = .offlineReward
        } else if canClaimDailyReward {
            presentedSheet = .dailyReward
        }
        start()
    }

    func tap() {
        normalizeDailyProgress()

        let now = Date.now
        if let lastTapAt, now.timeIntervalSince(lastTapAt) <= comboGracePeriod {
            combo += 1
        } else {
            combo = 1
        }
        self.lastTapAt = now

        state.maxCombo = max(state.maxCombo, combo)
        state.dailyBestCombo = max(state.dailyBestCombo, combo)

        let isCritical = Double.random(in: 0...1) < criticalChance
        lastTapWasCritical = isCritical

        let criticalMultiplier = isCritical ? 10.0 : 1.0
        let feverMultiplier = feverSecondsRemaining > 0 ? 5.0 : 1.0
        let gain = tapPower * comboMultiplier * criticalMultiplier * feverMultiplier

        addCoins(gain)
        state.lifetimeTaps += 1
        state.dailyTaps += 1

        feverCharge += 1.7 + Double(level(for: "fever")) * 0.12
        if feverCharge >= 100 {
            feverCharge = 0
            feverSecondsRemaining = feverDuration
            Haptics.success(enabled: state.hapticsEnabled)
        } else {
            Haptics.tap(enabled: state.hapticsEnabled, critical: isCritical)
        }

        let gainItem = FloatingGain(
            text: "+\(gain.compactGameNumber)",
            isCritical: isCritical,
            xOffset: CGFloat.random(in: -80...80)
        )
        floatingGains.append(gainItem)
        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(750))
            self?.floatingGains.removeAll { $0.id == gainItem.id }
        }
    }

    func level(for upgradeID: String) -> Int {
        state.upgradeLevels[upgradeID, default: 0]
    }

    func cost(for upgrade: UpgradeDefinition) -> Double {
        upgrade.baseCost * pow(upgrade.growth, Double(level(for: upgrade.id)))
    }

    func canBuy(_ upgrade: UpgradeDefinition) -> Bool {
        state.coins >= cost(for: upgrade)
    }

    func buy(_ upgrade: UpgradeDefinition) {
        let price = cost(for: upgrade)
        guard state.coins >= price else { return }
        state.coins -= price
        state.upgradeLevels[upgrade.id, default: 0] += 1
        state.dailyUpgrades += 1
        Haptics.success(enabled: state.hapticsEnabled)
        save()
    }

    func missionProgress(_ mission: MissionDefinition) -> Double {
        let current: Double
        switch mission.metric {
        case .taps: current = Double(state.dailyTaps)
        case .earned: current = state.dailyEarned
        case .upgrades: current = Double(state.dailyUpgrades)
        case .combo: current = Double(state.dailyBestCombo)
        }
        return min(1, current / mission.target)
    }

    func missionCurrentValue(_ mission: MissionDefinition) -> Double {
        switch mission.metric {
        case .taps: Double(state.dailyTaps)
        case .earned: state.dailyEarned
        case .upgrades: Double(state.dailyUpgrades)
        case .combo: Double(state.dailyBestCombo)
        }
    }

    func canClaimMission(_ mission: MissionDefinition) -> Bool {
        missionProgress(mission) >= 1 && !state.claimedMissionIDs.contains(mission.id)
    }

    func claimMission(_ mission: MissionDefinition) {
        guard canClaimMission(mission) else { return }
        state.claimedMissionIDs.insert(mission.id)
        state.gems += mission.rewardGems
        Haptics.success(enabled: state.hapticsEnabled)
        save()
    }

    func achievementProgress(_ achievement: AchievementDefinition) -> Double {
        let current: Double
        switch achievement.metric {
        case .lifetimeTaps: current = Double(state.lifetimeTaps)
        case .lifetimeCoins: current = state.lifetimeCoins
        case .prestige: current = Double(state.prestigeStars)
        case .maxCombo: current = Double(state.maxCombo)
        }
        return min(1, current / achievement.target)
    }

    func canClaimAchievement(_ achievement: AchievementDefinition) -> Bool {
        achievementProgress(achievement) >= 1 && !state.claimedAchievementIDs.contains(achievement.id)
    }

    func claimAchievement(_ achievement: AchievementDefinition) {
        guard canClaimAchievement(achievement) else { return }
        state.claimedAchievementIDs.insert(achievement.id)
        state.gems += achievement.rewardGems
        Haptics.success(enabled: state.hapticsEnabled)
        save()
    }

    func claimOfflineReward() {
        guard pendingOfflineReward > 0 else {
            presentedSheet = canClaimDailyReward ? .dailyReward : nil
            return
        }
        addCoins(pendingOfflineReward)
        pendingOfflineReward = 0
        Haptics.success(enabled: state.hapticsEnabled)
        save()
        presentedSheet = canClaimDailyReward ? .dailyReward : nil
    }

    func claimDailyReward() {
        let reward = dailyRewardAmount
        let calendar = Calendar.current
        if let last = state.lastDailyClaim {
            let start = calendar.startOfDay(for: last)
            let today = calendar.startOfDay(for: .now)
            let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
            state.streakDays = days == 1 ? state.streakDays + 1 : 1
        } else {
            state.streakDays = 1
        }

        state.lastDailyClaim = .now
        state.gems += reward
        Haptics.success(enabled: state.hapticsEnabled)
        save()
        presentedSheet = nil
    }

    func performPrestige() {
        guard canPrestige else { return }
        state.prestigeStars += 1
        state.coins = 0
        state.upgradeLevels = [:]
        combo = 0
        feverCharge = 0
        feverSecondsRemaining = 0
        Haptics.success(enabled: state.hapticsEnabled)
        save()
        presentedSheet = nil
    }

    func unlockOrSelect(_ theme: AppThemeChoice) {
        if state.unlockedThemeRaws.contains(theme.rawValue) {
            state.selectedTheme = theme
        } else if state.gems >= theme.unlockCost {
            state.gems -= theme.unlockCost
            state.unlockedThemeRaws.insert(theme.rawValue)
            state.selectedTheme = theme
            Haptics.success(enabled: state.hapticsEnabled)
        }
        save()
    }

    func setNotificationsEnabled(_ enabled: Bool) async {
        if enabled {
            let granted = await NotificationService.requestPermissionAndSchedule()
            state.notificationsEnabled = granted
        } else {
            NotificationService.disableReminders()
            state.notificationsEnabled = false
        }
        save()
    }

    func leaderboard() -> [LeaderboardEntry] {
        let playerScore = state.lifetimeCoins
        let samples: [(String, Double)] = [
            ("LunaTap", max(5_700_000, playerScore * 1.8)),
            ("MrCombo", max(3_800_000, playerScore * 1.35)),
            ("NeonFox", max(2_200_000, playerScore * 1.1)),
            ("Ты", playerScore),
            ("PixelCat", max(140_000, playerScore * 0.7)),
            ("TapNinja", max(45_000, playerScore * 0.35))
        ]
        let sorted = samples.sorted { $0.1 > $1.1 }
        return sorted.enumerated().map { index, item in
            LeaderboardEntry(rank: index + 1, name: item.0, score: item.1, isCurrentUser: item.0 == "Ты")
        }
    }

    func save() {
        state.lastSavedAt = .now
        persistence.save(state)
    }

    func resetAllProgress() {
        stop()
        persistence.reset()
        state = GameState()
        combo = 0
        feverCharge = 0
        feverSecondsRemaining = 0
        pendingOfflineReward = 0
        normalizeDailyProgress()
        save()
        start()
    }

    private var comboGracePeriod: TimeInterval {
        1.05 + Double(level(for: "combo")) * 0.035
    }

    private func tick() {
        let now = Date.now
        let delta = min(0.5, now.timeIntervalSince(lastTickAt))
        lastTickAt = now

        if autoPerSecond > 0 {
            addCoins(autoPerSecond * delta)
        }

        if feverSecondsRemaining > 0 {
            feverSecondsRemaining = max(0, feverSecondsRemaining - delta)
        }

        if let lastTapAt, now.timeIntervalSince(lastTapAt) > comboGracePeriod {
            combo = 0
        }

        saveAccumulator += delta
        if saveAccumulator >= 5 {
            saveAccumulator = 0
            save()
        }
    }

    private func addCoins(_ amount: Double) {
        guard amount.isFinite, amount > 0 else { return }
        state.coins += amount
        state.lifetimeCoins += amount
        state.dailyEarned += amount
    }

    private func calculateOfflineReward() {
        let elapsed = max(0, Date.now.timeIntervalSince(state.lastSavedAt))
        let capped = min(elapsed, offlineHours * 60 * 60)
        pendingOfflineReward = autoPerSecond * capped * 0.8
        state.lastSavedAt = .now
        persistence.save(state)
    }

    private func normalizeDailyProgress() {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.dateFormat = "yyyy-MM-dd"
        let currentKey = formatter.string(from: .now)

        guard state.dailyKey != currentKey else { return }
        state.dailyKey = currentKey
        state.dailyTaps = 0
        state.dailyEarned = 0
        state.dailyUpgrades = 0
        state.dailyBestCombo = 0
        state.claimedMissionIDs = []
        persistence.save(state)
    }
}
