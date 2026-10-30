# Stackcident — OVERVIEW
**Master Game Design Document (GDD) & Technical Product Specification**  
**Version:** 1.0 — Concept baseline  
**Status:** Pre-production; proposed design, not yet implemented  
**Platform:** iPhone first (iOS); iPad optional after validation  
**Project:** Stackcident  
**Tagline (working):** *See the fall. Change the fate.*

> **North star:** Stackcident is a playful, physics-driven stacking game in which an ordinary drop can become a ridiculous disaster. Its signature mechanic, **Future Vision**, lets players spend a limited resource to simulate a possible drop before committing. The player is not simply stacking taller; they are making calculated, hilarious decisions under increasing instability.

---

## 1. Executive vision

### 1.1 What the player does
The player is presented with a platform, an existing stack, and a sequence of quirky objects. They drag an object horizontally, rotate it with a deliberate control, and release it. Gravity, contact forces, friction, rotation, and collisions determine the result. The player tries to keep the tower alive as long as possible.

The game adds an unusual strategic instrument: a limited number of **Future Vision** charges. At any supported moment before release, the player can preview a short simulated future. A transparent “ghost” version of the selected object falls onto a simulated copy of the current tower. The simulation may show the object settling, wobbling, slipping, or setting off a cascade. The real tower is untouched by this preview. The player then decides whether to reposition, rotate, or risk a drop.

### 1.2 Player fantasy
“I barely saved a ridiculously crooked tower because I saw disaster coming—and then I made something even crazier.”

### 1.3 Non-goals
- Not a realistic civil engineering simulator.
- Not a gambling or wagering product.
- Not a generative-AI chat companion dressed as a game.
- Not a pay-to-win leaderboard.
- Not a server-dependent game at launch.
- Not a production-ready product until physics consistency is actually measured.

### 1.4 Core values
1. **Immediate clarity:** a player understands the first drop in seconds.
2. **Physical fairness:** failures have legible causes, not arbitrary surprises.
3. **Joyful chaos:** surprising outcomes should be funny rather than confusing.
4. **Meaningful prediction:** Future Vision reveals a useful simulated possibility.
5. **Short loops, deep mastery:** instant replay and gradually richer strategic decisions.
6. **Offline first:** a full single-player game works without an account or internet.
7. **Accessible by design:** readable contrast, reduced motion, haptic/sound alternatives, and one-handed-friendly controls.

---

## 2. Target audience, positioning, and commercial hypothesis

### 2.1 Audience
- Primary: casual mobile players who enjoy quick, skill-based arcade and physics puzzle games.
- Secondary: people who like shareable funny failures, daily challenges, and beating personal bests.
- Tertiary: puzzle-oriented players attracted to testing “what if?” outcomes.

### 2.2 Pitch
**One sentence:** *Stack ridiculous objects into an impossible tower—and peek into the future before your next mistake.*

**App Store subtitle candidate:** *Stack. Predict. Survive.* (Subject to title/subtitle limits, trademark and App Store review.)

### 2.3 Differentiation hypotheses
- Transparent, animated, physically simulated previews instead of a generic “safe/unsafe” icon.
- Objects selected for surprising weight distribution and collisions, not just visual novelty.
- Distinct challenge modes designed around scarce prediction charges.
- Shareable, short collapses with clean replay.
- No mandatory login or ads in the core prototype.

These are **hypotheses**, not verified gaps in the App Store. Competitive, naming, and trademark research are release gates.

### 2.4 Desired emotional rhythm
Anticipation → placement → suspense → impact → wobble or catastrophe → delighted reaction → immediate retry.

---

## 3. Complete gameplay specification

### 3.1 Basic round
1. Enter round; see base platform and zero or more existing objects.
2. Reveal next object, including a silhouette, weight cue, and rotation handles.
3. Player moves object left/right and optionally rotates it.
4. Optional: use Future Vision, see its result, and adjust intended placement.
5. Player confirms the drop using a clear release action.
6. World simulates settling for a bounded interval or until motion thresholds are low.
7. If validly supported: score rises, a brief reaction plays, and next object arrives.
8. If the loss condition triggers: freeze/resolve, show score, offer replay and immediate restart.

### 3.2 Basic controls
**Portrait orientation, touch-first.**
- Drag horizontally to choose horizontal placement.
- Separate on-screen rotate buttons or a two-finger twist (optional accessibility alternative), with controlled increments.
- A large **DROP** button to commit; avoid accidental releases.
- A **FUTURE VISION** button showing remaining charges.
- Pause, mute and reduced-motion controls.
- Optional haptics: subtle during alignment, sharp on impact, celebratory on save.
- Never require a tiny precise touch target for basic gameplay.

**Design decision for v1:** use explicit DROP, not lift-to-drop. This separates placement from release and makes Future Vision predictable.

### 3.3 Camera and scene
- 2D side-view, portrait aspect ratio.
- Fixed floor/base with side boundaries as needed for readability.
- Camera follows tower height with smooth, clamped vertical scrolling.
- Visible “danger line” or floor loss zone; no camera tricks that hide imminent collision.
- All gameplay collision shapes must match visual expectations reasonably well.

### 3.4 Object system
Each object has:
- Stable unique object ID.
- Visual sprite or vector art.
- Physics collision shape(s), mass/density, friction, restitution, angular damping, linear damping.
- Center of mass and optional special balancing feature.
- Bounding dimensions and allowable spawn pose/angle.
- Difficulty tier and unlock status.
- Sound/haptic profile and an optional humorous short name.

**Initial content target:** 15–25 carefully tuned objects, not a procedural infinity of untested shapes.

**Suggested initial families:**
- Box, book, slab, cylinder, sphere.
- Toaster, rubber duck, teacup, sofa, washing machine.
- Banana-like curve, bowling ball, wheel, awkward wedge, toy piano.

Use whimsical art with collision geometry that is transparent to players. Avoid tiny, overly complex concavities that make physics expensive and hard to understand.

### 3.5 Scoring
Proposed **v1 simple scoring**:
- +1 for each valid placed object after settling.
- A separate “tower height” statistic.
- Best survival run as principal leaderboard measure.

Later experiments:
- Stylish balance bonuses for narrow footprints.
- “Miracle save” bonus for dramatic recovery.
- Combo score for consecutive risky successes.
- Daily challenge score combining objects survived and fewest visions used.

**Fairness rule:** If an advantage is acquired through payment, keep that run off equivalent competitive leaderboards; do not sell leaderboard-winning charges.

### 3.6 Loss conditions
A run ends when one or more of:
- A defined number of non-debris stack objects fall beyond floor/base bounds.
- The newly dropped object is irrecoverably lost.
- The core supported structure collapses past an explicit threshold.
- A challenge-specific objective fails.

**Important:** specify and test exact rules. A single decorative object clipping an edge should not arbitrarily end a run. After instability, allow a short settling window before declaring loss.

### 3.7 Difficulty progression
Difficulty should grow through legible properties:
- Smaller supporting surfaces.
- Odd centers of mass.
- Taller towers and lever arms.
- Rotating/rolling objects.
- Challenging yet viable object sequences.
- Fewer free prediction charges in advanced modes.

Do **not** secretly change object friction, gravity, or collision response mid-run to force failure. A player's skill must matter.

### 3.8 Modes and roadmap
**MVP**
- Endless Classic.
- Future Vision with limited charges.
- Local personal best and stats.
- Pause/restart, audio/haptics settings.
- On-device tutorial.

**After retention validation**
- Daily Seed: identical object sequence and starting conditions for everyone.
- Puzzle Trials: win with constrained pieces and a fixed number of predictions.
- Challenge Collection: unusual platforms or themed object sets.
- Optional Game Center leaderboards and achievements.
- Replay/export for big collapses.

**Long-term possibilities**
- Ghost challenge: compare against a prerecorded run.
- Multiple future branches.
- Workshop/custom challenge seeds with appropriate moderation safeguards if sharing content.
- Cosmetic environments and unlockable object sets.

---

## 4. Signature system: Future Vision

### 4.1 Player-facing promise
“Before dropping, spend one vision to watch a possible outcome of this exact placement.”

The word **possible** is intentional until we have measured and verified deterministic agreement.

### 4.2 Interaction sequence
1. Player has an object selected, positioned, and rotated.
2. Tap Future Vision.
3. The game captures a **complete world snapshot**.
4. A separate simulation is created from the snapshot.
5. A virtual copy of the new object drops under equivalent conditions.
6. Simulation advances a specified horizon (initial target 2.0–3.0 seconds).
7. Result is recorded as sampled poses and an outcome classification.
8. The live game remains paused/unchanged.
9. The game overlays a semi-transparent ghost replay, a compact risk label, and an explicit “Simulation” legend.
10. Player may reposition/reorient and commit a real drop. A changed pose invalidates the old preview.

### 4.3 Charges and economy
**MVP proposal:** three predictions per run. One charge is spent when a simulation result is successfully presented. Do not charge if the simulation fails or is cancelled by the application.

Important questions for playtests:
- Is three enough to create interesting choices?
- Should all charges be available immediately?
- Should challenges reward unused charges?
- Do unlimited previews make the game too easy or less fun?

**Do not** sell consumable predictions in competitive modes during MVP.

### 4.4 World snapshot contract
Capture, per physical body:
- Body ID and collision shape reference.
- Position and rotation.
- Linear/angular velocities.
- Mass/inertia and center of mass.
- Damping, restitution, friction, collision filters.
- Sleep/awake state and active constraints/joints.
- Relevant external forces, moving-platform phase, and game rule flags.

Also capture:
- Gravity and physics solver configuration.
- Fixed timestep.
- Spawn pose/impulse for candidate object.
- Stable object creation order.
- Random seed / state if used.
- Any contacts or transitional solver state needed to maintain prediction parity.

**Engineering note:** reproducing the visible objects alone may not reproduce exactly the same future. Physics solvers can depend on contact caches, ordering, precision, sleeping rules, and subtimestep timing.

### 4.5 Simulation architecture
Recommended approach:
- Use **one simulation model/engine for both gameplay and prediction**, with a **separate world instance** for preview, rather than approximating the future with a second physics algorithm.
- Advance both using fixed time steps with a chosen solver configuration.
- Record transformations for ghost playback.
- Never run preview physics against the live scene, then attempt to undo it.

Candidate implementation choices:
1. **SpriteKit** for rendering/UI + carefully isolated physics world(s). SpriteKit is easy to start with but snapshot and deterministic stepping controls may be limiting.
2. **SpriteKit rendering + controllable 2D simulation library** with explicit stepping. This may make parity testing and headless simulation easier but adds integration complexity.
3. A lightweight custom physics solver only if required by measured constraints; writing robust collision and stacking physics from scratch is risky.

**Decision gate:** Prototype one-world/two-world parity before committing to a physics technology.

### 4.6 Prediction labels
Use observable physics outcomes, not opaque AI mysticism:
- **Stable:** the new object settles and the supported stack remains within motion/tilt thresholds for a measured interval.
- **Wobbly:** object is still supported but movement/tilt is above threshold, or risk of future displacement is high.
- **Collapse risk:** stack loses support or objects cross loss boundaries in the look-ahead.
- **Uncertain:** simulation is near a threshold, diverges from repeated runs, or cannot confidently assess the horizon.
- **Unavailable:** simulation timed out or a feature/complexity limit was reached.

Do not show invented numerical probabilities. A label like “91% safe” requires calibrated statistical evidence and clear conditions.

### 4.7 What a prediction cannot promise
- Long-term stability after the preview horizon.
- Perfect equivalence if the player's actual release time/pose changes.
- Precision across different physics engine versions or devices.
- Identical outcomes in highly chaotic contact chains without solver validation.

**Disclosure in gameplay:** “Short simulated preview. Outcomes can change if you move the piece.”

### 4.8 Performance budgets
Initial *targets to benchmark, not promises*:
- 60 FPS during routine gameplay on target devices.
- Short preview with 10–30 active rigid bodies.
- UI remains responsive during prediction calculation.
- A timeout path, rather than freezing the game.

Implementation ideas:
- Preview only upon explicit button press, not every drag frame.
- Bound active body count and preview duration.
- Sample stored ghost frames at a lower rate than physics ticks if visual quality permits.
- Precompute static shapes and collision definitions.
- Separate rendering from simulation execution, with thread-safe handoff where framework allows.
- Reuse data structures and avoid excessive allocation.

### 4.9 Parity and trust testing (critical)
Build automated tests that:
1. Save a tower and intended drop pose.
2. Run the preview simulation and save its trajectory.
3. Restore a fresh identical world from the same snapshot and perform the actual drop.
4. Compare positions, rotations, collision sequence, and outcome labels across time.
5. Repeat for stable, marginal, unstable, rolling, and multi-contact scenarios.

Record divergence rates and tolerances. A parity regression should block release of Future Vision. If exact parity cannot be achieved, be transparent about uncertainty and tune gameplay to minimize deceptive previews.

### 4.10 “AI” terminology
The first version uses **physics simulation**, which is a predictive computation but **not necessarily machine learning**. Brand the feature *Future Vision* rather than making unsupported “AI predicts every move” claims.

A genuine machine learning layer is optional later:
- Train a risk classifier on generated simulated cases.
- Evaluate against held-out tower states.
- Calibrate and audit any displayed probabilities.
- Deploy on-device through Core ML only if it improves latency or accuracy.
- Keep full simulation as the source for ghost animations.

---

## 5. Game feel and audiovisual direction

### 5.1 Art direction
**Working style:** premium toy-box chaos. Clean silhouettes, warm saturated objects, soft lighting/shading, expressive but restrained effects. The game should feel polished, not like generic prototype rectangles.

**Palette direction (not final):**
- Deep midnight navy for gameplay contrast.
- Warm coral/orange and sunny yellow for playful objects.
- Teal/cyan accents for controls.
- Ethereal violet/cyan for Future Vision ghosts.
- Green / amber / red reserved for stability risk signals, always paired with text and shapes for color-blind accessibility.

### 5.2 Visual language
- Normal world = solid rendered bodies and physically consistent shadows.
- Future Vision = translucent outlines, faint trails, spectral tint, clear label.
- Risk = distinct icon + text, not color alone.
- Impact = quick squash/screen movement only within accessibility limits.
- Collapse = readable slow motion replay optional, not constant excessive shake.

### 5.3 Audio and haptics
- Light pickup feedback.
- Slight ticking tension while repositioning.
- Material-specific impact sounds with pitch/volume variety.
- Bass/wooden cascade on major collapse, volume-limited.
- Tiny celebratory accent for successful dramatic saves.
- Haptics for settle, wobble, and collapse; fully optional.
- Separate sliders/toggles for music, sound effects, and haptics.
- Avoid copyrighted music unless properly licensed.

### 5.4 Mascot and humor
Optional “tower inspector” robot mascot offers short contextual reactions, but must never obscure the tower or slow restart. Initial lines are curated and event-driven; runtime generative AI is unnecessary.

---

## 6. UX screens, navigation, and state

### 6.1 Screen map
**Launch → Main Menu → Play → Pause / End of Run → Retry or Home**

Supplemental:
- How to Play / tutorial
- Daily Challenge (later)
- Object Collection (later)
- Stats / Leaderboards (later)
- Settings
- Purchases / Restore Purchases (when monetized)
- Privacy / Support / Credits

### 6.2 Main menu
- Strong animated tower/physics visual.
- One large Play button.
- Daily Challenge (locked or hidden until available, no dead-end buttons).
- Best score.
- Sound/settings access.
- No unnecessary sign-up wall.

### 6.3 Gameplay HUD
- Score and best score, top safe area.
- Current object and optional next-object hint.
- Available predictions (clear numerical count).
- Obvious rotate controls, Drop, Future Vision.
- Pause and muted status.
- Contextual feedback within safe areas, respecting Dynamic Island/notch and device dimensions.

### 6.4 Future Vision UI
- Enter preview intentionally, not automatically.
- Brief calculating indicator if required.
- Ghost trail visible against stack.
- Risk label and “2.5-second simulation” disclosure.
- One-tap dismissal.
- Avoid pre-deduction or double-charging charges.
- Previous prediction expires after position/rotation/tower state changes.

### 6.5 Game-over screen
- Final score, personal best, number of successful drops.
- Optional funniest collapse replay.
- Large **Retry** button available immediately.
- Share after explicit user intent.
- Avoid interstitial ads that interrupt restart.

### 6.6 Onboarding
A 30–60 second playable tutorial:
1. Drag an easy box.
2. Rotate object with control.
3. Drop onto stable base.
4. Present Future Vision once for free.
5. Invite the player to use prediction on a risky placement.
6. Return to actual normal gameplay quickly.

No paragraphs of instruction on the first launch.

### 6.7 Accessibility
- Alternate non-gesture rotate controls.
- Reduced motion and optional camera shake.
- Distinct haptic and textual feedback.
- Clear contrast and scalable labels where feasible.
- VoiceOver menu navigation; gameplay alternatives and controls evaluated.
- Haptic off/audio off never makes core information inaccessible.
- Test touch targets and multiple device sizes.

---

## 7. Economy, retention, and monetization

### 7.1 Monetization principle
Fun must work without purchase. Avoid monetizing the central Future Vision advantage in scored competitive play.

**Initial pricing hypothesis:** free trial/play access with a one-time $2.99–$4.99 premium unlock, or a straight paid download after market testing. No subscription is necessary for offline gameplay.

Possible premium content:
- Distinct object packs (tested, noncompetitive mode).
- Cosmetic environments.
- Additional handcrafted puzzle challenges.
- Replay tools or expanded customization, if genuinely valuable.

Avoid:
- Selling extra attempts to exploit frustration.
- Selling powerful predictions on leaderboards.
- Manipulative timers, loot boxes, or deceptive offers.
- Advertising a permanent price before App Store economic validation.

### 7.2 Retention loops
- Immediate retry after failure.
- Visible skill improvement through higher scores.
- Personal best and milestone celebrations.
- Daily identical-seed challenge (post-MVP).
- Unlockable nonessential cosmetic achievements.
- Optional “best collapse of the day” local clip.

### 7.3 Metrics
When implementing analytics, prefer minimal, privacy-conscious data collection with consent and disclosure where required. Core validation can start with direct tester feedback.

Suggested funnel:
- First launch → tutorial complete → first drop → first prediction → first failure → second run.
- Median run length and attempts per session.
- Prediction usage rate and unused charges.
- Share/replay usage if implemented.
- D1/D7 retention (only when appropriately measured).
- Crash-free sessions, simulation failures, prediction latency and parity divergence.
- Conversion and refund rate if monetized.

**Do not invent success-rate targets as guarantees.** Set quantitative gates after prototype playtests.

---

## 8. Technical architecture

### 8.1 Proposed stack
- **Language:** Swift.
- **UI:** SwiftUI for menus, overlays, onboarding, settings.
- **2D rendering:** SpriteKit initially, subject to prediction-parity decision.
- **Physics:** one controlled solver architecture supporting both live and isolated preview worlds; select through proof of concept.
- **Storage:** local Codable files, SwiftData, or UserDefaults for tiny settings; durable versioned save model for records.
- **Haptics:** Core Haptics when appropriate with safe fallbacks.
- **Audio:** AVFoundation / SpriteKit audio where appropriate.
- **Purchases:** StoreKit 2 only when monetization is introduced.
- **Leaderboards:** Game Center optionally.
- **ML:** none required in MVP; optional Core ML after measured need.
- **Backend:** none required for MVP.

### 8.2 Suggested project layout
```text
Stackcident/
├── README.md
├── overview.md
├── docs/
│   ├── architecture.md
│   ├── physics-parity-test-plan.md
│   ├── art-style-guide.md
│   ├── release-checklist.md
│   └── decisions/
├── StackcidentApp/
│   ├── App/
│   ├── Features/
│   │   ├── Menu/
│   │   ├── Gameplay/
│   │   ├── FutureVision/
│   │   ├── Tutorial/
│   │   └── Settings/
│   ├── Core/
│   │   ├── Physics/
│   │   ├── Simulation/
│   │   ├── Models/
│   │   ├── Persistence/
│   │   └── AudioHaptics/
│   └── Resources/
├── StackcidentTests/
│   ├── SimulationParity/
│   ├── Rules/
│   └── Persistence/
└── StackcidentUITests/
```
Proposed layout only. Do not create unused scaffolding merely to match the diagram.

### 8.3 Essential systems
**GameState**: title, tutorial, aiming, prediction, dropping, settling, won/continuing, lost, paused.

**ObjectDefinition**: immutable tuning metadata and collision geometry.

**WorldState**: serializable state needed to recreate simulation, with schema version.

**PhysicsWorldAdapter**: abstraction for instantiate world, add objects, step with fixed delta, read body transforms and contacts, destroy world.

**PredictionService**: accepts immutable snapshot and intended drop, returns bounded trajectory and risk result; reports error/timeout safely.

**GameRules**: scoring, placement validity, loss conditions, progression.

**ReplayRecorder**: optional bounded buffer of sampled transforms, reused by ghost playback and replay export later.

**SaveStore**: options, local best, unlocked cosmetics, schema migration.

### 8.4 Proposed domain model
```swift
struct DropIntent {
    let objectID: String
    let spawnPosition: Vector2
    let spawnAngle: Double
    let releaseVelocity: Vector2
    let worldRevision: Int
}

enum PredictionClassification {
    case stable
    case wobbly
    case collapseRisk
    case uncertain
}

struct PredictionResult {
    let classification: PredictionClassification
    let horizonSeconds: Double
    let sampledFrames: [WorldFrame]
    let worldRevision: Int
    let intentFingerprint: String
}
```
Pseudocode-like type sketch: Vector2 and WorldFrame still need concrete definitions and the result should include error/timeout handling.

### 8.5 Performance and threading
- Target 60 FPS for supported scenes, but measure on real iPhones.
- No synchronous long simulation on the UI thread.
- Use a fixed physics tick and bounded simulation horizon.
- Avoid excessive bodies and collision hull complexity.
- Cancel obsolete predictions after state change.
- Return prediction results tagged with revision IDs to prevent stale overlays.
- Treat foreground/background transitions, interruption, and low-memory conditions explicitly.
- Save session state only when reliable to restore; otherwise explain that the run restarts.

### 8.6 Privacy and networking
- Offline-first baseline.
- No credentials or financial data.
- No required account.
- No background microphone or unnecessary permissions.
- If Game Center, analytics, or sharing are introduced, update disclosures and entitlement setup.
- Only share gameplay videos when users explicitly request export.
- Avoid embedding secrets in the app or repository.

### 8.7 Compatibility and deployment
- Establish a concrete minimum iOS version after checking chosen framework APIs.
- Use Apple signing and TestFlight for real-device testing.
- Version Xcode project configuration and asset licenses.
- Run unit and integration tests in CI where build runners permit.
- No Vercel deployment is required for the iPhone game; a marketing website could be hosted separately if useful.

---

## 9. Physics design details and edge cases

### 9.1 Tuning parameters
Specify physically plausible but game-friendly:
- Gravity magnitude and global scale.
- Fixed physics timestep (candidate 1/60 second, subject to tests).
- Solver iterations and contact tolerance.
- Body density/mass range.
- Restitution and friction by object/material.
- Damping and rotation limits.
- Sleeping/waking behavior.
- Collision layers.
- Boundary size and offscreen cleanup rules.

### 9.2 Deterministic-seed challenges
A shared seed must define object order, shape definitions, allowed variation, starting platform, scoring and rules version. Cross-device competition should not assume pixel-identical rigid-body trajectories. Compare fairness and tolerances experimentally.

### 9.3 Edge cases
- Piece is dropped partly outside playfield.
- A spinning object strikes another at high speed.
- A stack is still settling when user requests prediction.
- Prediction consumes charge but app backgrounds or crashes.
- Preview result arrives after the player moves the item.
- Player rotates an asymmetric object and its collision shape differs.
- Two bodies overlap on spawn.
- Slow device cannot simulate within budget.
- Extremely thin contacts tunnel through obstacles.
- A physics body never sleeps due to tiny oscillations.
- Tower extends outside vertical camera bounds.
- A daily seed generates an unwinnable opening.
- Device orientation or layout changes mid-session.
- Audio, haptics, or reduced motion settings change during play.

### 9.4 Decision policy
Physics consistency, legibility and basic frame rate take precedence over novelty. Remove or replace objects that cannot be made fair.

---

## 10. Content pipeline

### 10.1 Object production
1. Design silhouette and balancing challenge.
2. Define simple collision shapes.
3. Tune mass, friction and center of mass.
4. Create sprite and audio profile.
5. Test on low, medium and high tower states.
6. Validate Future Vision parity.
7. Assign difficulty tier and unlock conditions.
8. Add to object catalog only after playtesting.

### 10.2 Theme packs (possible)
- Kitchen Catastrophes
- Living Room Disaster
- Toybox Trouble
- Office Panic
- Cosmic Junk

All names and assets require originality and appropriate rights. Use original art or fully licensed assets.

### 10.3 Difficulty curation
Build small automated test fixtures to detect physically impossible or consistently trivial sequences, then let human playtesters assess whether the challenge is actually fun.

---

## 11. Development plan and stage gates

### Phase 0 — Discovery and validation
**Deliverables:**
- App Store and trademark research for “Stackcident.”
- Competitor analysis (stacking, physics chaos, preview/trajectory mechanics).
- One-page product thesis with target audience and differentiator.
- Technical physics feasibility checklist.

**Gate:** name is usable enough to proceed, and no obvious blocking competitive/technical issue.

### Phase 1 — Physics proof of concept (highest priority)
**Deliverables:**
- Simple floor and five primitive bodies.
- Interactive horizontal positioning and controlled rotation.
- Live drop.
- Independent snapshot-based two-second preview.
- Ghost replay.
- Automated prediction-vs-actual parity tests.

**Gate:** acceptable match between predicted and actual drops; preview latency and frame rate benchmarked on a real device. If not, change physics architecture before expanding content.

### Phase 2 — Playable vertical slice
**Deliverables:**
- 10–15 tuned objects.
- Endless mode, score, lose/restart.
- Limited Future Vision charges.
- First-run tutorial, polished minimum HUD.
- Sound, basic haptics, settings.
- Tester-friendly diagnostics with no sensitive data collection.

**Gate:** test players understand controls and want to retry without coaching.

### Phase 3 — Content, polish, testing
**Deliverables:**
- 15–25 objects.
- Refined art direction, effects, accessibility.
- Performance optimization and crash fixes.
- Balancing changes from playtests.
- Optional local collapse replay.

**Gate:** acceptable performance, no unfair routine collisions, and clear prediction language.

### Phase 4 — App Store launch
**Deliverables:**
- Apple developer signing, screenshots, app icon, metadata.
- Privacy information and support contact.
- Age rating and required disclosures.
- TestFlight testing and release checklist.
- Monetization decision based on actual feedback.

**Gate:** store-ready quality, no misleading AI claims, compliant purchases if any.

### Phase 5 — Post-launch
Only after observing play and retention:
- Daily challenge and share/replay.
- Game Center.
- More handcrafted objects, cosmetics.
- Optional trained risk model if it objectively helps.

---

## 12. Testing and quality assurance

### 12.1 Test categories
- **Physics unit tests:** contact behavior, collision geometry, mass, stability classification.
- **Prediction parity:** preview vs actual result with identical inputs.
- **Rules tests:** score, loss, charges, pause state, invalidation.
- **UI tests:** buttons, menu state, modal dismissal, tutorial, accessibility identifiers.
- **Performance tests:** late-game tower, expensive contacts, low-power behavior.
- **Persistence tests:** best-score save, migration, interrupted sessions.
- **Compatibility tests:** multiple iPhone sizes and supported iOS versions.
- **Accessibility tests:** VoiceOver for menus, reduced motion, non-color signals.
- **Human tests:** understandability, frustration, fun, and retry motivation.

### 12.2 Required prediction acceptance scenarios
- Stable centered box.
- Overhanging box near threshold.
- Round object on flat surface.
- Asymmetric object rotated 90 degrees.
- Existing tower with angular motion.
- Multiple contacts in a collapse.
- Spawn-edge collision.
- Prediction timeout/failure.
- Move/rotate after preview → result invalidates.
- Background app during preview.
- Repeated snapshot produces results within established tolerances.

### 12.3 Human research prompts
- “What did you expect that drop to do?”
- “Did Future Vision help you make a different decision?”
- “When did the game feel unfair?”
- “Did you want to retry? Why or why not?”
- “Would you send a video of your tower to a friend?”
- “Would you pay for this, and what specifically would you pay for?”

Do not lead testers by saying the game is “addictive” or that its predictions are accurate.

---

## 13. Risks and mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| Preview contradicts real result | Critical | Same physics model, snapshot contracts, parity tests, uncertainty label |
| Physics looks unfair | High | Simple collision geometry, user-visible rules, human balancing |
| Preview causes lag | High | Bounded simulation, background computation where safe, graceful timeout |
| Game becomes repetitive | High | Distinct object shapes, modes, scoring experiments, retention tests |
| Prediction becomes overpowered | Medium | Limited charges, challenge-specific scoring, balancing |
| “AI” marketing is misleading | High | Call it physics-based Future Vision unless genuine ML exists |
| App Store name/trademark collision | High | Search and legal review before release |
| Monetization harms trust | High | No pay-to-win competitive advantage, clear purchase terms |
| Content-production bottleneck | Medium | Modular object pipeline and reusable art conventions |
| iOS-specific implementation limitations | High | Prove solver/snapshot approach before committing |

---

## 14. Decisions already agreed vs. proposals

### Agreed direction from product discussions
- Game name: **Stackcident** (pending availability/trademark review).
- iPhone game.
- Physical stacking with funny collapses.
- Distinctive **Future Vision** preview before drops.
- Aim for a polished, satisfying, marketable casual game.
- Native, primarily offline implementation preferred.

### Proposed, still open to testing
- Exact paid/free business model.
- 2D portrait presentation.
- Three Future Vision charges per run.
- Explicit Drop button and rotation scheme.
- Physics library/engine selection.
- Exact failure condition and scoring.
- Final object roster and art direction.
- Daily challenge, replays and Game Center.
- Supported iOS version and device performance targets.

Keep proposed choices editable. Product experiments should override assumptions.

---

## 15. Definition of done for the first playable build

A build qualifies as an **actual playable prototype** only when:
- A tester can launch it on an iPhone.
- The player can position, rotate and drop multiple objects.
- Collisions, gravity, settling and collapse work.
- Score and a credible loss rule operate.
- Restart works consistently.
- Future Vision previews an actual *separately simulated* drop, not a fabricated animation.
- Prediction results are invalidated when inputs change.
- Preview does not silently alter the live world.
- We have recorded parity and performance test results.
- There are no required network calls, accounts or paid services.
- The README explains how to run and test the build.

A polished menu without reliable physics prediction is **not** completion of this milestone.

---

## 16. Immediate next actions

1. Commit this overview as the baseline reference.
2. Create an architecture decision record comparing SpriteKit-only vs controllable physics simulation.
3. Build the smallest two-world physics experiment before designing dozens of objects.
4. Instrument parity, simulation time, and runtime frame rate from the beginning.
5. Playtest whether preview changes decisions and increases enjoyment.
6. Only then expand the content and visual identity.

---

## 17. Glossary

**Live world:** the player's real, authoritative physics state.

**Preview world:** an isolated simulation copied from a snapshot of the live world.

**Ghost replay:** transparent animation of transformations computed by the preview world.

**Prediction parity:** degree to which a simulated preview matches an equivalent actual drop.

**World revision:** monotonically changing identifier used to reject old previews after the live state or drop intent changes.

**Fixed timestep:** a consistent physics simulation interval independent of rendering frames.

**Daily seed:** reproducible challenge configuration used to present the same content and constraints to players.

**Stability classifier:** interpretable logic categorizing a simulated outcome as stable, wobbly, collapse risk, or uncertain.

---

**Document ownership:** Stackcident project.  
**Maintenance rule:** Update this overview when the product vision changes; put detailed engineering decisions and test results in separate version-controlled documents.  
**Truthfulness rule:** Do not describe proposed features as shipped, or simulation as trained AI, without evidence.


---

## 18. Physics specification cross-reference (2026-10-29)

The detailed, implementation-oriented physics design is maintained in [docs/physics-engine.md](docs/physics-engine.md). It defines units, fixed-step timing, rigid bodies, contact/constraint handling, snapshot completeness, physically simulated Future Vision, ghost playback, stability classification, charge invariants, numerical error metrics, 25 test fixtures, and explicit engine-selection gates. Treat all unmeasured parameter values as experimental starting points rather than shipped guarantees. Any design modification affecting the physics experience must update the physics specification and matching acceptance criteria.


---

## 19. Implementation alignment — 2026-10-30

The latest native iPhone prototype includes an animated in-app splash, a Start Game menu, a tutorial sheet, eight geometric piece types, a narrowing challenge footprint, SpriteKit gravity/collisions and a separate, testable drop-resolution policy. These are **implemented source changes, not certified device-tested features**. The current art is stylized prototype geometry, not the eventual illustrated toy-box production aesthetic.

**Gameplay rule clarification:** An ordinary wobble, rotation, or lateral movement is not a loss. A dropped object must cross the true lower world-coordinate kill boundary to fail the current prototype round. Scoring requires demonstrated support and calm/dwell time, with conservative fallback for SpriteKit contact-cache misses. The exact final scoring/loss rules remain subject to usability and physics acceptance testing.

**Priority next:** run Xcode/Simulator and physical-iPhone tests, evaluate camera/touch sizing and difficulty with real playtesters, and build the two-world Future Vision feasibility prototype. Future Vision remains intentionally unavailable and must never be marketed as delivered.


## 20. Native iOS prototype gameplay stabilization — 2026-10-30

The current prototype retains the native SwiftUI splash/menu, portrait HUD and SpriteKit stacked-shape aesthetic but underwent a substantive physics rewrite after repeated iPhone Simulator bug reports. All pieces now share the same collision configuration and a single post-physics landing decision policy. The floor is an explicit static collider, body geometry is preserved from the aiming preview to the release, dynamic masses are normalized, and scoring waits for a grounded/low-motion interval. An actual dropped piece falling below the platform ends the round with a clear explanation; lateral wobble or an older block moving is not an automatic loss.

**What is proven:** the pure landing rules compiled under the available Linux Swift toolchain, and five standalone geometry/outcome assertions passed. **What is not proven:** SpriteKit runtime collisions, Xcode compilation, XCUITest, iPhone Simulator playthroughs, real-device FPS, and a fully reliable 10-piece run. The first-party Future Vision prediction remains intentionally unimplemented.

The detailed regression matrix is [docs/qa-smoke-checklist.md](docs/qa-smoke-checklist.md). Do not expand scope until it passes on an iPhone; if live SpriteKit remains unreliable, evaluate the controllable single-solver design laid out in the physics architecture instead of adding more ad hoc timeouts.
