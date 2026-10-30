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

## 2026-10-30 — Repository audit, rule extraction and documentation reconciliation

**Committed to `main`:** identified and removed an undeclared `wasReleasedBelowSpawn` reference that could prevent compiling. Extracted `DropRules.swift` from the SpriteKit scene and made it the decision source for accepted, missed, and continuing drops. Added `DropRulesTests.swift` covering actual lower-bound loss, false wobble loss, supported dwell, recently supported grace, stationary airborne no-score, and fallback near supports. Adjusted GameModel to avoid spamming the same waiting status and provide playful success/failure lines.

**Presentation already in repository:** native splash after iOS launch, menu/Start Game, How to Play sheet, SwiftUI HUD, Game Center-free local best score, starry SpriteKit world with geometric challenge pieces, a narrow platform, and camera following the tower. These are currently source-implemented features; no verified device run has been provided for this revision.

**Documentation updated in the same sequence:** `overview.md`, `requirements.md`, `docs/architecture.md`, `docs/physics-engine.md`, and `README.md`. Requirement status and known prototype-vs-production differences are now explicit.

**Remaining important risks:** SpriteKit contact support detection is approximate and can misread edge contacts; some midair/edge cases may still require resolution. Current score and difficulty are untested with players. There are no physical test reports, build logs, code signing results, snapshot-capable solver, or genuine Future Vision yet.

**Mandatory next validation in Xcode:** `git pull origin main && xcodegen generate`, then Cmd+B, Cmd+U, Cmd+R. Run 10 normal drops, off-edge miss, rapid tapping, repeated Retry, home→start, tall tower camera, and background/foreground behavior. Fix observed build/scene failures before attempting larger visual refactors or claiming polished production quality.

**Technical next step after validation:** prototype a single step-able 2D solver reused by live and preview worlds, define state cloning and record parity measurements. Do not fake future replay or enable prediction tokens prematurely.

## 2026-10-30 — Screenshot-confirmed stalled first drop

**Reported:** The first red crate visibly comes to rest on the blue static platform at score 0, but the UI stays on “Checking that landing…” with Drop disabled.

**Cause in source:** The only normal support signal was `allContactedBodies()`; SpriteKit can return an empty set for resting/sleeping bodies. The previous geometry fallback checked only previously placed blocks and **excluded the floor**, so the first block had no fallback support. Waiting was therefore indefinitely reachable despite a valid landing.

**Fix committed:** `TowerScene` retains the static platform node and introduces an AABB-based geometry support fallback checking the platform **and** previous pieces, requiring horizontal overlap, near-touching vertical surfaces and a lower support. Geometric support is accepted only if the object has low linear/angular velocity. Existing dwell and rule checks then resolve scoring. The actual drop still fails only after crossing the lower kill boundary. Added regression tests for a resting supported first object and rejecting fast unsupported movement.

**Caveat:** SpriteKit world AABBs and body-center comparisons are an approximate gameplay prototype, especially for rotated/concave objects. Before claiming reliable physics or Future Vision, replace or strengthen with contact-normal support graphs and measure on actual iPhone. Xcode build/XCTest/Simulator run must still be executed on the user's Mac.

**Test:** Pull main, Cmd+B, Cmd+U, Cmd+R; center first crate and wait ~1–2 seconds: score should increment and next piece spawn. Test off-platform miss, wedge edge, 10 pieces, retry, home→restart.

## 2026-10-30 — Build/launch investigation following reported app launch failure

**Status:** Source-only audit. The user's exact Xcode error / crash log was not provided, so the precise cause cannot be confirmed. Avoid calling this a verified working build until a successful compile, XCTest run and simulator launch are observed.

**Changes made:**
- `project.yml`: removed conflicting generated-Info.plist setting while retaining the explicitly declared Info.plist; removed AppIcon reference without an asset catalog; omitted empty development team.
- `StackcidentApp/Info.plist`: normalized required native iOS bundle metadata, executable/package keys, portrait orientation and launch-screen declaration; incremented prototype build version.
- `.github/workflows/ios.yml`: new macOS GitHub Actions pipeline to install XcodeGen, generate the Xcode project, build for iOS Simulator, and run XCTest on an available iPhone Simulator.
- Existing UIKit/SwiftUI/physics source, splash, menu and game content otherwise preserved.

**Next verification order:** `git pull origin main`, `xcodegen generate`, Xcode Product > Clean Build Folder, Cmd+B, Cmd+U, Cmd+R. If the build fails, capture the **first compiler error** in the Xcode Issue navigator; if it installs but closes, capture Debug console exception and crash report; if it displays a blank screen, verify RootView splash→menu route and SpriteKit scene lifecycle. Actions CI URL: https://github.com/komail2004/Stackcident/actions

**Do not infer:** CI success before a real run, full App Store compatibility, or Future Vision readiness. The current physics solver is still a prototype.

## 2026-10-30 — Persistent first-drop hang, independent watchdog

Screenshot at 3:07 PM confirms app launches and renders the red block on blue floor, yet score remains zero and primary control remains disabled. This invalidates assumptions that the prior contact+velocity fix was sufficient. Source change adds an independent SpriteKit action watchdog associated with the released piece, checking geometric resting support against the platform and other placed objects at 1.75 seconds and again every 0.6 seconds while unresolved. It resolves only a visibly resting/overlapping surface within a 24-point geometry tolerance; a piece below the real kill boundary still loses. The normal update-loop classification remains as a faster path.

**Source committed, no execution evidence.** If this still hangs, inspect whether the scene's SpriteKit actions and update ticks are running; capture Xcode console, pause debugger, and inspect `TowerScene.falling`, scene `isPaused`, `speed`, platform bounds, and current drop state. Do not declare verified until physical simulator test demonstrates score advancing from 0 to 1.

## 2026-10-30 — SIGTERM screenshot and landing-watchdog rollback

The Xcode screenshot shows `Thread 1: signal SIGTERM` at `mach_msg2_trap` inside libsystem_kernel. **This alone is not proof of a Swift crash**: SIGTERM is a termination signal, commonly observed if the debug session or simulator application is stopped externally. The screenshot does not include a Swift exception, a failing source line, or a crash backtrace.

The preceding source revision introduced a repeating per-object SKAction landing watchdog. This was unnecessary complexity alongside `SKScene.update` and does not prove the underlying physics-state problem is fixed. Removed that recursive action mechanism. Grounding is now sampled directly in `update` using world-space shape-frame overlap and bottom-to-support-top gap, with the existing low-motion dwell requirement in `DropRules`. The same real kill boundary remains authoritative for loss.

**Next required evidence:** In Xcode, pull main, Clean Build Folder, build and run; do not press Stop while examining the app. If it pauses, inspect the Debug navigator console and the first meaningful Swift/Objective-C exception. If it hangs again, set a breakpoint in `TowerScene.update`, inspect `geometrySupported`, `speed`, `contactSince`, `elapsed`, and whether `model?.phase` is `.falling`. Actual iPhone test and XCTest remain unverified. No further visual polish should be layered over unresolved launch/landing defects.
