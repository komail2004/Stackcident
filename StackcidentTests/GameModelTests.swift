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
        XCTAssertEqual(game.visionCharges, 3, "Disabled prediction must never debit a charge")
        game.restart()
        XCTAssertEqual(game.score, 0)
        XCTAssertTrue(game.canAim)
        XCTAssertEqual(game.levelName, "THE WARMUP")
    }

    func testNoDropWithoutScene() {
        let game = GameModel()
        game.drop()
        XCTAssertTrue(game.canAim, "A failed drop dispatch must not leave the game waiting")
    }

    func testDuplicatePlacementCannotScore() {
        let game = GameModel()
        game.completedPlacement()
        XCTAssertEqual(game.score, 0, "Placement without a falling object must be ignored")
    }

    func testDifficultyLabels() {
        let game = GameModel()
        game.announcePiece("MARBLE MAYHEM", level: 5)
        XCTAssertEqual(game.levelName, "DANGER ZONE")
        XCTAssertTrue(game.status.contains("MARBLE MAYHEM"))
        game.announcePiece("DIAMOND DISASTER", level: 14)
        XCTAssertEqual(game.levelName, "IMPOSSIBLE?")
    }
}
