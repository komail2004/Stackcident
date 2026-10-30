# Stackcident

**Native iOS/iPhone physics stacking game — prototype 0.1.** Drop precarious objects, build a tower, and ultimately preview possible futures with **Future Vision**.

## Current implementation
- Native SwiftUI iOS shell, SpriteKit physics playfield
- Drag horizontally to aim; rotate in 15-degree steps; explicit DROP
- Simple drop/settle/loss loop, score and locally persisted best score
- Retry, user-facing status and initial unit test
- **Future Vision is NOT implemented yet.** The button tells the truth and does not debit charges. Accurate preview requires a separate, controlled, step-able physics solver with proven parity.
- No accounts, servers, ads or network services

## Run locally on macOS
1. Install Xcode and command-line tools.
2. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) using `brew install xcodegen` (or its official installation instructions).
3. Clone the repository and run `xcodegen generate` at the repository root.
4. Open `Stackcident.xcodeproj` in Xcode.
5. Select an iPhone simulator, choose signing team for a real device if needed, and press Run. Run the `StackcidentTests` scheme/tests through Xcode.

> **Not compiled or device-tested yet in this environment.** The project generator is used so its configuration is version-controlled without checking in hand-authored .pbxproj internals. The iOS 17.0 deployment target and bundle identifier are **provisional**. Resolve code signing and update settings before App Store distribution.

## Design documents
- [Overview](overview.md)
- [Requirements](requirements.md)
- [Architecture](docs/architecture.md)
- [Physics & Future Vision](docs/physics-engine.md)

## Next engineering milestone
1. Choose and integrate a controlled 2D physics solver for **both** live and preview worlds.
2. Implement fixed stepping, complete world snapshots and distinct isolated preview world.
3. Generate trajectory frames and translucent ghost playback.
4. Measure preview-to-actual parity and latency on a real iPhone before enabling predictions.

The current SpriteKit-based live prototype is deliberately **not** advertised as accurate future prediction.


## Update notes — 2026-10-30

Native iPhone prototype now has an in-app animated splash, a Start Game menu, How to Play, a score/best tracker, and a challenging geometric object sequence. For each drop, a dedicated `DropRules.swift` policy decides whether the object is supported, still falling, or has physically missed. Its XCTest coverage is in `StackcidentTests/DropRulesTests.swift`.

**Pull in Xcode:** `git pull origin main`; regenerate with `xcodegen generate` if you have not done so since the new Swift files were added, then open `Stackcident.xcodeproj`, build with Cmd+B, run with Cmd+R, and test with Cmd+U.

**Must verify on-device:** splash → Start Game → Drop → next piece → miss → Retry → Home; wedge and ball physics, tall-stack camera framing, no phantom game-over, no unsupported false score, and lifecycle transitions. Xcode compilation and device tests have not been run by the assistant. **Future Vision is still disabled** pending a same-engine separate-world physics implementation and accuracy proof.


## 2026-10-30 — Physics stabilization rebuild

Repeated iPhone Simulator screenshots showed unsupported/incorrect game-over, stacked objects shaking, and the drop controls getting stuck. The scene was restructured rather than patched with additional timeouts.

- One explicit static platform collider and explicit piece/platform collision masks.
- Each object has a physics body authored once, with its final geometry reused at release.
- Physics is sampled in \`didSimulatePhysics\` after SpriteKit advances the world.
- A single pure \`DropRules\` system handles every object, including the first and second drops.
- A piece scores only when near physical support and motion is low for a dwell period. No timer-only loss.
- Visible loss messaging now describes a piece falling below the platform.
- Mass and gravity are tuned for an iPhone-sized SpriteKit scene, with dynamic pieces retained.
- Tests and manual reproduction steps: [iOS QA Smoke Checklist](docs/qa-smoke-checklist.md).

**Still unverified on device:** The assistant cannot execute Xcode/Simulator here. Do not interpret committed code as a passing device build. Check [GitHub Actions](https://github.com/komail2004/Stackcident/actions), then run the smoke tests locally. Future Vision remains intentionally inactive.
