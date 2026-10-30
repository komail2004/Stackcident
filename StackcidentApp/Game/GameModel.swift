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
    @Published private(set) var levelName = "THE WARMUP"
    @Published private(set) var nextPieceName = "SOFT CRATE"

    weak var scene: TowerScene?

    var canAim: Bool { phase == .ready }
    var canDrop: Bool { phase == .ready }

    func rotate(_ degrees: CGFloat) { guard canAim else { return }; scene?.rotateCandidate(degrees: degrees) }
    func drop() {
        guard canDrop else { return }
        guard scene?.commitDrop() == true else { return }
        phase = .falling
        status = "Gravity is judging you…"
    }

    func completedPlacement() {
        guard phase == .falling else { return }
        score += 1
        if score > best {
            best = score
            UserDefaults.standard.set(best, forKey: "bestScore")
        }
        phase = .ready
        status = ["Clean landing!", "Physics approves. Barely.", "A bold architectural decision.", "Somehow, that worked."][score % 4]
        scene?.spawnNext()
    }

    func failed() {
        guard phase == .falling else { return }
        phase = .over
        status = "That piece fell below the platform. Gravity wins!"
    }

    func restart() {
        score = 0
        visionCharges = 3
        phase = .ready
        status = "Drag to aim, rotate, then drop."
        levelName = "THE WARMUP"
        nextPieceName = "SOFT CRATE"
        scene?.resetWorld()
    }

    func announcePiece(_ name: String, level: Int) {
        nextPieceName = name
        levelName = level < 3 ? "THE WARMUP" : level < 7 ? "DANGER ZONE" : level < 12 ? "CHAOS MODE" : "IMPOSSIBLE?"
        // After a scored placement, preserve the success message until the
        // player starts the next drop. The upcoming object has its own HUD.
        if score == 0 && phase == .ready {
            status = "NEXT UP  ·  \(name)"
        }
    }

    func updateWaitingStatus() {
        guard phase == .falling else { return }
        if status != "Landing in progress… look out below!" {
            status = "Landing in progress… look out below!"
        }
    }

    func futureVision() {
        // Accurate isolated prediction requires a step-able cloned physics world.
        // We deliberately do not fabricate a prediction using SpriteKit animation.
        status = "Future Vision is locked pending physics parity tests."
    }
}
