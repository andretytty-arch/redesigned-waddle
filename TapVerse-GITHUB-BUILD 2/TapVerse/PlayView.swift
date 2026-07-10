import SwiftUI

struct PlayView: View {
    @Environment(GameStore.self) private var store
    @State private var pulse = false

    var body: some View {
        ZStack {
            GameBackground(theme: store.selectedTheme)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                    incomeCard
                    tapArena
                    feverCard
                    quickActions
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 26)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TAPVERSE")
                        .font(.caption.bold())
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Твоя империя")
                        .font(.largeTitle.bold())
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "diamond.fill")
                        .foregroundStyle(.cyan)
                    Text("\(store.state.gems)")
                        .font(.headline.monospacedDigit())
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.top, 8)

            Text(store.state.coins.compactGameNumber)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .contentTransition(.numericText())
                .minimumScaleFactor(0.55)
                .lineLimit(1)

            Text("монет")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.65))
        }
    }

    private var incomeCard: some View {
        GlassCard {
            HStack(spacing: 12) {
                CurrencyBadge(icon: "hand.tap.fill", value: store.tapPower.compactGameNumber, label: "за клик")
                Divider().frame(height: 36)
                CurrencyBadge(icon: "gearshape.2.fill", value: store.autoPerSecond.compactGameNumber, label: "в секунду")
                Divider().frame(height: 36)
                CurrencyBadge(icon: "star.fill", value: "x\(String(format: "%.2f", 1 + Double(store.state.prestigeStars) * 0.25))", label: "престиж")
            }
        }
    }

    private var tapArena: some View {
        ZStack {
            ForEach(store.floatingGains) { gain in
                Text(gain.isCritical ? "КРИТ \(gain.text)" : gain.text)
                    .font(gain.isCritical ? .headline.bold() : .subheadline.bold())
                    .foregroundStyle(gain.isCritical ? .yellow : .white)
                    .shadow(color: .black.opacity(0.3), radius: 3)
                    .offset(x: gain.xOffset, y: -145)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
            }

            Circle()
                .fill(.white.opacity(0.11))
                .frame(width: 286, height: 286)
                .blur(radius: 2)
                .scaleEffect(pulse ? 1.08 : 0.96)

            Circle()
                .stroke(.white.opacity(0.22), lineWidth: 2)
                .frame(width: 258, height: 258)
                .scaleEffect(pulse ? 0.94 : 1.05)

            Button {
                store.tap()
                pulse.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white, store.selectedTheme.colors.last ?? .purple],
                                center: .topLeading,
                                startRadius: 10,
                                endRadius: 150
                            )
                        )
                        .shadow(color: (store.selectedTheme.colors.last ?? .purple).opacity(0.65), radius: 28)

                    VStack(spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 58, weight: .bold))
                        Text("ЖМИ")
                            .font(.title2.weight(.black))
                            .tracking(4)
                    }
                    .foregroundStyle(.black.opacity(0.78))
                }
                .frame(width: 220, height: 220)
            }
            .buttonStyle(TapButtonStyle())
            .accessibilityLabel("Главная кнопка. Нажмите, чтобы получить монеты")
        }
        .frame(height: 330)
        .animation(.spring(response: 0.28, dampingFraction: 0.58), value: store.floatingGains)
        .animation(.easeInOut(duration: 0.25), value: pulse)
        .overlay(alignment: .bottom) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(store.combo > 0 ? .orange : .white.opacity(0.4))
                Text(store.combo > 0 ? "КОМБО x\(store.combo)  •  x\(String(format: "%.2f", store.comboMultiplier))" : "Начни комбо")
                    .font(.subheadline.bold().monospacedDigit())
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }

    private var feverCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                HStack {
                    Label("Режим перегрева", systemImage: "sparkles")
                        .font(.headline)
                    Spacer()
                    Text(store.feverSecondsRemaining > 0 ? "x5 • \(Int(store.feverSecondsRemaining))с" : "\(Int(store.feverCharge))%")
                        .font(.subheadline.bold().monospacedDigit())
                        .foregroundStyle(store.feverSecondsRemaining > 0 ? .yellow : .secondary)
                }
                ProgressBar(progress: store.feverSecondsRemaining > 0 ? 1 : store.feverCharge / 100)
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            Button {
                store.presentedSheet = .prestige
            } label: {
                Label("Престиж", systemImage: "star.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.18))

            ShareLink(item: store.shareText) {
                Label("Бросить вызов", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.18))
        }
    }
}

private struct TapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .rotationEffect(.degrees(configuration.isPressed ? -2 : 0))
            .animation(.spring(response: 0.18, dampingFraction: 0.55), value: configuration.isPressed)
    }
}
