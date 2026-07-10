import Foundation

struct PersistenceService {
    private let key = "tapverse.game.state.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> GameState {
        guard
            let data = defaults.data(forKey: key),
            let state = try? JSONDecoder().decode(GameState.self, from: data)
        else {
            return GameState()
        }
        return state
    }

    func save(_ state: GameState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}
