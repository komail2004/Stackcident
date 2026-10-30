import XCTest
@testable import Stackcident

final class DropRulesTests: XCTestCase {
    private func sample(elapsed: TimeInterval = 1,
                        y: CGFloat = 150,
                        supported: Bool = false,
                        recently: Bool = false,
                        plausible: Bool = false,
                        speed: CGFloat = 8,
                        angular: CGFloat = 0.1,
                        calm: TimeInterval = 0) -> DropRules.Observation {
        DropRules.Observation(elapsed: elapsed, y: y, killY: 25,
                              supported: supported, recentlySupported: recently,
                              hasPlausibleRestingSupport: plausible,
                              linearSpeed: speed, angularSpeed: angular,
                              calmSupportDuration: calm)
    }

    func testRestingOnStaticPlatformCanCompleteWithoutContactCallback() {
        // TowerScene turns calm geometric floor support into supported=true.
        // This is the initial-drop regression shown in the simulator.
        XCTAssertEqual(DropRules.decide(sample(elapsed: 1.3,
                                               supported: true,
                                               speed: 0.4,
                                               angular: 0.01,
                                               calm: 0.4)), .accepted)
    }

    func testGeometricNearSupportNeverScoresWhileMovingFast() {
        XCTAssertEqual(DropRules.decide(sample(elapsed: 6,
                                               plausible: true,
                                               speed: 80)), .continueFalling)
    }

    func testWobblingContactIsNotImmediateLoss() {
        XCTAssertEqual(DropRules.decide(sample(supported: true, speed: 80)),
                       .continueFalling)
    }

    func testTrueLowerBoundaryMissEndsRun() {
        XCTAssertEqual(DropRules.decide(sample(y: 24, supported: true)),
                       .missed)
    }

    func testNewObjectRequiresSettledDwellTime() {
        XCTAssertEqual(DropRules.decide(sample(supported: true, calm: 0.1)),
                       .continueFalling)
        XCTAssertEqual(DropRules.decide(sample(supported: true, calm: 0.42)),
                       .accepted)
    }

    func testUnsupportedStationaryMidairNeverScores() {
        XCTAssertEqual(DropRules.decide(sample(elapsed: 9, speed: 0)),
                       .continueFalling)
    }

    func testRecentlySupportedCanFinishAfterGracePeriod() {
        XCTAssertEqual(DropRules.decide(sample(elapsed: 3.1, recently: true,
                                               speed: 20)), .accepted)
    }

    func testLateFallbackNeedsNearSupportAndLowMotion() {
        XCTAssertEqual(DropRules.decide(sample(elapsed: 6, plausible: true,
                                               speed: 8)), .accepted)
        XCTAssertEqual(DropRules.decide(sample(elapsed: 6, plausible: true,
                                               speed: 60)), .continueFalling)
    }

    func testJustReleasedObjectCannotImmediatelyScore() {
        XCTAssertEqual(DropRules.decide(sample(elapsed: 0.2, supported: true,
                                               calm: 1)), .continueFalling)
    }
}
