import SwiftUI

struct MissionsView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ZStack {
            GameBackground(theme: store.selectedTheme)

            ScrollView {
                VStack(spacing: 18) {
                    SectionHeader("Ежедневные задания", subtitle: "Обновляются каждый день и дают кристаллы")

                    ForEach(GameData.missions) { mission in
                        MissionCard(mission: mission)
                    }

                    SectionHeader("Достижения", subtitle: "Постоянные цели для долгой прогрессии")
                        .padding(.top, 6)

                    ForEach(GameData.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding(16)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Задания")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MissionCard: View {
    @Environment(GameStore.self) private var store
    let mission: MissionDefinition

    var body: some View {
        let progress = store.missionProgress(mission)
        let claimed = store.state.claimedMissionIDs.contains(mission.id)

        GlassCard {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: mission.icon)
                        .font(.title3.bold())
                        .frame(width: 42, height: 42)
                        .background(.white.opacity(0.12), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(mission.title)
                            .font(.headline)
                        Text("\(store.missionCurrentValue(mission).compactGameNumber) / \(mission.target.compactGameNumber)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Label("\(mission.rewardGems)", systemImage: "diamond.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.cyan)
                }

                ProgressBar(progress: progress)

                Button {
                    store.claimMission(mission)
                } label: {
                    Text(claimed ? "Получено" : progress >= 1 ? "Забрать награду" : "В процессе")
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
                .disabled(progress < 1 || claimed)
                .opacity(progress < 1 || claimed ? 0.45 : 1)
            }
        }
    }
}

private struct AchievementCard: View {
    @Environment(GameStore.self) private var store
    let achievement: AchievementDefinition

    var body: some View {
        let progress = store.achievementProgress(achievement)
        let claimed = store.state.claimedAchievementIDs.contains(achievement.id)

        GlassCard {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: achievement.icon)
                        .font(.title2.bold())
                        .foregroundStyle(progress >= 1 ? .yellow : .white.opacity(0.65))
                        .frame(width: 46, height: 46)
                        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(achievement.title)
                            .font(.headline)
                        Text(achievement.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("+\(achievement.rewardGems) 💎")
                        .font(.caption.bold())
                }

                ProgressBar(progress: progress)

                if progress >= 1 {
                    Button {
                        store.claimAchievement(achievement)
                    } label: {
                        Text(claimed ? "Награда получена" : "Получить награду")
                    }
                    .buttonStyle(PrimaryCapsuleButtonStyle())
                    .disabled(claimed)
                    .opacity(claimed ? 0.45 : 1)
                }
            }
        }
    }
}
