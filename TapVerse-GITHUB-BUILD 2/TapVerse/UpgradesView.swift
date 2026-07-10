import SwiftUI

struct UpgradesView: View {
    @Environment(GameStore.self) private var store
    @State private var selectedCategory: UpgradeCategory = .tap

    private var filteredUpgrades: [UpgradeDefinition] {
        GameData.upgrades.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ZStack {
            GameBackground(theme: store.selectedTheme)

            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader("Лаборатория", subtitle: "Прокачивай активный и пассивный доход")

                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(UpgradeCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)

                    ForEach(filteredUpgrades) { upgrade in
                        UpgradeCard(upgrade: upgrade)
                    }

                    GlassCard {
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.max.fill")
                                .font(.title2)
                                .foregroundStyle(.yellow)
                            Text("Сначала усиливай авто‑доход, затем критический шанс. Так прогресс продолжится даже когда приложение закрыто.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Улучшения")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct UpgradeCard: View {
    @Environment(GameStore.self) private var store
    let upgrade: UpgradeDefinition

    var body: some View {
        let level = store.level(for: upgrade.id)
        let price = store.cost(for: upgrade)
        let affordable = store.canBuy(upgrade)

        GlassCard {
            HStack(spacing: 14) {
                Image(systemName: upgrade.icon)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(upgrade.title)
                            .font(.headline)
                        Spacer()
                        Text("УР. \(level)")
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(.secondary)
                    }

                    Text(upgrade.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        store.buy(upgrade)
                    } label: {
                        HStack {
                            Image(systemName: "circle.hexagongrid.fill")
                            Text(price.compactGameNumber)
                            Spacer()
                            Text("Улучшить")
                        }
                        .font(.subheadline.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(affordable ? .white : .white.opacity(0.12), in: Capsule())
                        .foregroundStyle(affordable ? .black : .white.opacity(0.45))
                    }
                    .disabled(!affordable)
                    .accessibilityLabel("Купить \(upgrade.title) за \(price.compactGameNumber) монет")
                }
            }
        }
    }
}
