import SwiftUI

struct OfflineRewardSheet: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        sheetBackground {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 52))
                .foregroundStyle(.yellow)

            Text("Пока тебя не было")
                .font(.title.bold())

            Text("Авто‑майнер продолжал работать и накопил награду.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("+\(store.pendingOfflineReward.compactGameNumber)")
                .font(.system(size: 42, weight: .black, design: .rounded))

            Button("Забрать монеты") {
                store.claimOfflineReward()
            }
            .buttonStyle(PrimaryCapsuleButtonStyle())
        }
        .interactiveDismissDisabled()
    }
}

struct DailyRewardSheet: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        sheetBackground {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 52))
                .foregroundStyle(.cyan)

            Text("День \(store.state.streakDays + 1)")
                .font(.title.bold())

            Text("Заходи каждый день: серия увеличивает награду до 14-го дня.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Label("+\(store.dailyRewardAmount)", systemImage: "diamond.fill")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(.cyan)

            Button("Забрать награду") {
                store.claimDailyReward()
            }
            .buttonStyle(PrimaryCapsuleButtonStyle())
        }
        .interactiveDismissDisabled()
    }
}

struct PrestigeSheet: View {
    @Environment(GameStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        sheetBackground {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 54))
                .foregroundStyle(.yellow)

            Text("Новая галактика")
                .font(.title.bold())

            Text("Монеты и уровни улучшений обнулятся. Ты получишь звезду и постоянный бонус ко всему доходу.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 30) {
                VStack {
                    Text("\(store.state.prestigeStars)")
                        .font(.title.bold())
                    Text("сейчас")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "arrow.right")
                VStack {
                    Text("\(store.state.prestigeStars + 1)")
                        .font(.title.bold())
                    Text("после")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if store.canPrestige {
                Button("Перезапустить и получить звезду") {
                    store.performPrestige()
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
            } else {
                Text("Нужно заработать \(store.prestigeRequirement.compactGameNumber) монет за всё время.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Продолжить играть") {
                    dismiss()
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
            }
        }
    }
}

private func sheetBackground<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ZStack {
        LinearGradient(colors: [Color(hex: 0x18132F), Color(hex: 0x3B2467)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        VStack(spacing: 18) {
            content()
        }
        .padding(24)
    }
    .preferredColorScheme(.dark)
}
