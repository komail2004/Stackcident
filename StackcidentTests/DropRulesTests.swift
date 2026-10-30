import XCTest
@testable import Stackcident

final class DropRulesTests: XCTestCase {
    private func observation(
        elapsed: TimeInterval = 1.5,
        bottom: CGFloat = 100,
        supported: Bool = true,
        stableDuration: TimeInterval = 0.5,
        lowMotion: Bool = true
    ) -> DropRules.Observation {
        .init(
            elapsed: elapsed,
            pieceBottom: bottom,
            killLine: 10,
            geometricSupport: supported,
            stableDuration: stableDuration,
            lowMotion: lowMotion
        )
    }

    func testFirstDropRestingOnPlatformScores() {
        let piece = CGRect(x: 160, y: 124, width: 65, height: 44)
        let base = CGRect(x: 125, y: 104, width: 140, height: 20)
        XCTAssertTrue(DropRules.isGrounded(
            piece: piece, pieceCenterY: piece.midY, supports: [base]
        ))
        XCTAssertEqual(DropRules.decide(observation()), .accepted)
    }

    func testSecondPieceCanRestOnFirst() {
        let first = CGRect(x: 160, y: 124, width: 65, height: 44)
        let second = CGRect(x: 177, y: 168, width: 55, height: 50)
        XCTAssertTrue(DropRules.isGrounded(
            piece: second, pieceCenterY: second.midY, supports: [first]
        ))
    }

    func testFarAbovePlatformDoesNotCountAsLanded() {
        let piece = CGRect(x: 160, y: 200, width: 65, height: 44)
        let base = CGRect(x: 125, y: 104, width: 140, height: 20)
        XCTAssertFalse(DropRules.isGrounded(
            piece: piece, pieceCenterY: piece.midY, supports: [base]
        ))
    }

    func testPieceOffPlatformDoesNotCountAsLanded() {
        let piece = CGRect(x: 290, y: 124, width: 65, height: 44)
        let base = CGRect(x: 125, y: 104, width: 140, height: 20)
        XCTAssertFalse(DropRules.isGrounded(
            piece: piece, pieceCenterY: piece.midY, supports: [base]
        ))
    }

    func testPieceBelowSupportDoesNotCountAsLanded() {
        let piece = CGRect(x: 160, y: 50, width: 65, height: 44)
        let base = CGRect(x: 125, y: 104, width: 140, height: 20)
        XCTAssertFalse(DropRules.isGrounded(
            piece: piece, pieceCenterY: piece.midY, supports: [base]
        ))
    }

    func testWobblingDoesNotImmediatelyScoreOrLose() {
        XCTAssertEqual(DropRules.decide(
            observation(stableDuration: 0, lowMotion: false)
        ), .continueFalling)
    }

    func testSupportedAndCalmNeedsDwell() {
        XCTAssertEqual(DropRules.decide(
            observation(stableDuration: 0.15)
        ), .continueFalling)
        XCTAssertEqual(DropRules.decide(
            observation(stableDuration: 0.40)
        ), .accepted)
    }

    func testMissBelowKillLineEndsRun() {
        XCTAssertEqual(DropRules.decide(
            observation(bottom: 9, supported: false)
        ), .missed)
    }

    func testStationaryObjectInMidairNeverScores() {
        XCTAssertEqual(DropRules.decide(
            observation(elapsed: 20, supported: false)
        ), .continueFalling)
    }

    func testTimeAloneNeverCausesGameOverOrSuccess() {
        XCTAssertEqual(DropRules.decide(
            observation(elapsed: 200, supported: false, lowMotion: false)
        ), .continueFalling)
    }

    func testLongSupportedAndSlowObjectResolves() {
        XCTAssertEqual(DropRules.decide(
            observation(elapsed: 3.2, stableDuration: 0.1)
        ), .accepted)
    }

    func testVeryEarlyContactCannotScore() {
        XCTAssertEqual(DropRules.decide(
            observation(elapsed: 0.2, stableDuration: 0.5)
        ), .continueFalling)
    }

    func testSlidingObjectCannotScoreFromTimeout() {
        XCTAssertEqual(DropRules.decide(
            observation(elapsed: 10, supported: true, lowMotion: false)
        ), .continueFalling)
    }
}
