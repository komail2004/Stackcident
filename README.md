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
