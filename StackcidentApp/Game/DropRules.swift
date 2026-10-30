import Foundation
import CoreGraphics

/// Pure rules used by SpriteKit's live-world prototype. Values are in scene
/// points and seconds, NOT SI meters. They do not predict future physics.
enum DropRules {
    enum Decision: Equatable {
        case continueFalling
        case accepted
        case missed
    }

    struct Observation {
        let elapsed: TimeInterval
        let y: CGFloat
        let killY: CGFloat
        let supported: Bool
        let recentlySupported: Bool
        let hasPlausibleRestingSupport: Bool
        let linearSpeed: CGFloat
        let angularSpeed: CGFloat
        let calmSupportDuration: TimeInterval
    }

    static func decide(_ o: Observation) -> Decision {
        // The first and only immediate loss check. Horizontal travel,
        // oscillation and previously placed objects do not cause an instant
        // game over.
        if o.y < o.killY { return .missed }
        if o.elapsed < 0.55 { return .continueFalling }

        if o.supported && o.linearSpeed < 38 &&
            o.angularSpeed < 0.85 && o.calmSupportDuration >= 0.32 {
            return .accepted
        }
        // Allow settling to finish despite intermittent contact detection,
        // but never award points to an obviously fast-moving object.
        if o.elapsed >= 2.8 &&
            (o.supported || o.recentlySupported) &&
            o.linearSpeed < 70 {
            return .accepted
        }
        // Conservative fallback for SpriteKit contact-cache misses.
        if o.elapsed >= 5.5 && o.hasPlausibleRestingSupport &&
            o.linearSpeed < 16 && o.angularSpeed < 0.4 {
            return .accepted
        }
        return .continueFalling
    }
}
