# Physics stabilization smoke test — 2026-10-30

**Scope:** iPhone-only Stackcident prototype. **Status:** source implemented, Xcode/Simulator tests must still be executed on the user's Mac.

## Why we rewrote the scene

Earlier versions combined a first-drop landing-zone exception, contact callbacks, shape-frame guesses, per-piece action watchdogs, rapidly changing damping values and multiple timeouts. Screenshots showed false losses, endless "Checking that landing", excessive wobble, and pieces apparently missing the starting platform. The screenshots are valid bug reports, but they do not establish precisely why SpriteKit failed to collide or score on each attempt.

We replaced the layered workarounds with one scene and one pure decision policy. This is a **prototype stabilization**, not the completed precision-clone physics engine required by Future Vision.

## As-built invariants

1. The blue platform is a static SKPhysicsBody with explicit \`platform\` category, \`piece\` collision bit, and zero restitution.
2. Each falling piece uses **one** physics body created with its visual geometry before release; no second/mismatched body is constructed when the player presses DROP.
3. Every piece declares \`piece\` category, collision with platform and other pieces, and precise collision detection.
4. \`didSimulatePhysics()\` evaluates landing after SpriteKit's physics step, not before it.
5. A piece is grounded only when its **world-space** bounds are close to a lower support surface with meaningful horizontal overlap.
6. A genuinely grounded and low-motion piece must remain stable for a short interval before scoring. A slow supported piece can be recovered from solver jitter after three seconds.
7. Elapsed time alone never causes loss or success. A missed piece must fall below the world-space kill line.
8. Only the currently falling object can resolve or trigger the current drop's loss. Previous placed objects can move, roll or collide.
9. Score increments exactly once per accepted drop; accepted and missed are mutually exclusive state transitions.
10. The UI explicitly says when a piece misses the platform, rather than only showing a generic joke.
11. The scene retains dynamic physics bodies after settling to preserve interactive collapses.
12. Future Vision remains disabled until isolated-world simulation parity is implemented and validated.

## Run the real iOS smoke test

On the Mac:

\`\`\`bash
cd ~/Documents/Stackcident
git pull origin main
xcodegen generate
open Stackcident.xcodeproj
\`\`\`

Then Xcode: **Product → Clean Build Folder**, **Command+B**, **Command+U** (tests), **Command+R** (launch).

### Required manual cases

| Test | Steps | Expected |
|---|---|---|
| S-01 | Launch cold | Splash then main menu, no blank screen |
| S-02 | Start Game | Platform, candidate, score 0, enabled DROP |
| S-03 | Center first crate | Piece collides with platform, settles, score 1 |
| S-04 | Center second wedge | Wedge collides with crate/platform, score 2 on a stable landing |
| S-05 | Drop third sphere carefully | Ball can roll realistically, without passing through platform |
| S-06 | Drop far outside platform | Piece falls below real kill line, game over with clear explanation |
| S-07 | Leave block wobbling on support | No instant phantom game over |
| S-08 | Drop 10+ pieces | Camera follows stack; controls never overlap playfield |
| S-09 | Double-tap DROP rapidly | Only one physical body committed |
| S-10 | Restart after failure | No old bodies remain; score 0, three vision charges |
| S-11 | Home then Start | Fresh scene, controls functional |
| S-12 | Background then foreground | No phantom drop or corrupted score |
| S-13 | Airplane Mode | Core game and local best work without network |
| S-14 | Test on physical iPhone | Frame rate, touch, memory and audio/haptics profiled separately |

## When a bug remains

Capture the **first Xcode issue**, the **first relevant console exception**, or a short screen recording. For physics bug reproduction, record which piece index was being placed, where it was dropped, whether the object passed through or rolled away, the displayed score, and the elapsed seconds.

The implementation has no verified real-device performance data and uses SpriteKit frame-based support detection, which remains approximate for complicated shapes. If it cannot reliably satisfy S-03 through S-06, escalate to replacing live physics with the controllable single-solver architecture documented in \`physics-engine.md\`, rather than reintroducing shape-specific magic timers.

## CI status

The repo contains \`.github/workflows/ios.yml\`, which is intended to build and test on an iOS Simulator. Workflow success must be checked in GitHub Actions; commit status returned no confirmed passing checks at the time of this document.
