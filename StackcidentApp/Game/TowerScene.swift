import SpriteKit

/// Native iOS SpriteKit vertical slice. Physics is real, but Future Vision still
/// requires the separate snapshot-capable simulation engine described in docs.
@MainActor
final class TowerScene: SKScene {
    weak var model: GameModel?

    private let worldCamera = SKCameraNode()
    private var candidate: SKShapeNode?
    private var activeDropped: SKShapeNode?
    private var placed: [SKShapeNode] = []
    private var floor: SKShapeNode?
    private var lastTouchX: CGFloat?
    private var dropStarted: TimeInterval?
    private var stableSince: TimeInterval?
    private var nextIndex = 0
    private var cameraCenterY: CGFloat = 0
    private var initialized = false

    private let floorY: CGFloat = 98
    private let palette: [SKColor] = [
        .init(red: 1, green: 0.70, blue: 0.28, alpha: 1),
        .init(red: 0.35, green: 0.87, blue: 0.80, alpha: 1),
        .init(red: 0.99, green: 0.39, blue: 0.49, alpha: 1),
        .init(red: 0.67, green: 0.48, blue: 0.99, alpha: 1),
        .init(red: 0.99, green: 0.83, blue: 0.34, alpha: 1)
    ]

    private enum ShapeKind: Int {
        case crate, ball, plank, wedge, tall, heavy
    }

    override func didMove(to view: SKView) {
        guard !initialized else { return }
        initialized = true
        backgroundColor = SKColor(red: 0.06, green: 0.075, blue: 0.14, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -12.5)
        addChild(worldCamera)
        camera = worldCamera
        resetWorld()
    }

    func resetWorld() {
        children.filter { $0 !== worldCamera }.forEach { $0.removeFromParent() }
        worldCamera.removeAllActions()
        candidate = nil
        activeDropped = nil
        placed.removeAll()
        floor = nil
        lastTouchX = nil
        dropStarted = nil
        stableSince = nil
        nextIndex = 0
        cameraCenterY = size.height / 2
        worldCamera.position = CGPoint(x: size.width / 2, y: cameraCenterY)

        let width = min(size.width * 0.66, 255)
        let base = SKShapeNode(rectOf: CGSize(width: width, height: 20), cornerRadius: 7)
        base.fillColor = SKColor(red: 0.37, green: 0.49, blue: 0.67, alpha: 1)
        base.strokeColor = .white.withAlphaComponent(0.35)
        base.lineWidth = 2
        base.position = CGPoint(x: size.width / 2, y: floorY)
        base.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: 20))
        base.physicsBody?.isDynamic = false
        base.name = "platform"
        addChild(base)
        floor = base

        let line = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
        line.position = CGPoint(x: size.width / 2, y: floorY - 70)
        line.fillColor = .systemRed.withAlphaComponent(0.24)
        line.strokeColor = .clear
        addChild(line)
        spawnNext()
    }

    private func shape(for kind: ShapeKind, difficulty: Int) -> (SKShapeNode, SKPhysicsBody) {
        let level = min(difficulty, 12)
        let shrink = CGFloat(min(level, 8)) * 1.35
        let path: CGPath
        let body: SKPhysicsBody
        let node: SKShapeNode

        switch kind {
        case .ball:
            let radius = max(19, 30 - shrink * 0.42)
            node = SKShapeNode(circleOfRadius: radius)
            body = SKPhysicsBody(circleOfRadius: radius)
        case .plank:
            let w = max(66, 104 - shrink)
            let h: CGFloat = 19
            node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 3)
            body = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
        case .wedge:
            let w = max(40, 75 - shrink)
            let h: CGFloat = 51
            let p = CGMutablePath()
            p.move(to: CGPoint(x: -w/2, y: -h/2))
            p.addLine(to: CGPoint(x: w/2, y: -h/2))
            p.addLine(to: CGPoint(x: w/4, y: h/2))
            p.closeSubpath()
            path = p
            node = SKShapeNode(path: path)
            body = SKPhysicsBody(polygonFrom: path)
        case .tall:
            let w: CGFloat = 30
            let h = 78 + CGFloat(level) * 1.5
            node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 4)
            body = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
        case .heavy:
            let w: CGFloat = 58
            let h: CGFloat = 52
            node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 9)
            body = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
            body.density = 3.2
        case .crate:
            let w = max(35, 66 - shrink)
            let h: CGFloat = 46
            node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 6)
            body = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
        }

        node.fillColor = palette[(nextIndex + kind.rawValue) % palette.count]
        node.strokeColor = .white.withAlphaComponent(0.60)
        node.lineWidth = 2.5
        node.glowWidth = 0.5
        body.friction = kind == .ball ? 0.42 : 0.65
        body.restitution = kind == .ball ? 0.14 : 0.03
        body.linearDamping = 0.16
        body.angularDamping = 0.19
        body.allowsRotation = true
        body.usesPreciseCollisionDetection = true
        return (node, body)
    }

    func spawnNext() {
        guard initialized, candidate == nil, activeDropped == nil else { return }
        let score = model?.score ?? nextIndex
        let kinds: [ShapeKind] = score < 2 ? [.crate, .plank] :
            score < 5 ? [.crate, .plank, .wedge, .ball] :
            [.ball, .wedge, .tall, .heavy, .plank, .crate]
        // Deterministic variety from a lightweight, non-random object sequence.
        let index = (nextIndex * 7 + nextIndex / 3) % kinds.count
        let kind = kinds[index]
        let (node, _) = shape(for: kind, difficulty: score)
        candidateKind = kind
        let highest = placed.map { $0.position.y + $0.frame.height / 2 }.max() ?? floorY
        node.position = CGPoint(x: size.width / 2, y: max(floorY + 220, highest + 145))
        node.name = "candidate"
        addChild(node)
        candidate = node
        nextIndex += 1
        followCandidate(animated: true)
    }

    private func followCandidate(animated: Bool) {
        guard let candidate else { return }
        // Keep spawn near the upper third while the visible tower stays below.
        let desired = max(size.height / 2, candidate.position.y - size.height * 0.24)
        cameraCenterY = desired
        worldCamera.removeAction(forKey: "follow")
        let destination = CGPoint(x: size.width / 2, y: desired)
        if animated {
            let move = SKAction.move(to: destination, duration: 0.38)
            move.timingMode = .easeInEaseOut
            worldCamera.run(move, withKey: "follow")
        } else {
            worldCamera.position = destination
        }
    }

    func rotateCandidate(degrees: CGFloat) {
        guard let candidate, model?.canAim == true else { return }
        candidate.zRotation += degrees * .pi / 180
    }

    func commitDrop() {
        guard let candidate else { return }
        self.candidate = nil
        let score = model?.score ?? 0
        let kind = inferredKind(for: candidate)
        // Use the authored local physics shape, never the rotated frame bounding box.
        let (_, body) = shape(for: kind, difficulty: score)
        body.affectedByGravity = true
        candidate.physicsBody = body
        candidate.name = "placed"
        placed.append(candidate)
        activeDropped = candidate
        dropStarted = nil
        stableSince = nil
    }

    // The candidate's shape is recorded at spawn, so its collision geometry
    // never depends on the transformed bounding box after rotation.
    private var candidateKind: ShapeKind = .crate

    private func inferredKind(for node: SKShapeNode) -> ShapeKind {
        candidateKind
    }

    override func update(_ time: TimeInterval) {
        guard model?.phase == .falling else { return }
        if dropStarted == nil { dropStarted = time }
        let elapsed = time - (dropStarted ?? time)
        let lost = placed.contains { node in
            node.position.y < floorY - 84 ||
            abs(node.position.x - size.width / 2) > size.width * 0.68
        }
        if lost {
            model?.failed()
            activeDropped = nil
            return
        }
        guard let current = activeDropped, let body = current.physicsBody else { return }
        let speed = hypot(body.velocity.dx, body.velocity.dy)
        let slow = speed < 12 && abs(body.angularVelocity) < 0.22
        if elapsed > 0.85 && slow {
            if stableSince == nil { stableSince = time }
            if time - (stableSince ?? time) > 0.42 {
                activeDropped = nil
                dropStarted = nil
                stableSince = nil
                model?.completedPlacement()
            }
        } else {
            stableSince = nil
        }
        if elapsed > 9 { model?.failed(); activeDropped = nil }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchX = touches.first?.location(in: self).x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard model?.canAim == true, let candidate,
              let touch = touches.first else { return }
        let nextX = touch.location(in: self).x
        let dx = nextX - (lastTouchX ?? nextX)
        candidate.position.x = max(40, min(size.width - 40, candidate.position.x + dx))
        lastTouchX = nextX
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchX = nil
    }
}
