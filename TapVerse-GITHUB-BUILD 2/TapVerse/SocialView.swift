import SwiftUI

struct SocialView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ZStack {
            GameBackground(theme: store.selectedTheme)

            ScrollView {
                VStack(spacing: 18) {
                    inviteCard
                    squadCard
                    leaderboardCard
                }
                .padding(16)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Друзья")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var inviteCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(.cyan)

                Text("Позови друга — устрой дуэль")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)

                Text("Демо уже создаёт персональный код и готовый текст для публикации. После подключения backend код можно связать с реальными наградами.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text(store.state.referralCode)
                    .font(.system(.title2, design: .monospaced, weight: .black))
                    .tracking(5)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 15))

                ShareLink(item: store.shareText) {
                    Label("Поделиться вызовом", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(PrimaryCapsuleButtonStyle())
            }
        }
    }

    private var squadCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Общая цель отряда")
                            .font(.headline)
                        Text("Заполни шкалу вместе с друзьями")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "person.3.sequence.fill")
                        .font(.title2)
                }

                ProgressBar(progress: store.squadGoalProgress)

                HStack {
                    Text("\((store.squadGoalProgress * 2_000_000).compactGameNumber)")
                    Spacer()
                    Text("2M")
                }
                .font(.caption.bold().monospacedDigit())
                .foregroundStyle(.secondary)
            }
        }
    }

    private var leaderboardCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("Локальный рейтинг")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                }

                ForEach(store.leaderboard()) { entry in
                    HStack(spacing: 12) {
                        Text("#\(entry.rank)")
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundStyle(entry.rank <= 3 ? .yellow : .secondary)
                            .frame(width: 34, alignment: .leading)

                        Text(entry.name)
                            .font(.subheadline.weight(entry.isCurrentUser ? .bold : .regular))

                        Spacer()

                        Text(entry.score.compactGameNumber)
                            .font(.subheadline.bold().monospacedDigit())
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, entry.isCurrentUser ? 10 : 0)
                    .background(entry.isCurrentUser ? .white.opacity(0.1) : .clear, in: Capsule())
                }

                Text("Для глобального рейтинга подключается Game Center или собственный сервер.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
