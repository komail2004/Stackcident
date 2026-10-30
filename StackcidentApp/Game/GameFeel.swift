import Foundation
import CoreGraphics

/// Central tuning values for the iPhone SpriteKit prototype. Units are
/// SpriteKit scene points/seconds, not SI units or Future Vision parameters.
enum GameFeel {
    static let gravityY: CGFloat = -245
    static let openingClearance: CGFloat = 215
    static let stackClearance: CGFloat = 155

    static let standardMass: CGFloat = 0.85
    static let sphereMass: CGFloat = 0.65
    static let heavyMass: CGFloat = 1.8

    static let standardFriction: CGFloat = 0.74
    static let sphereFriction: CGFloat = 0.25
    static let standardDamping: CGFloat = 0.65
    static let sphereDamping: CGFloat = 0.95
    static let standardAngularDamping: CGFloat = 1.2
    static let sphereAngularDamping: CGFloat = 2.4

    // Native SpriteKit success feedback must remain legible long enough
    // for a player to register it; SwiftUI status stays until another action.
    static let successHoldSeconds: TimeInterval = 1.75
    static let successFadeSeconds: TimeInterval = 0.65

    // Can only sleep a body when it has *already* passed supported landing
    // resolution and is physically slow. An impact may wake it later.
    static func canSleep(grounded: Bool, speed: CGFloat, angularSpeed: CGFloat) -> Bool {
        grounded && speed < 24 && angularSpeed < 0.50
    }
}
