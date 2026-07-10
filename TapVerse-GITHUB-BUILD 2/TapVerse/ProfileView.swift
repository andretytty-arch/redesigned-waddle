import SwiftUI

struct ProfileView: View {
    @Environment(GameStore.self) private var store
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            GameBackground(theme: store.selectedTheme)

            ScrollView {
                VStack(spacing: 18) {
                    statsCard
                    prestigeCard
                    themesCard
                    settingsCard
                }
                .padding(16)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Сбросить весь прогресс?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Сбросить", role: .destructive) {
                store.resetAllProgress()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Монеты, улучшения, темы, достижения и серия будут удалены.")
        }
    }

    private var statsCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Игрок \(store.state.referralCode)")
                            .font(.title3.bold())
                        Text("Звёздный уровень \(store.state.prestigeStars)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 46))
                }

                Divider()

                HStack(spacing: 10) {
                    profileStat("Монет", store.state.lifetimeCoins.compactGameNumber)
                    profileStat("Кликов", Double(store.state.lifetimeTaps).compactGameNumber)
                    profileStat("Комбо", "x\(store.state.maxCombo)")
                }
            }
        }
    }

    private var prestigeCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Престиж")
                            .font(.headline)
                        Text("Перезапусти экономику ради постоянного множителя")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "star.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                }

                ProgressBar(progress: store.prestigeProgress)

                HStack {
                    Text(store.state.lifetimeCoins.compactGameNumber)
                    Spacer()
                    Text(store.prestigeRequirement.compactGameNumber)
                }
                .font(.caption.bold().monospacedDigit())
                .foregroundStyle(.secondary)

                Button {
                    store.presentedSheet = .prestige
                } label: {
                    Text(store.canPrestige ? "Перейти к престижу" : "Нужно больше монет")
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
                .disabled(!store.canPrestige)
                .opacity(store.canPrestige ? 1 : 0.45)
            }
        }
    }

    private var themesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Стили интерфейса")
                        .font(.headline)
                    Spacer()
                    Label("\(store.state.gems)", systemImage: "diamond.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.cyan)
                }

                ForEach(AppThemeChoice.allCases) { theme in
                    ThemeRow(theme: theme)
                }
            }
        }
    }

    private var settingsCard: some View {
        GlassCard {
            VStack(spacing: 4) {
                Toggle(
                    isOn: Binding(
                        get: { store.state.hapticsEnabled },
                        set: { value in
                            store.state.hapticsEnabled = value
                            store.save()
                        }
                    )
                ) {
                    Label("Тактильный отклик", systemImage: "waveform")
                }
                .padding(.vertical, 8)

                Divider()

                Toggle(
                    isOn: Binding(
                        get: { store.state.notificationsEnabled },
                        set: { value in
                            Task { await store.setNotificationsEnabled(value) }
                        }
                    )
                ) {
                    Label("Напоминание через 8 часов", systemImage: "bell.badge.fill")
                }
                .padding(.vertical, 8)

                Divider()

                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Сбросить прогресс", systemImage: "trash.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                }
            }
        }
    }

    private func profileStat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.headline.bold().monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ThemeRow: View {
    @Environment(GameStore.self) private var store
    let theme: AppThemeChoice

    var body: some View {
        let unlocked = store.state.unlockedThemeRaws.contains(theme.rawValue)
        let selected = store.state.selectedTheme == theme

        Button {
            store.unlockOrSelect(theme)
        } label: {
            HStack(spacing: 12) {
                LinearGradient(colors: theme.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 54, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay {
                        Image(systemName: theme.icon)
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.title)
                        .font(.subheadline.bold())
                    Text(unlocked ? (selected ? "Выбрана" : "Открыта") : "\(theme.unlockCost) кристаллов")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : unlocked ? "circle" : "lock.fill")
                    .foregroundStyle(selected ? .green : .secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!unlocked && store.state.gems < theme.unlockCost)
        .opacity(!unlocked && store.state.gems < theme.unlockCost ? 0.5 : 1)
    }
}
