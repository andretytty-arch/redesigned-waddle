import UIKit

@MainActor
enum Haptics {
    static func tap(enabled: Bool, critical: Bool) {
        guard enabled else { return }
        if critical {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.65)
        }
    }

    static func success(enabled: Bool) {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
