import XCTest
@testable import Stackcident

final class GameFeelTests: XCTestCase {
    func testDropTuningSlowerThanOldBuild() {
        XCTAssertLessThan(abs(GameFeel.gravityY), 420)
        XCTAssertGreaterThan(GameFeel.openingClearance, 150)
    }

    func testSleepRequiresActualSlowGroundedBody() {
        XCTAssertTrue(GameFeel.canSleep(
            grounded: true, speed: 3, angularSpeed: 0.1
        ))
        XCTAssertFalse(GameFeel.canSleep(
            grounded: false, speed: 0, angularSpeed: 0
        ))
        XCTAssertFalse(GameFeel.canSleep(
            grounded: true, speed: 80, angularSpeed: 0.1
        ))
        XCTAssertFalse(GameFeel.canSleep(
            grounded: true, speed: 5, angularSpeed: 3.0
        ))
    }

    func testFeedbackHasReadableMinimumDuration() {
        XCTAssertGreaterThanOrEqual(GameFeel.successHoldSeconds, 1.5)
        XCTAssertGreaterThanOrEqual(
            GameFeel.successHoldSeconds + GameFeel.successFadeSeconds, 2.0
        )
    }

    func testSphereHasLowerFrictionAndMoreAngularDamping() {
        XCTAssertLessThan(GameFeel.sphereFriction, GameFeel.standardFriction)
        XCTAssertGreaterThan(
            GameFeel.sphereAngularDamping, GameFeel.standardAngularDamping
        )
    }
}
