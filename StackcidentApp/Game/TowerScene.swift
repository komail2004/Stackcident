import SpriteKit

/// Native SpriteKit gameplay for the iPhone prototype.
/// Live objects remain dynamic. Future Vision needs a separate, controlled
/// physics implementation; this scene does not pretend to simulate it.
@MainActor
final class TowerScene: SKScene {
    weak var model: GameModel?

    private enum Collision {
        static let platform: UInt32 = 1 << 0
        static let piece: UInt32 = 1 << 1
    }

    private enum Piece: Int {
        case crate, wedge, sphere, diamond, column, tiny, beam, barrel

        var name: String {
            switch self {
            case .crate: return "SOFT CRATE"
            case .wedge: return "TRICKY TRIANGLE"
            case .sphere: return "MARBLE MAYHEM"
            case .diamond: return "DIAMOND DISASTER"
            case .column: return "TIPPING TOWER"
            case .tiny: return "TINY TROUBLE"
            case .beam: return "PANIC PLANK"
            case .barrel: return "HEAVY BARREL"
            }
        }
    }

    private let followCamera = SKCameraNode()
    private let scenery = SKNode()
    private var didInitialize = false
    private var platform: SKShapeNode?
    private var candidate: SKShapeNode?
    private var candidateBody: SKPhysicsBody?
    private var activeDrop: SKShapeNode?
    private var placed: [SKShapeNode] = []

    private var nextIndex = 0
    private var lastTouchX: CGFloat?
    private var sceneClock: TimeInterval = 0
    private var releaseTime: TimeInterval?
    private var stableSince: TimeInterval?
    private var previousSample: (position: CGPoint, angle: CGFloat, time: TimeInterval)?
    private var lowMotion = false

    private let baseY: CGFloat = 105
    private let palette: [SKColor] = [
        .init(red: 1.00, green: 0.48, blue: 0.41, alpha: 1),
        .init(red: 0.28, green: 0.86, blue: 0.79, alpha: 1),
        .init(red: 0.99, green: 0.76, blue: 0.34, alpha: 1),
        .init(red: 0.70, green: 0.53, blue: 0.98, alpha: 1),
        .init(red: 0.98, green: 0.40, blue: 0.65, alpha: 1)
    ]

    override func didMove(to view: SKView) {
        guard !didInitialize else { return }
        didInitialize = true
        backgroundColor = SKColor(red: 0.045, green: 0.061, blue: 0.12, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: GameFeel.gravityY)
        addChild(followCamera)
        camera = followCamera
        resetWorld()
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
    }

    func resetWorld() {
        isPaused = false
        for node in children where node !== followCamera {
            node.removeFromParent()
        }
        followCamera.removeAllActions()
        followCamera.position = CGPoint(x: size.width / 2, y: size.height / 2)
        followCamera.setScale(1)
        scenery.removeAllChildren()
        scenery.removeFromParent()
        addChild(scenery)

        platform = nil
        candidate = nil
        candidateBody = nil
        activeDrop = nil
        placed.removeAll()
        nextIndex = 0
        releaseTime = nil
        stableSince = nil
        previousSample = nil
        lowMotion = false
        lastTouchX = nil

        addBackground()

        let width = min(size.width * 0.54, 210)
        let platformSize = CGSize(width: width, height: 20)
        let base = SKShapeNode(rectOf: platformSize, cornerRadius: 7)
        base.position = CGPoint(x: size.width / 2, y: baseY)
        base.fillColor = SKColor(red: 0.38, green: 0.48, blue: 0.68, alpha: 1)
        base.strokeColor = .white.withAlphaComponent(0.50)
        base.lineWidth = 2
        base.zPosition = 3

        // Explicit mutually compatible collision masks are crucial. Never
        // depend on an engine's undocumented default bitmask settings.
        let baseBody = SKPhysicsBody(rectangleOf: platformSize)
        baseBody.isDynamic = false
        baseBody.friction = 0.90
        baseBody.restitution = 0
        baseBody.categoryBitMask = Collision.platform
        baseBody.collisionBitMask = Collision.piece
        baseBody.contactTestBitMask = Collision.piece
        base.physicsBody = baseBody
        addChild(base)
        platform = base

        let halo = SKShapeNode(ellipseOf: CGSize(width: width + 44, height: 23))
        halo.position = CGPoint(x: size.width / 2, y: baseY - 27)
        halo.fillColor = .cyan.withAlphaComponent(0.09)
        halo.strokeColor = .cyan.withAlphaComponent(0.18)
        halo.zPosition = -1
        addChild(halo)

        spawnNext()
    }

    private func addBackground() {
        for i in 0..<40 {
            let dot = SKShapeNode(circleOfRadius: i % 7 == 0 ? 2 : 1)
            dot.fillColor = .white.withAlphaComponent(i % 4 == 0 ? 0.24 : 0.12)
            dot.strokeColor = .clear
            dot.position = CGPoint(
                x: CGFloat((i * 83 + 41) % 997) / 997 * max(size.width, 1),
                y: CGFloat((i * 137 + 71) % 991) / 991 * 2400
            )
            dot.zPosition = -10
            scenery.addChild(dot)
        }
    }

    private func selectedPiece() -> Piece {
        let sequence: [Piece] = [
            .crate, .wedge, .sphere, .beam, .diamond, .tiny, .column,
            .sphere, .barrel, .wedge, .tiny, .diamond, .beam, .column
        ]
        return sequence[nextIndex % sequence.count]
    }

    private func makePiece(_ kind: Piece, level: Int) -> (SKShapeNode, SKPhysicsBody) {
        let node: SKShapeNode
        let body: SKPhysicsBody
        switch kind {
        case .crate:
            let size = CGSize(width: max(42, 65 - CGFloat(level)), height: 44)
            node = SKShapeNode(rectOf: size, cornerRadius: 7)
            body = SKPhysicsBody(rectangleOf: size)
        case .wedge:
            let polygon = CGMutablePath()
            polygon.move(to: CGPoint(x: -33, y: -24))
            polygon.addLine(to: CGPoint(x: 33, y: -24))
            polygon.addLine(to: CGPoint(x: 0, y: 30))
            polygon.closeSubpath()
            node = SKShapeNode(path: polygon)
            body = SKPhysicsBody(polygonFrom: polygon)
        case .sphere:
            let radius: CGFloat = 27
            node = SKShapeNode(circleOfRadius: radius)
            body = SKPhysicsBody(circleOfRadius: radius)
        case .diamond:
            let polygon = CGMutablePath()
            polygon.move(to: CGPoint(x: 0, y: 34))
            polygon.addLine(to: CGPoint(x: 30, y: 0))
            polygon.addLine(to: CGPoint(x: 0, y: -34))
            polygon.addLine(to: CGPoint(x: -30, y: 0))
            polygon.closeSubpath()
            node = SKShapeNode(path: polygon)
            body = SKPhysicsBody(polygonFrom: polygon)
        case .column:
            let size = CGSize(width: 27, height: 80)
            node = SKShapeNode(rectOf: size, cornerRadius: 5)
            body = SKPhysicsBody(rectangleOf: size)
        case .tiny:
            let size = CGSize(width: 31, height: 30)
            node = SKShapeNode(rectOf: size, cornerRadius: 5)
            body = SKPhysicsBody(rectangleOf: size)
        case .beam:
            let size = CGSize(width: max(70, 101 - CGFloat(level)), height: 19)
            node = SKShapeNode(rectOf: size, cornerRadius: 4)
            body = SKPhysicsBody(rectangleOf: size)
        case .barrel:
            let size = CGSize(width: 54, height: 56)
            node = SKShapeNode(rectOf: size, cornerRadius: 12)
            body = SKPhysicsBody(rectangleOf: size)
            body.density = 2.0
        }

        node.fillColor = palette[(nextIndex + kind.rawValue) % palette.count]
        node.strokeColor = .white.withAlphaComponent(0.65)
        node.lineWidth = 2.5
        node.glowWidth = 0.6
        node.zPosition = 5
        let glint = SKShapeNode(circleOfRadius: 4)
        glint.fillColor = .white.withAlphaComponent(0.23)
        glint.strokeColor = .clear
        glint.position = CGPoint(x: -10, y: 9)
        node.addChild(glint)

        // Normalize mass for scene-point-sized geometry. A default density
        // applied to very large shapes can produce extreme impulses.
        body.mass = kind == .barrel ? GameFeel.heavyMass :
                    kind == .sphere ? GameFeel.sphereMass : GameFeel.standardMass
        body.isDynamic = true
        body.affectedByGravity = true
        body.allowsRotation = true
        body.categoryBitMask = Collision.piece
        body.collisionBitMask = Collision.platform | Collision.piece
        body.contactTestBitMask = Collision.platform | Collision.piece
        body.friction = kind == .sphere ? GameFeel.sphereFriction : GameFeel.standardFriction
        body.restitution = 0
        body.linearDamping = kind == .sphere ? GameFeel.sphereDamping : GameFeel.standardDamping
        body.angularDamping = kind == .sphere ? GameFeel.sphereAngularDamping : GameFeel.standardAngularDamping
        // At these reduced fall speeds a 30-point minimum body moves only a
        // fraction of its width per frame. Continuous detection can increase
        // contact solver work in stacks; regression test for tunneling.
        body.usesPreciseCollisionDetection = false
        return (node, body)
    }

    func spawnNext() {
        guard didInitialize, candidate == nil, activeDrop == nil else { return }
        let score = model?.score ?? 0
        let kind = selectedPiece()
        let (node, body) = makePiece(kind, level: score)
        let highest = placed.map { $0.frame.maxY }.max() ?? baseY
        let startY = max(baseY + GameFeel.openingClearance,
                         highest + GameFeel.stackClearance)

        candidateBody = body
        candidate = node
        node.position = CGPoint(x: size.width / 2, y: startY)
        node.name = "candidate"
        node.alpha = 0
        addChild(node)
        node.run(.fadeIn(withDuration: 0.18))
        nextIndex += 1
        model?.announcePiece(kind.name, level: score)

        let cameraY = max(size.height / 2, startY - size.height * 0.32)
        followCamera.removeAction(forKey: "follow")
        let cameraAction = SKAction.move(to: CGPoint(x: size.width / 2, y: cameraY),
                                         duration: 0.32)
        cameraAction.timingMode = .easeInEaseOut
        followCamera.run(cameraAction, withKey: "follow")
    }

    func rotateCandidate(degrees: CGFloat) {
        guard model?.canAim == true, let candidate else { return }
        candidate.zRotation += degrees * .pi / 180
        // Do not scale the object while aiming: scale animations change the
        // visible shape without changing the authored collision fixture.
    }

    @discardableResult
    func commitDrop() -> Bool {
        guard activeDrop == nil, let candidate, let candidateBody else {
            return false
        }
        self.candidate = nil
        self.candidateBody = nil
        candidate.name = "placed"
        candidate.removeAllActions()
        candidate.alpha = 1
        // Attach the exact body created for this visual shape. The old code
        // constructed a second body on release, risking mismatch.
        candidate.physicsBody = candidateBody
        placed.append(candidate)
        activeDrop = candidate
        releaseTime = nil
        stableSince = nil
        previousSample = nil
        lowMotion = false
        return true
    }

    private func supportFrames(for piece: SKShapeNode) -> [CGRect] {
        var frames: [CGRect] = []
        if let platform { frames.append(platform.frame) }
        frames.append(contentsOf: placed.filter { $0 !== piece }.map { $0.frame })
        return frames
    }

    override func update(_ currentTime: TimeInterval) {
        sceneClock = currentTime
    }

    /// Read object positions *after* SpriteKit's physics step.
    override func didSimulatePhysics() {
        guard model?.phase == .falling,
              let piece = activeDrop,
              piece.physicsBody != nil else { return }

        if releaseTime == nil { releaseTime = sceneClock }
        let elapsed = max(0, sceneClock - (releaseTime ?? sceneClock))
        let grounded = DropRules.isGrounded(
            piece: piece.frame,
            pieceCenterY: piece.position.y,
            supports: supportFrames(for: piece)
        )

        if let previous = previousSample,
           sceneClock - previous.time >= 0.22 {
            let dt = sceneClock - previous.time
            let displacement = hypot(piece.position.x - previous.position.x,
                                     piece.position.y - previous.position.y)
            let turn = abs(piece.zRotation - previous.angle)
            lowMotion = displacement / dt < 42 && turn / dt < 0.85
            previousSample = (piece.position, piece.zRotation, sceneClock)
        } else if previousSample == nil {
            previousSample = (piece.position, piece.zRotation, sceneClock)
        }

        if grounded && lowMotion {
            if stableSince == nil { stableSince = sceneClock }
        } else {
            stableSince = nil
        }

        let decision = DropRules.decide(.init(
            elapsed: elapsed,
            pieceBottom: piece.frame.minY,
            killLine: baseY - 95,
            geometricSupport: grounded,
            stableDuration: stableSince.map { sceneClock - $0 } ?? 0,
            lowMotion: lowMotion
        ))

        switch decision {
        case .accepted:
            completeCurrentDrop()
        case .missed:
            activeDrop = nil
            model?.failed()
        case .continueFalling:
            if elapsed > 5 { model?.updateWaitingStatus() }
        }
    }

    private func completeCurrentDrop() {
        guard let landed = activeDrop else { return }
        // SpriteKit's sleeping state preserves dynamic bodies: future impacts
        // can wake them. Do not pin the tower or freeze moving pieces.
        if let body = landed.physicsBody {
            let speed = hypot(body.velocity.dx, body.velocity.dy)
            if GameFeel.canSleep(
                grounded: DropRules.isGrounded(
                    piece: landed.frame,
                    pieceCenterY: landed.position.y,
                    supports: supportFrames(for: landed)
                ),
                speed: speed,
                angularSpeed: abs(body.angularVelocity)
            ) {
                body.velocity = .zero
                body.angularVelocity = 0
                body.isResting = true
            }
        }
        activeDrop = nil
        releaseTime = nil
        stableSince = nil
        previousSample = nil
        lowMotion = false
        model?.completedPlacement()
        let message = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        message.text = ["NICE!", "A MIRACLE!", "STILL STANDING!", "SOMEHOW!"][
            max(0, (model?.score ?? 1) - 1) % 4
        ]
        message.fontSize = 21
        message.fontColor = .init(red: 1, green: 0.81, blue: 0.48, alpha: 1)
        message.position = CGPoint(x: size.width / 2,
                                   y: followCamera.position.y + size.height * 0.20)
        message.zPosition = 50
        message.name = "successToast"
        enumerateChildNodes(withName: "successToast") { node, _ in node.removeFromParent() }
        addChild(message)
        message.run(.sequence([
            .wait(forDuration: GameFeel.successHoldSeconds),
            .group([.moveBy(x: 0, y: 28, duration: GameFeel.successFadeSeconds),
                    .fadeOut(withDuration: GameFeel.successFadeSeconds)]),
            .removeFromParent()
        ]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchX = touches.first?.location(in: self).x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard model?.canAim == true, let candidate,
              let touch = touches.first else { return }
        let newX = touch.location(in: self).x
        let dx = newX - (lastTouchX ?? newX)
        candidate.position.x = min(size.width - 38,
                                   max(38, candidate.position.x + dx))
        lastTouchX = newX
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchX = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchX = nil
    }
}
