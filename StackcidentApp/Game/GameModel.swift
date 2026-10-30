import Foundation
import Combine

@MainActor
final class GameModel: ObservableObject {
    enum Phase { case ready, falling, over }
    @Published private(set) var score: Int = 0
    @Published private(set) var best: Int = UserDefaults.standard.integer(forKey: "bestScore")
    @Published private(set) var phase: Phase = .ready
    @Published private(set) var status = "Drag to aim, rotate, then drop."
    @Published private(set) var visionCharges = 3

    weak var scene: TowerScene?

    var canAim: Bool { phase == .ready }
    var canDrop: Bool { phase == .ready }

    func rotate(_ degrees: CGFloat) { guard canAim else { return }; scene?.rotateCandidate(degrees: degrees) }
    func drop() {
        guard canDrop else { return }
        phase = .falling
        status = "Hold it together…"
        scene?.commitDrop()
    }

    func completedPlacement() {
        guard phase == .falling else { return }
        score += 1
        if score > best {
            best = score
            UserDefaults.standard.set(best, forKey: "bestScore")
        }
        phase = .ready
        status = "Nice save! Try another."
        scene?.spawnNext()
    }

    func failed() {
        guard phase != .over else { return }
        phase = .over
        status = "STACKCIDENT! The tower fell."
    }

    func restart() {
        score = 0
        visionCharges = 3
        phase = .ready
        status = "Drag to aim, rotate, then drop."
        scene?.resetWorld()
    }

    func futureVision() {
        // Accurate isolated prediction requires a step-able cloned physics world.
        // We deliberately do not fabricate a prediction using SpriteKit animation.
        status = "Future Vision is locked pending physics parity tests."
    }
}
