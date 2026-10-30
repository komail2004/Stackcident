import SpriteKit

/// iPhone-native arcade stacking. SpriteKit is the live physics prototype;
/// Future Vision remains disabled until a separate parity-tested solver exists.
@MainActor
final class TowerScene: SKScene {
    weak var model: GameModel?
    private let followCamera = SKCameraNode()
    private let scenery = SKNode()
    private var candidate: SKShapeNode?
    private var falling: SKShapeNode?
    private var placed: [SKShapeNode] = []
    private var platformNode: SKShapeNode?
    private var activeDefinition: Piece = .block
    private var nextIndex = 0
    private var initialized = false
    private var lastTouchX: CGFloat?
    private var dropTime: TimeInterval?
    private var contactSince: TimeInterval?
    private var lastSupportTime: TimeInterval?
    private var previousFallingPose: CGPoint?
    private var previousFallingAngle: CGFloat = 0
    private var restingSince: TimeInterval?
    private var cameraHeight: CGFloat = 0
    private let baseY: CGFloat = 100
    private let colors: [SKColor] = [
        .init(red: 0.99, green: 0.48, blue: 0.40, alpha: 1),
        .init(red: 0.23, green: 0.83, blue: 0.78, alpha: 1),
        .init(red: 0.96, green: 0.74, blue: 0.33, alpha: 1),
        .init(red: 0.67, green: 0.54, blue: 0.98, alpha: 1),
        .init(red: 0.95, green: 0.38, blue: 0.61, alpha: 1)
    ]

    private enum Piece: Int {
        case block, plank, sphere, wedge, column, barrel, tiny, diamond
        var title: String {
            switch self {
            case .block: return "SOFT CRATE"
            case .plank: return "BALANCE BEAM"
            case .sphere: return "MARBLE MAYHEM"
            case .wedge: return "TRICKY TRIANGLE"
            case .column: return "TIPPING TOWER"
            case .barrel: return "HEAVY BARREL"
            case .tiny: return "TINY TROUBLE"
            case .diamond: return "DIAMOND DISASTER"
            }
        }
    }

    override func didMove(to view: SKView) {
        guard !initialized else { return }
        initialized = true
        backgroundColor = SKColor(red: 0.045, green: 0.061, blue: 0.12, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -620)
        addChild(followCamera)
        camera = followCamera
        resetWorld()
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
    }

    func resetWorld() {
        isPaused = false
        removeAllActions()
        children.filter { $0 !== followCamera }.forEach { $0.removeFromParent() }
        followCamera.removeAllActions()
        followCamera.setScale(1)
        scenery.removeAllChildren()
        scenery.removeFromParent()
        addChild(scenery)
        candidate = nil
        falling = nil
        placed.removeAll()
        platformNode = nil
        nextIndex = 0
        dropTime = nil
        contactSince = nil
        lastSupportTime = nil
        previousFallingPose = nil
        restingSince = nil
        lastTouchX = nil
        cameraHeight = size.height / 2
        followCamera.position = CGPoint(x: size.width / 2, y: cameraHeight)
        decorateSky()

        // Platform narrows after a couple of successes, not by changing
        // physics behind the player's back. All pieces stay fully dynamic.
        let platformWidth = min(size.width * 0.46, 172)
        let platform = SKShapeNode(rectOf: CGSize(width: platformWidth, height: 19), cornerRadius: 8)
        platform.position = CGPoint(x: size.width / 2, y: baseY)
        platform.fillColor = SKColor(red: 0.35, green: 0.43, blue: 0.63, alpha: 1)
        platform.strokeColor = .white.withAlphaComponent(0.52)
        platform.lineWidth = 2
        platform.zPosition = 3
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platformWidth, height: 19))
        platform.physicsBody?.isDynamic = false
        addChild(platform)
        platformNode = platform

        let halo = SKShapeNode(ellipseOf: CGSize(width: platformWidth + 35, height: 25))
        halo.position = CGPoint(x: size.width / 2, y: baseY - 24)
        halo.fillColor = .cyan.withAlphaComponent(0.09)
        halo.strokeColor = .cyan.withAlphaComponent(0.20)
        halo.zPosition = -1
        addChild(halo)

        spawnNext()
    }

    private func decorateSky() {
        for i in 0..<45 {
            let x = CGFloat((i * 83 + 41) % 997) / 997 * max(size.width, 1)
            let y = CGFloat((i * 137 + 71) % 991) / 991 * 2300
            let dot = SKShapeNode(circleOfRadius: i % 7 == 0 ? 2.2 : 1.1)
            dot.position = CGPoint(x: x, y: y)
            dot.fillColor = .white.withAlphaComponent(i % 3 == 0 ? 0.28 : 0.12)
            dot.strokeColor = .clear
            dot.zPosition = -10
            scenery.addChild(dot)
        }
        for h in stride(from: 250, through: 2300, by: 230) {
            let mark = SKLabelNode(fontNamed: "AvenirNext-Medium")
            mark.text = "✦  \(h / 10) M"
            mark.fontSize = 10
            mark.fontColor = .white.withAlphaComponent(0.22)
            mark.position = CGPoint(x: 44, y: CGFloat(h))
            mark.zPosition = -2
            scenery.addChild(mark)
        }
    }

    private func makePiece(_ kind: Piece, score: Int) -> (SKShapeNode, SKPhysicsBody) {
        let level = CGFloat(min(score, 20))
        let shape: SKShapeNode
        let body: SKPhysicsBody
        switch kind {
        case .block:
            let w = max(35, 63 - level * 1.0)
            let sz = CGSize(width: w, height: 44)
            shape = SKShapeNode(rectOf: sz, cornerRadius: 9)
            body = SKPhysicsBody(rectangleOf: sz)
        case .plank:
            let sz = CGSize(width: max(62, 100 - level * 1.3), height: 17)
            shape = SKShapeNode(rectOf: sz, cornerRadius: 7)
            body = SKPhysicsBody(rectangleOf: sz)
        case .sphere:
            let r = max(19, 29 - level * 0.25)
            shape = SKShapeNode(circleOfRadius: r)
            body = SKPhysicsBody(circleOfRadius: r)
        case .wedge:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -34, y: -24))
            path.addLine(to: CGPoint(x: 34, y: -24))
            path.addLine(to: CGPoint(x: -2, y: 32))
            path.closeSubpath()
            shape = SKShapeNode(path: path)
            body = SKPhysicsBody(polygonFrom: path)
        case .column:
            let sz = CGSize(width: 25, height: 90)
            shape = SKShapeNode(rectOf: sz, cornerRadius: 8)
            body = SKPhysicsBody(rectangleOf: sz)
        case .barrel:
            let sz = CGSize(width: 54, height: 56)
            shape = SKShapeNode(rectOf: sz, cornerRadius: 18)
            body = SKPhysicsBody(rectangleOf: sz)
            body.density = 2.8
        case .tiny:
            let sz = CGSize(width: 32, height: 30)
            shape = SKShapeNode(rectOf: sz, cornerRadius: 6)
            body = SKPhysicsBody(rectangleOf: sz)
        case .diamond:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 34))
            path.addLine(to: CGPoint(x: 32, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -34))
            path.addLine(to: CGPoint(x: -32, y: 0))
            path.closeSubpath()
            shape = SKShapeNode(path: path)
            body = SKPhysicsBody(polygonFrom: path)
        }
        shape.fillColor = colors[(nextIndex + kind.rawValue) % colors.count]
        shape.strokeColor = .white.withAlphaComponent(0.65)
        shape.lineWidth = 3
        shape.glowWidth = 1.2
        let highlight = SKShapeNode(circleOfRadius: 5)
        highlight.fillColor = .white.withAlphaComponent(0.28)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -11, y: 9)
        highlight.zPosition = 2
        shape.addChild(highlight)
        shape.zPosition = 5
        body.friction = kind == .sphere ? 0.36 : 0.60
        body.restitution = kind == .sphere ? 0.12 : 0.025
        body.linearDamping = 0.23
        body.angularDamping = 0.25
        body.usesPreciseCollisionDetection = true
        return (shape, body)
    }

    private func chosenKind(score: Int) -> Piece {
        // Nonrepeating, hard shapes arrive very early; sequence is stable
        // across runs, so players improve skill rather than fight randomness.
        let progression: [Piece] = [
            .block, .wedge, .sphere, .diamond, .column,
            .tiny, .sphere, .barrel, .wedge, .diamond,
            .tiny, .column, .sphere, .plank, .barrel
        ]
        return progression[nextIndex % progression.count]
    }

    func spawnNext() {
        guard initialized, candidate == nil, falling == nil else { return }
        let score = model?.score ?? 0
        let kind = chosenKind(score: score)
        activeDefinition = kind
        let (node, _) = makePiece(kind, score: score)
        let highest = placed.map { $0.position.y + $0.frame.height / 2 }.max() ?? baseY
        let startY = max(baseY + 210, highest + 185)
        node.position = CGPoint(x: size.width / 2, y: startY)
        node.name = "candidate"
        node.alpha = 0
        addChild(node)
        node.run(SKAction.fadeIn(withDuration: 0.22))
        candidate = node
        nextIndex += 1
        model?.announcePiece(kind.title, level: score)
        followPiece()
    }

    private func followPiece() {
        guard let candidate else { return }
        // Candidate remains below top of actual SpriteKit viewport. Bottom
        // SwiftUI controls are not inside this scene at all.
        let target = max(size.height / 2, candidate.position.y - size.height * 0.36)
        cameraHeight = target
        followCamera.removeAction(forKey: "camera")
        let move = SKAction.move(to: CGPoint(x: size.width / 2, y: target), duration: 0.33)
        move.timingMode = .easeInEaseOut
        followCamera.run(move, withKey: "camera")
    }

    func rotateCandidate(degrees: CGFloat) {
        guard model?.canAim == true, let candidate else { return }
        candidate.zRotation += degrees * .pi / 180
        candidate.run(SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08)
        ]))
    }

    @discardableResult
    func commitDrop() -> Bool {
        guard let object = candidate else { return false }
        candidate = nil
        let (_, body) = makePiece(activeDefinition, score: model?.score ?? 0)
        object.physicsBody = body
        object.name = "placed"
        placed.append(object)
        falling = object
        dropTime = nil
        contactSince = nil
        lastSupportTime = nil
        previousFallingPose = nil
        restingSince = nil
        return true
    }

    /// Resting bodies may have no active contact callbacks. Use real
    /// world-space rectangles, rather than action timers or assumed contacts.
    private func isRestingOnSurface(_ piece: SKShapeNode) -> Bool {
        let rect = piece.frame
        let supports = ([platformNode].compactMap { $0 } +
                        placed.filter { $0 !== piece })
        return supports.contains { support in
            let supportRect = support.frame
            let overlap = min(rect.maxX, supportRect.maxX) -
                          max(rect.minX, supportRect.minX)
            let gap = rect.minY - supportRect.maxY
            return piece.position.y > support.position.y &&
                   overlap > 10 && gap >= -12 && gap <= 18
        }
    }

    /// SpriteKit may report no active contacts for bodies that are asleep.
    /// A conservative geometry-based support check provides the missing
    /// resting-contact signal, including for the static floor.
    private func hasGeometricSupport(_ piece: SKShapeNode) -> Bool {
        let frame = piece.calculateAccumulatedFrame()
        let bottom = frame.minY
        let potentialSupports = ([platformNode].compactMap { $0 } + placed.filter { $0 !== piece })
        return potentialSupports.contains { support in
            let other = support.calculateAccumulatedFrame()
            let horizontalOverlap = min(frame.maxX, other.maxX) - max(frame.minX, other.minX)
            let verticalGap = abs(bottom - other.maxY)
            // AABB tests are a fallback only, and require low velocity/dwell
            // before a placement is accepted by DropRules.
            return horizontalOverlap > min(frame.width, other.width) * 0.18 &&
                   verticalGap < 13 && piece.position.y > support.position.y
        }
    }

    private func hasSupportingContact(_ piece: SKShapeNode) -> Bool {
        guard let body = piece.physicsBody else { return false }
        return body.allContactedBodies().contains { other in
            guard let n = other.node else { return false }
            return n !== piece && n.position.y < piece.position.y + 12
        }
    }

    private func finishDrop() {
        guard falling != nil else { return }
        falling = nil
        dropTime = nil
        contactSince = nil
        model?.completedPlacement()
        sparkle()
    }

    private func sparkle() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = ["NICE!", "CLEAN!", "SAVED!", "WOW!"][max(0, (model?.score ?? 1) - 1) % 4]
        label.fontSize = 25
        label.fontColor = .init(red: 1, green: 0.85, blue: 0.55, alpha: 1)
        label.position = CGPoint(x: size.width / 2, y: followCamera.position.y + size.height * 0.18)
        label.zPosition = 50
        addChild(label)
        label.run(.sequence([.group([.moveBy(x: 0, y: 45, duration: 0.65), .fadeOut(withDuration: 0.65)]), .removeFromParent()]))
    }

    override func update(_ currentTime: TimeInterval) {
        guard let phase = model?.phase, phase != .over else { return }
        guard phase == .falling, let object = falling, let body = object.physicsBody else { return }
        if dropTime == nil { dropTime = currentTime }
        let elapsed = currentTime - (dropTime ?? currentTime)

        // Resolve every piece with the same rules. Resting SpriteKit bodies
        // may stop reporting contacts or retain non-zero solver velocities.
        // Observe *visible pose stability* and a genuine supporting surface,
        // rather than waiting indefinitely on contact callbacks.
        let atSurface = isRestingOnSurface(object)
        if let previous = previousFallingPose {
            let displacement = hypot(object.position.x - previous.x,
                                     object.position.y - previous.y)
            let angleChange = abs(object.zRotation - previousFallingAngle)
            if atSurface && displacement < 1.8 && angleChange < 0.045 {
                if restingSince == nil { restingSince = currentTime }
            } else {
                restingSince = nil
            }
        }
        previousFallingPose = object.position
        previousFallingAngle = object.zRotation

        if elapsed >= 1.0 && atSurface &&
           (restingSince.map { currentTime - $0 >= 0.40 } ?? false) {
            finishDrop()
            return
        }
        // Some near-static objects jitter forever by a few points. When a
        // piece remains within the surface landing band for several seconds,
        // recognize it as landed rather than hanging in a disabled UI state.
        if elapsed >= 3.0 && atSurface {
            finishDrop()
            return
        }

        let contactSupported = hasSupportingContact(object)
        let geometrySupported = atSurface || hasGeometricSupport(object)
        let speed = hypot(body.velocity.dx, body.velocity.dy)
        let calm = speed < 26 && abs(body.angularVelocity) < 0.55
        let supported = contactSupported || geometrySupported
        if supported { lastSupportTime = currentTime }
        if elapsed > 0.55 && geometrySupported && calm {
            if contactSince == nil { contactSince = currentTime }
        } else {
            contactSince = nil
        }
        let observation = DropRules.Observation(
            elapsed: elapsed,
            y: object.position.y,
            killY: baseY - 75,
            supported: supported,
            recentlySupported: lastSupportTime.map { currentTime - $0 < 1.2 } ?? false,
            hasPlausibleRestingSupport: geometrySupported,
            linearSpeed: speed,
            angularSpeed: abs(body.angularVelocity),
            calmSupportDuration: contactSince.map { currentTime - $0 } ?? 0
        )
        switch DropRules.decide(observation) {
        case .accepted:
            finishDrop()
        case .missed:
            falling = nil
            model?.failed()
        case .continueFalling:
            if elapsed > 5.5 { model?.updateWaitingStatus() }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchX = touches.first?.location(in: self).x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard model?.canAim == true, let candidate, let touch = touches.first else { return }
        let x = touch.location(in: self).x
        let dx = x - (lastTouchX ?? x)
        candidate.position.x = max(38, min(size.width - 38, candidate.position.x + dx))
        lastTouchX = x
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchX = nil
    }
}
