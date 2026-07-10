import AppIntents

struct OpenTapVerseIntent: AppIntent {
    static let title: LocalizedStringResource = "Открыть TAPVERSE"
    static let description = IntentDescription("Открывает главный экран кликера.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct TapVerseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenTapVerseIntent(),
            phrases: [
                "Открыть \(.applicationName)",
                "Начать кликать в \(.applicationName)"
            ],
            shortTitle: "Открыть кликер",
            systemImageName: "hand.tap.fill"
        )
    }
}
