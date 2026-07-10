import SwiftUI

struct GameBackground: View {
    let theme: AppThemeChoice

    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(.white.opacity(0.09))
                .frame(width: 240, height: 240)
                .blur(radius: 18)
                .offset(x: 150, y: -260)

            Circle()
                .fill(theme.colors.last?.opacity(0.2) ?? .clear)
                .frame(width: 300, height: 300)
                .blur(radius: 35)
                .offset(x: -170, y: 290)
        }
    }
}

struct GlassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(.ultraThinMaterial.opacity(0.85), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            }
    }
}

struct CurrencyBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.yellow)
                .frame(width: 32, height: 32)
                .background(.white.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline.monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.12))
                Capsule()
                    .fill(.white)
                    .frame(width: proxy.size.width * max(0, min(1, progress)))
            }
        }
        .frame(height: 8)
        .accessibilityValue("\(Int(progress * 100)) процентов")
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title2.bold())
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PrimaryCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(.white, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
