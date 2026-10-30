# Implementation Status — Stackcident
**2026-10-29 | Prototype 0.1 | NOT compiled or device-tested**

## Added to `main`
- `project.yml`: XcodeGen native iPhone app project specification.
- `StackcidentApp/App/StackcidentApp.swift`: SwiftUI app entry.
- `StackcidentApp/App/ContentView.swift`: playable HUD and controls.
- `StackcidentApp/Game/GameModel.swift`: game state, scoring, charges, restart.
- `StackcidentApp/Game/TowerScene.swift`: initial SpriteKit live-world gravity and collision prototype.
- `StackcidentApp/Info.plist`: app metadata.
- `StackcidentTests/GameModelTests.swift`: starting test.
- `README.md`: setup and limitation notes.

## Implementation limitations
- **Future Vision is not yet enabled.** No prediction is faked; charges are not consumed. Next stage is an independent step-able physics engine or proven SpriteKit cloning mechanism.
- Current live-world physics is an exploratory SpriteKit prototype, not a validated deterministic/snapshot-capable engine.
- Settlement and loss detection are provisional heuristics; tall, wobbly towers and rotated bounding boxes need correctness improvements.
- Object visuals are simple rectangles, not final art.
- Touch controls, game transitions, launch setup, code signing and UI tests need physical iPhone checks.
- Source has been committed, but no Xcode/macOS build is available in the current execution environment.

## Next gates
1. Generate the Xcode project using XcodeGen; compile and repair any Xcode diagnostics.
2. Install on a physical iPhone, verify dragging, rotation, collisions, scoring and restart.
3. Write engine ADR; select a controllable solver with native iOS-compatible integration.
4. Replace the prototype live simulation with solver-driven live and preview worlds.
5. Create world snapshot tests, trajectory recorder, ghost playback, risk labels and prediction charge tests.
6. Benchmark parity, latency, memory and gameplay stability on real devices.
7. Move to visual polish and content only after physics proof succeeds.

See [physics-engine.md](physics-engine.md) and [requirements.md](../requirements.md) for acceptance contracts.
