import SpriteKit

@MainActor
final class TowerScene: SKScene, SKPhysicsContactDelegate {
    weak var model: GameModel?
    private var candidate: SKShapeNode?
    private var settledCount = 0
    private var lastTouchedX: CGFloat = 0
    private var dropTime: TimeInterval?
    private var activeDropped: SKShapeNode?
    private var floorY: CGFloat { size.height * 0.16 }
    private let floorCategory: UInt32 = 1
    private let objectCategory: UInt32 = 2
    private let leftMargin: CGFloat = 28
    private let palette: [SKColor] = [.systemYellow, .systemOrange, .systemTeal, .systemPink, .systemPurple]

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.055, green: 0.075, blue: 0.13, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        resetWorld()
    }

    func resetWorld() {
        removeAllActions()
        removeAllChildren()
        activeDropped = nil
        candidate = nil
        dropTime = nil
        settledCount = 0
        let floor = SKShapeNode(rectOf: CGSize(width: size.width * 0.7, height: 24), cornerRadius: 8)
        floor.position = CGPoint(x: size.width / 2, y: floorY)
        floor.fillColor = .init(red: 0.34, green: 0.42, blue: 0.57, alpha: 1)
        floor.strokeColor = .clear
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.7, height: 24))
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = floorCategory
        floor.name = "floor"
        addChild(floor)
        spawnNext()
    }

    func spawnNext() {
        guard candidate == nil else { return }
        let width: CGFloat = [72, 58, 85, 65, 94][settledCount % 5]
        let height: CGFloat = [39, 52, 32, 55, 36][settledCount % 5]
        let object = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 6)
        object.fillColor = palette[settledCount % palette.count]
        object.strokeColor = .white.withAlphaComponent(0.24)
        object.lineWidth = 2
        object.name = "candidate"
        object.position = CGPoint(x: size.width / 2, y: min(size.height - 105, floorY + 300))
        addChild(object)
        candidate = object
    }

    func rotateCandidate(degrees: CGFloat) {
        guard let candidate else { return }
        candidate.zRotation += degrees * .pi / 180
    }

    func commitDrop() {
        guard let object = candidate else { return }
        candidate = nil
        object.name = "stackBody"
        let body = SKPhysicsBody(rectangleOf: object.frame.size)
        body.restitution = 0.04
        body.friction = 0.78
        body.linearDamping = 0.12
        body.angularDamping = 0.22
        body.categoryBitMask = objectCategory
        body.contactTestBitMask = floorCategory | objectCategory
        body.collisionBitMask = floorCategory | objectCategory
        object.physicsBody = body
        activeDropped = object
        dropTime = nil
    }

    override func update(_ currentTime: TimeInterval) {
        guard model?.phase == .falling, let object = activeDropped else { return }
        if dropTime == nil { dropTime = currentTime }
        guard let since = dropTime else { return }
        if object.position.y < floorY - 120 || abs(object.position.x - size.width / 2) > size.width * 0.55 {
            model?.failed()
            activeDropped = nil
            return
        }
        let elapsed = currentTime - since
        if elapsed > 1.25, let body = object.physicsBody,
           abs(body.velocity.dx) < 12, abs(body.velocity.dy) < 12,
           abs(body.angularVelocity) < 0.35 {
            activeDropped = nil
            dropTime = nil
            settledCount += 1
            model?.completedPlacement()
        } else if elapsed > 8 {
            // Prototype safeguard: unresolved movement ends the run.
            model?.failed()
            activeDropped = nil
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first { lastTouchedX = touch.location(in: self).x }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard model?.canAim == true, let candidate, let touch = touches.first else { return }
        let x = touch.location(in: self).x
        let delta = x - lastTouchedX
        candidate.position.x = max(leftMargin, min(size.width - leftMargin, candidate.position.x + delta))
        lastTouchedX = x
    }
}
