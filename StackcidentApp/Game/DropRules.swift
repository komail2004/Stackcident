import Foundation

/// Pure, testable arcade landing policy. SpriteKit owns the physical motion;
/// these rules only decide whether a completed drop can be scored or missed.
/// All distances are in scene points.
enum DropRules {
    enum Decision: Equatable {
        case continueFalling
        case accepted
        case missed
    }

    struct Observation {
        let elapsed: TimeInterval
        let pieceBottom: CGFloat
        let killLine: CGFloat
        let geometricSupport: Bool
        let stableDuration: TimeInterval
        let lowMotion: Bool
    }

    /// A shape is supported if its bottom is near the upper surface of a lower
    /// shape, with meaningful horizontal overlap. Caller supplies physical
    /// object frames in the same scene coordinate system.
    static func isGrounded(
        piece: CGRect,
        pieceCenterY: CGFloat,
        supports: [CGRect]
    ) -> Bool {
        guard !piece.isNull, !piece.isEmpty else { return false }
        for support in supports where !support.isNull && !support.isEmpty {
            let horizontalOverlap = min(piece.maxX, support.maxX) -
                                    max(piece.minX, support.minX)
            let minimumOverlap = min(piece.width, support.width) * 0.18
            let gap = piece.minY - support.maxY
            if pieceCenterY > support.midY &&
               horizontalOverlap > max(6, minimumOverlap) &&
               gap >= -18 && gap <= 20 {
                return true
            }
        }
        return false
    }

    static func decide(_ state: Observation) -> Decision {
        // A piece is lost only after it has actually passed below the
        // platform and cannot be recovered. Never use a time-only loss rule.
        if state.pieceBottom < state.killLine {
            return .missed
        }
        if state.elapsed < 0.55 {
            return .continueFalling
        }
        if state.geometricSupport &&
           state.lowMotion &&
           state.stableDuration >= 0.32 {
            return .accepted
        }
        // A supported body can exhibit solver jitter indefinitely. The
        // fallback still requires low movement and physical support.
        if state.elapsed >= 3.0 &&
           state.geometricSupport &&
           state.lowMotion {
            return .accepted
        }
        return .continueFalling
    }
}
