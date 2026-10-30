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

## 2026-10-29 — Gameplay and viewport iteration (source committed; Xcode verification pending)

User testing on iPhone 17 Pro Simulator showed that the previous tower and candidate overlapped bottom SwiftUI controls and difficulty barely increased.

Changes committed to `main`:
- Split the iPhone screen into a separate title bar, flexible clipped SpriteKit playfield and an opaque bottom control panel. Gameplay no longer renders beneath the DROP button.
- Introduced `SKCameraNode` following tower growth in world coordinates rather than allowing the stack to disappear under controls.
- Added six physics-backed shape families: crates, planks, wedges, balls, tall thin objects and heavy blocks; later scores unlock less forgiving shapes.
- Added density/friction/restitution variation and more aggressive gravity to make shape choices matter.
- Created physics bodies from their authored local geometry instead of using rotated node frame bounding boxes.
- Added an explicit danger line and checks for fallen pieces even during aiming, with a restart path.
- Refined score/status, controls, compact typography, and the primary action state (DROP IT! / TRY AGAIN).

**Remaining shortcomings:** These are prototype source changes, not yet compiled/tested on the user's Mac. SpriteKit physics is not prediction-parity capable as-is. Future Vision remains deliberately disabled rather than faked. Level tuning, contact detection, stability, camera limits, accessibility and camera behavior across device sizes still require simulator and physical-iPhone review.

**To test:** In the cloned repository run `git pull origin main`, open the existing Xcode project, build/run; generate Xcode project only if project.yml changed. Report compiler diagnostics or gameplay footage for corrections.

## 2026-10-29 — Arcade polish and dropped-object correctness pass

User reported low difficulty, placeholder visuals, indefinite “waiting” states, and false game-over.

Code changes:
- Replaced unreliable velocity-only settling with physical contact + dwell checks and a forgiving, bounded supported-placement resolution path.
- Removed the previous hard-coded 8/9 second automatic **game over** timeout.
- Restricted failure checks to a clearly missed **currently falling** object instead of shifting pieces from earlier successful placements.
- Made `GameModel.drop()` advance to falling only if the SpriteKit scene actually accepted a drop.
- Rebuilt the object progression around eight mechanical silhouettes, with a sphere on the second drop, narrow/awkward objects and diamond, column, barrel and tiny variants.
- Added starry background, altitude markers, platform glow, bright outlined shapes, arrival fades, success popups and a tracking camera.
- Polished native SwiftUI header, stage labels, translucent banner, gradient buttons, spacing and disabled states.
- Added unit checks for failed drop dispatch, stage labels, and preventing invalid score increments.

Still unverified: Xcode build on user's Mac, simulator/device gameplay, edge-case contact physics, fair difficulty, actual Future Vision (still intentionally unavailable).

Manual test checklist: drop a centered crate; drop a sphere; make an off-edge miss; tilt a wedge; complete 10 drops; test immediately after Retry; drag at both extremes; validate no unexpected game-over from a previously placed body; check UI and FPS on iPhone 17 Pro simulator. Send exact compiler diagnostics if build fails.

**Physics limitation:** SpriteKit contact checks and timeouts remain prototype heuristics, not the deterministic authoritative solver committed to in the architecture docs.
