import XCTest
@testable import Stackcident

@MainActor
final class GameModelTests: XCTestCase {
    func testInitialStateAndRestart() {
        let game = GameModel()
        XCTAssertEqual(game.score, 0)
        XCTAssertEqual(game.visionCharges, 3)
        XCTAssertTrue(game.canDrop)
        game.futureVision()
        XCTAssertEqual(game.visionCharges, 3, "Unimplemented prediction must never debit a charge")
        game.restart()
        XCTAssertEqual(game.score, 0)
        XCTAssertTrue(game.canAim)
    }
}
