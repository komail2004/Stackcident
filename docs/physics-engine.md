# Stackcident — Physics Engine & Future Vision Engineering Specification

**Document ID:** STK-PHY-001  
**Version:** 1.0 — Detailed design baseline  
**Date:** 2026-10-29  
**Status:** Proposed; no physics implementation or measured performance yet  
**Scope:** Native **iOS/iPhone**, portrait, 2D physics; offline-first  
**Related documents:** [Overview](../overview.md) · [Requirements](../requirements.md) · [Architecture](architecture.md)

> **Physics is the game's central promise.** The same mathematical model must produce the actual tower and the simulated possible future. The prediction cannot be a scripted visual, and the game must never pretend that a physically sensitive, chaotic outcome is guaranteed.

## 0. Decision record and engineering truths

**Confirmed product decisions:** iPhone-only iOS game, real stacking physics, explicit DROP action, player-adjustable horizontal position and orientation, physically calculated Future Vision, separated preview and live worlds, offline core.

**Engineering choices awaiting empirical validation:** physics library; timestep and solver options; supported iPhones/iOS versions; exact stability thresholds; body budgets; preview horizon/latency; reliable degree of prediction parity across representative contacts. **Nothing in this specification proves that a selected engine already works.**

**Suggested baseline:** SwiftUI for native iOS chrome, SpriteKit for visualization, and **one independently step-able 2D rigid-body physics engine instance per world** to drive both gameplay and Future Vision. A Box2D-style engine is a candidate. Use of SpriteKit's built-in physics instead remains an alternate only after a cloning/stepping parity experiment. Investigate licensing, Swift interop, supported Apple platforms and distributable binaries before adoption.

### 0.1 Normative terms
- **MUST**: required to satisfy the game design.
- **SHOULD**: default practice; deviations require ADR evidence.
- **MAY**: optional.
- **Live world:** sole authoritative state for scoring, collision and failure.
- **Preview world:** disposable isolated world created from a frozen snapshot.
- **Canonical state:** versioned physics inputs sufficient to replay a drop under the defined solver contract.
- **Pose:** 2D translation plus orientation.
- **Step:** one fixed physics advance.
- **Physics tick:** monotonic index counting fixed steps, not display frames.
- **Ambiguous:** insufficiently confident forecast, not a failure of the player.

---

## 1. Coordinate system, units and constants

### 1.1 Units
Use SI-style internal units: distance in meters, time in seconds, mass in kilograms, angles in radians, linear velocity in m/s, angular velocity in rad/s, force in newtons, impulses in N·s and torque in N·m. Values may represent toy-scale objects; the renderer translates them to visual points with a single pixels-per-meter scale factor.

Do not mix screen points into collision geometry or raw touch coordinates into the physics solver.

### 1.2 Reference coordinate convention
- Physics origin at center of floor, where Y is positive upward, X positive rightward.
- Renderer camera maps physics-space coordinates into SpriteKit scene points.
- Aiming uses player-visible horizontal position that is converted into legal physics coordinates.
- UI rotation buttons adjust radians via a fixed configured step.
- Define clock direction and positive angular velocity consistently.
- Floor is static; moving floors require a future configuration version and explicit snapshot treatment.

### 1.3 Candidate physics configuration (NOT final)
| Property | Starting hypothesis | Why | Verification |
|---|---|---|---|
| Gravity | (0, −9.81) m/s² | Understandable baseline | Free-fall test |
| Fixed step | 1/60 s | Controllable repeatability | 30/60/120 Hz display tests |
| Max catch-up | 4 steps / render frame | Avoid spiral of death | Frame-spike test |
| Linear/angular solver iterations | Engine-specific, measure | Stacking stability | Contact stress |
| Max active bodies | Initial test 10–30 | On-device performance bound | 30-body scene |
| Candidate preview | 120–180 ticks (2–3 s) | Useful short lookahead | Latency profiling |
| Contact tolerance | Engine-defined tuning | Prevent jitter | Thin contact cases |
| Restitution | Per-material, limited | Avoid pinball chaos | Rebound test |
| Friction | Per-material, documented | Predictable sliding | Incline test |
| Density | Object catalog value | Stable mass/inertia | Mass audit |
| Sleep thresholds | Engine-specific, documented | Settling performance | Slow oscillation test |

**Do not freeze these into requirements until physically tested.** Different physics engines expose different parameters. A 2D tower needs tuning for gameplay rather than scientific realism.

### 1.4 Time accounting
Rendering occurs on a display refresh schedule (potentially 60/120 Hz); physics ticks remain fixed. Maintain an accumulator, clamp pathological frame delta, and never let a paused preview silently advance live physics. If the engine cannot catch up without excessive latency, record overload and retain coherent simulation time rather than applying arbitrary larger timesteps.

Reference loop:

```swift
// Illustrative algorithm, not compiling production code.
accumulator += min(frameDelta, maxAcceptedFrameDelta)
let fixedDelta = 1.0 / 60.0
var steps = 0
while accumulator >= fixedDelta && steps < maxCatchUpSteps {
    liveWorld.step(fixedDelta)
    evaluatePhysicsEvents()
    accumulator -= fixedDelta
    steps += 1
}
publishInterpolatedFrame(alpha: accumulator / fixedDelta)
```

Never use the number of rendered frames as elapsed physics time.

---

## 2. Rigid-body state and mathematical model

Each piece is a rigid body whose state includes position `p=(x,y)`, orientation `θ`, linear velocity `v`, angular velocity `ω`, mass `m`, inertia `I`, sleeping/awake status, collision fixtures and material properties.

### 2.1 Motion
- Linear acceleration `a = F/m + g` where applicable.
- Torque induces angular acceleration `α = τ/I`.
- Impulses produce instantaneous velocity changes.
- Angular contact friction resists sliding and can rotate bodies.
- Damping reduces linear/angular motion but is **not** a substitute for solver stability.
- Use engine-authoritative integrator and contact solver; do not hand-update positions on top of a live solver.

### 2.2 Common implementation errors to avoid
- Updating SpriteKit node positions by both scene actions and physics engine.
- Recreating collision polygons with different vertices for preview.
- Computing different mass/inertia in preview.
- Injecting forces during render callbacks rather than controlled physics steps.
- Applying arbitrary random “wobble” to live objects.
- Ignoring angular velocity, sleep state or joint state in snapshots.
- Reusing mutable physics body references between independent worlds.
- Letting a preview rewind/restore the authoritative world.

### 2.3 Numerical validity
Reject NaN, infinity, negative/zero dynamic mass, invalid polygons, implausibly huge velocities and unstable scaling. Clamp candidate positions to legal bounds. Validate canonical numeric ranges at content import and before world restoration; debug-assert and production-safe-fail on violations.

---

## 3. Collision shapes, mass and center of gravity

### 3.1 Visual-to-physics mapping
Art must approximate collision boundaries. Author one physics fixture definition per object and instantiate the exact same fixture in both worlds. Do not auto-trace complex image alpha during gameplay.

**Preferred primitives:** circle, box, convex polygon, simple compound of supported shapes. A concave banana can use a small number of convex pieces. Keep thin shapes thick enough for stable contacts.

### 3.2 Catalog schema
```yaml
id: toy_toaster_01
shapeVersion: 1
displayName: Toy Toaster
visualAsset: object_toaster_01
fixtures:
  - type: box
    widthMeters: 0.72
    heightMeters: 0.44
    offsetMeters: { x: 0.0, y: 0.0 }
material:
  density: 2.2
  friction: 0.56
  restitution: 0.08
damping:
  linear: 0.03
  angular: 0.09
spawn:
  allowedAngleDegrees: [-90, 90]
  minX: -2.5
  maxX: 2.5
difficultyTier: 1
```
**Example only.** Values require empirical tuning, not physical justification from a toy toaster.

### 3.3 Center of mass
An asymmetric piece should behave asymmetrically because fixture geometry and mass distribution determine its center of mass and inertia. Optionally add explicitly versioned body properties for intentionally weighted objects. Do not inject a scripted tilt in the renderer. Visual highlighting can hint at heavy sides.

### 3.4 Collision categories
Define named categories (platform, live-object, spawn-preview-only visualization, decoration, ghost). Ghost nodes must have **no collision body** in the live world. Decorative particles must never affect scoring or trigger loss. Keep collision filters identical between preview and live for physical bodies.

### 3.5 Continuous collision detection
Use engine-supported CCD/bullet settings for sufficiently fast or small bodies where tunneling occurs. CCD may affect solver results and cost; record it in fixture definitions and snapshots.

---

## 4. Contact physics and stacking stability

### 4.1 Contact workflow
Each fixed tick:
1. Integrate velocities/forces using solver.
2. Broad-phase candidate collision detection.
3. Narrow-phase contact manifold generation.
4. Iterative velocity/position constraint solving.
5. Apply friction/restitution and resulting impulses.
6. Update body transforms/sleep status.
7. Export contacts and supported geometry for game rules.

The underlying engine may use a different exact ordering. The adapter should not rely on undocumented internal details.

### 4.2 Sliding, rolling and tipping
- Sliding begins when contact forces exceed supported friction threshold.
- Rolling emerges from circular collision geometry and contact torque.
- Tipping emerges as the support polygon/contacts fail to contain a projected center of mass **in simplified quasi-static situations**.
- Multiple stacked bodies require dynamic solver simulation; a center-of-mass projection alone is insufficient as a future predictor.

### 4.3 Support graph
For classification and debug, derive a directed support graph from physically valid contacts: floor supports A, A supports B, etc. Use contact normal/orientation to distinguish support from incidental lateral brushing. The graph is diagnostic and rule input, not a second physics engine.

### 4.4 Sleep and settling
A body can be sleeping with nonzero residual approximation error; never infer “safe forever” from asleep status alone. A valid settled state may require:
- low translational and angular motion;
- stable supported contacts;
- acceptable duration below thresholds;
- no object already beyond loss boundaries.

Use hysteresis (different enter/exit thresholds) to avoid rapid stable/wobbly flicker. Settlement timeout ensures an oscillating tower does not block gameplay indefinitely.

---

## 5. Drop transaction and authoritative resolution

### 5.1 Lifecycle
```text
AIMING → DROP_COMMITTED → FALLING → SETTLING
                                     ├── VALID_PLACEMENT → NEXT_OBJECT
                                     └── LOSS → RESULTS
```

The coordinator accepts one drop command per object. Snapshot the chosen `DropIntent` at commit, disable further aiming for that object, and add the body exactly once. The live world is the only source of collision outcomes.

### 5.2 Validation before a drop
- Candidate object exists and is unlocked for this sequence.
- Candidate pose legal and within spawn bounds.
- Pose not intersecting forbidden objects.
- No active drop already pending.
- Round state is AIMING.
- All numerical fields finite.
- Drop release velocity defined.
- No obsolete preview overlay is mistaken for a committed result.

### 5.3 Outcomes and scoring
Scoring should occur once per valid settled object, not when it touches something briefly. Use an idempotent `placementID` to protect against duplicate events. A collapse during settlement triggers one loss event, preserves final score and ends input. Avoid counting decorative pieces, previews or old-world contacts.

### 5.4 Defining failure
The initial design should choose a simple measurable rule such as loss when the just-placed physical object falls out of the legal support region or a defined threshold of core objects falls past a boundary; exact criteria require playtesting. Use world coordinates and support information, not whether an object is temporarily outside the camera view.

---

## 6. Future Vision: exact data path

**Fundamental contract:** preview must represent the **same drop action** against an isolated world equivalent to the paused authoritative world.

### 6.1 Preview request
```text
Player taps Future Vision
 → validate state/charge
 → stop live-world tick at defined boundary
 → snapshot complete world + object definitions + solver configuration
 → attach worldRevision, intentRevision, requestID
 → create separate preview engine world
 → restore snapshot and introduce candidate with same rules
 → step 120–180 ticks independently
 → record frames/contact events
 → classify result
 → return only if request still current
 → debit 1 charge only on accepted completed result
 → render transparent recorded world
 → return to aiming
```

### 6.2 Deep copy and ownership
No live pointers in preview structures, no shared mutable `SKPhysicsBody`, no shared engine world handles. Immutable object configuration can be shared by value/reference if logically immutable; individual dynamic bodies, fixtures, contact buffers and solver objects belong to exactly one world. Preview result owns a copied trajectory, not references to a soon-to-be-destroyed physics world.

### 6.3 Canonical snapshot fields
| Category | Required fields |
|---|---|
| Identity | World ID, world revision, rules version, snapshot version, tick index |
| Engine | Engine/library version, solver options, gravity, fixed timestep, numerical precision platform assumptions |
| Body | Stable body ID, definition ID and version, pose, linear/angular velocity, dynamic/static mode, awake/sleep state |
| Geometry | Fixture shapes, offsets, geometry version, density, mass/inertia (or deterministic derivation), center of mass |
| Contact | Contact warm-start/caches/impulses if required to reproduce the solver, or explicit documented approximation |
| Constraints | Joint anchors, limits, motors, spring/suspension state as applicable |
| Environment | Static boundaries, moving platform phase, global forces, any wind/current effect |
| Spawn | Candidate definition, position, orientation, initial linear/angular velocity, release tick |
| Randomness | RNG seed **and current generator state**, deterministic object/fixture creation order |
| Gameplay | Relevant contact/loss threshold rules and phase |
| Provenance | Platform build, physics engine identifier, revision fingerprint and validation checksum |

A high-level snapshot is **not automatically sufficient** for bit-identical reconstruction. Contact caches/warm starting, floating-point behavior, scheduling and shape insertion order may matter.

### 6.4 Snapshot versioning
Version snapshot schema independently from user saves. Include catalog hash and engine configuration hash. Reject incompatible snapshots, skip prediction gracefully and do not attempt unsafe decoding. Never persist preview engine memory addresses.

### 6.5 Fixed-step prediction algorithm
```swift
func predict(_ request: PredictionRequest) throws -> PredictionOutcome {
    let world = try physicsFactory.restore(request.worldSnapshot) // isolated
    defer { world.destroy() }

    try world.addCandidate(request.dropIntent)
    var frames = [WorldFrame]()
    var motion = MotionSummary()

    for tick in 0..<request.horizonTicks {
        try Task.checkCancellation()
        try world.step(request.fixedDelta)
        motion.accumulate(world.contacts, world.bodies, tick)
        if tick % request.sampleEveryTicks == 0 {
            frames.append(world.captureFrame())
        }
        if motion.hasDefinitiveIrrecoverableLoss {
            // May stop early if animation and classifier contracts permit.
            break
        }
    }
    return classifyAndPackage(frames: frames, motion: motion)
}
```
Illustrative pseudocode. The real adapter must enforce cancellation and bounded resources at appropriate safe points.

### 6.6 Prediction charge invariants
- Never spend a charge when a request starts.
- Spend exactly one on a valid result accepted by the current coordinator.
- Failed, cancelled, outdated and timeout results cost zero.
- Repeated taps during active request do not spawn multiple workers.
- Charge modification is a single serialized coordinator transaction.
- When pause/background interrupts preview, cancellation leaves charge intact unless the accepted result already appeared.
- UI immediately displays updated count once accepted.

### 6.7 Stale result policy
A result is current only if all are true:
```text
result.requestID == activeRequestID
result.worldRevision == liveWorldRevisionAtRequest
result.intentFingerprint == currentIntentFingerprint
roundID == request.roundID
gameState accepts preview completion
```
Because the preview design freezes live simulation during aiming, the matching world revision should remain stable. Any actual world tick that changes the scenario invalidates cached previews.

### 6.8 Ghost playback architecture
- Playback receives `[WorldFrame]` with monotonic tick timestamps.
- Each frame maps body IDs to position and rotation; reconstruct-only visual nodes.
- Render predicted pieces translucently with a clear legend.
- Optionally render original live stack dimmed but never overwrite live poses.
- Sample at a bounded interval and interpolate between frames.
- Maintain separate “ghost node” namespace to prevent gameplay collision callbacks.
- Clear ghost nodes on dismiss, new aim, Drop, Restart, background or timeout.
- For reduced motion: use key poses or final silhouette with textual summary rather than fast flashing animation.

---

## 7. Predicting whether the tower is safe

### 7.1 Why simple binary labels are inadequate
A tower may be stable during 2 seconds yet collapse 0.5 seconds later. A marginal object may settle on one run and tip on another due to tiny contact differences. A single end-frame metric is not sufficient.

### 7.2 Feature extraction per preview
- Number and identity of pieces that cross configured loss boundaries.
- New piece contact/support persistence.
- Root or core support-graph changes.
- Maximum displacement and angular change per relevant body.
- Magnitude and decay of linear and angular velocity over a terminal window.
- Contact impulse magnitudes (for diagnosis and severe impact indicators).
- Tower height, lateral sway and critical overhang.
- Bodies still moving at preview end.
- Sensitivity/disagreement across repeated simulation replicas when necessary.

### 7.3 Proposed decision ordering
1. **Collapse Risk** if the preview explicitly reaches a real loss condition or irrecoverable structural failure.
2. **Uncertain** if the preview fails to reach meaningful resolution, is near a decision boundary, or the simulator reports parity/sensitivity risk.
3. **Wobbly** if supported but residual motion/displacement exceeds stable thresholds.
4. **Stable** if resolved, supported, low-motion and no relevant loss threshold crossed during the horizon.

This ordering is a **proposed policy**; threshold values are not yet validated.

### 7.4 Statistical percentages
Do not label “92% chance of survival” unless calibrated from a defined distribution of perturbed drop conditions, with held-out evaluation. An exact deterministic simulation alone provides one scenario, not a probability distribution.

### 7.5 Optional sensitivity analysis
For near-critical poses, run a small predetermined set of perturbed scenarios (e.g. slight x/angle/release-time offsets) using independent preview worlds:
- Report agreement/disagreement, not a claim of universal real-world probability.
- Budget the extra computation.
- Explicitly tell players “sensitive placement” rather than making a precise percentage claim.
- Never perturb the real-world release secretly.

---

## 8. Determinism, replay and parity methodology

### 8.1 Three levels of parity
- **Level A — Same world instance repeated:** same exact initial state and commands yield same path if engine supports repeatable stepping.
- **Level B — Clone equivalence:** snapshot-restored preview matches fresh authoritative control world within tolerance.
- **Level C — User-observed agreement:** preview rendered and actual committed drop lead to a materially consistent outcome under matching pose/timing.

Level C is the commercial trust requirement. Level B enables confidence but does not guarantee all human-visible outcomes when there are uncontrollable changes.

### 8.2 Error metrics
For each body `i` and tick `t`:
- Position deviation `e_p(i,t) = ||p_preview(i,t) − p_control(i,t)||`.
- Wrapped angular error `e_θ(i,t) = abs(wrapToPi(θ_preview − θ_control))`.
- Contact graph difference.
- First impact time/tick difference.
- Outcome label agreement and confusion matrix.
- False-confident safe predictions count.
- Simulation runtime p50/p95/p99 by device tier.

Record world size/body count, fixture versions, seed, runtime architecture and iOS build. Do not substitute a single average error for severe individual failures.

### 8.3 Gold fixtures
| Fixture | Setup | Expected capability |
|---|---|---|
| PHY-001 | Falling rectangle over floor | Gravity/impact consistent |
| PHY-002 | Offset rectangle onto centered slab | Torque and tipping |
| PHY-003 | Sphere on sloped/flat surface | Rolling and friction |
| PHY-004 | Thin book across two supports | Multiple contacts |
| PHY-005 | Uneven center of mass | Asymmetric rotation |
| PHY-006 | Wobbling base with nonzero velocities | Dynamic snapshot clone |
| PHY-007 | Stack with sleeping bodies | Wake/settle parity |
| PHY-008 | Contact-dense chain reaction | Multi-body fidelity |
| PHY-009 | Corner impact at speed | CCD/tunneling |
| PHY-010 | Candidate partly outside permitted region | Input rejection |
| PHY-011 | 30-body late tower | Runtime and memory |
| PHY-012 | Preview cancellation at every phase | State and charges intact |
| PHY-013 | Aim changes mid-preview | Stale result discarded |
| PHY-014 | App background during simulation | Safe cancellation/lifecycle |
| PHY-015 | Rapid taps and double Drop | Idempotence |
| PHY-016 | Corrupted/incompatible snapshot | Safe unavailable result |
| PHY-017 | Near-threshold overhang | Uncertainty messaging |
| PHY-018 | Repeated deterministic seed | Repeatable object sequence |
| PHY-019 | Long-standing micro-vibrating tower | Bounded settlement |
| PHY-020 | Slow device/prediction timeout | Responsive fallback |
| PHY-021 | Many restarts and predictions | Memory/leak stability |
| PHY-022 | Different supported device CPUs | Cross-device tolerance study |
| PHY-023 | Different rendering refresh rates | Same physics tick rules |
| PHY-024 | Paused live world | No unrequested motion |
| PHY-025 | Preview ghost with reduced motion | Accessible alternative |

### 8.4 Suggested test protocol
For each deterministic test: serialize starting state once; instantiate **two new worlds** from the same fixture; apply one identical `DropIntent`; run identical ticks; compare sampled frames and outcome classifications; repeat test a specified number of times. Then separately test live-play command path to detect UI/coordinator differences.

### 8.5 Acceptance thresholds
**TBD by prototype measurement.** Declare numeric tolerances and confidence thresholds before V1 release after collecting baseline distributions. Avoid choosing arbitrary thresholds today, or claiming 100% deterministic success across devices.

**Immediate release blocker:** repeatable cases in which Future Vision confidently indicates safe while the matching live drop materially collapses. Near-threshold outcomes must be classified Uncertain or resolved by architectural changes.

---

## 9. iPhone performance and concurrency

### 9.1 Ownership boundaries
- `@MainActor` owns SwiftUI state, presentation and rendering transactions.
- A single serialized context owns live physics mutation.
- A separate worker/actor owns isolated preview-world computations.
- Immutable snapshot values cross ownership boundaries; raw physics-engine pointers do not.
- `Task` cancellation is respected at predictable simulation step intervals.
- No UI rendering work or SpriteKit node mutation from background simulation threads.

**Special warning:** Some engine wrappers are not thread-safe even with different worlds. Test and document library concurrency guarantees. If unsupported, process preview on the same serialized simulation executor while keeping UI responsive via an asynchronous bounded job, not undefined parallel calls.

### 9.2 Performance budgets
Provisional, unverified goals:
- Gameplay steady target 60 FPS.
- 2 s preview/10–30 bodies under 1 s p95 on defined supported iPhones.
- No main-thread stall exceeding 100 ms caused by routine preview.
- No memory growth without bound over 100 preview/restart cycles.
- Sustained 30-minute thermal/performance check.
- On slow hardware, preview can return Unavailable or simplified feedback without blocking authoritative game.

### 9.3 Profiling
Use Instruments Time Profiler, Allocations/Leaks, Core Animation, Xcode debug memory graph and signposts for snapshots, solver steps, contact graph updates, classification, ghost replay and SwiftUI publishing. Collect measurements **on real iPhones**, not simulator-only.

### 9.4 Complexity safeguards
- Prebake/cached convex fixture data.
- Limit active dynamic bodies or safely prune offscreen non-gameplay debris.
- Avoid recalculating polygon geometry per tick.
- Keep physics contacts/impulses authoritative.
- Record a lower visual sampling rate than solver tick if replay remains clear.
- Reuse ghost nodes and buffered arrays.
- Cap simultaneously running predictions at one.
- Display “prediction unavailable” without corrupting the run if limits are exceeded.

---

## 10. Engine evaluation matrix and proof-of-concept gate

| Criterion | SpriteKit built-in physics | Independently step-able 2D solver |
|---|---|---|
| Native iPhone integration | Strong | Requires adapter/interop |
| Visual rendering | Native SpriteKit | SpriteKit renderer can still be used |
| Arbitrary-step isolated preview | Must prove viability | Typically explicit API |
| Full snapshot semantics | Must prove; no simple universal clone | Still requires contact-cache handling |
| Test headlessly | More awkward | Often easier |
| Swift ergonomics | Strong | Depends on bindings |
| Licensing and maintenance | Apple framework | Verify chosen library version/licensing |
| Determinism across hardware | Not assumed | Not assumed |
| Decision | Reject/approve based on parity evidence | Investigate first |

### 10.1 PoC implementation order
1. Create minimum native SwiftUI iPhone shell, SpriteKit scene and debug HUD.
2. Implement two engine-owned worlds with the same config.
3. Put floor and five dynamic bodies into live world.
4. Add horizontal and rotation controls.
5. Capture snapshot and candidate intent at a fixed tick.
6. Run isolated 120-tick preview and record poses.
7. Render translucent playback with no collisions.
8. Commit identical drop to live world.
9. Compare recorded trajectories and outcomes.
10. Add cancellation, invalidation and charged-on-success semantics.
11. Run at least PHY-001–009 and PHY-012–016 on-device.
12. Write ADR documenting chosen solver and measured limitations.

### 10.2 Failure alternatives
If cloned-world parity is poor:
- Investigate missing engine internal state, warm starting and contact-cache compatibility.
- Hold the live world at the exact snapshot boundary until chosen release.
- Test reconstructing both preview and authoritative release from the same canonical snapshot, if it doesn't disrupt gameplay continuity.
- If uncertainty remains, use an honest preview of a **possible** future with clear uncertain classifications and no guaranteed claims.
- Consider a simpler toy physics model or narrower object shapes.
- **Do not** secretly fake ghost trajectories to force apparent accuracy.

---

## 11. Detailed data contracts and invariants

### 11.1 Suggested records
```text
WorldConfig {
  gravity: Vec2
  timestep: Double
  solverOptions: VersionedMap
  physicsEngineID: String
  engineVersion: String
  rulesVersion: Int
}
BodyDefinition {
  id: String
  fixtureDefinitions: [FixtureDefinition]
  physicsProperties: MaterialAndDynamics
  centerOfMassPolicy: Enum
  version: Int
}
BodyState {
  bodyID: UInt64
  definitionID: String
  pose: Pose
  velocity: Vec2
  angularVelocity: Double
  awake: Bool
  additionalEngineState: ValidatedOptional
}
DropIntent {
  candidateDefinitionID: String
  pose: Pose
  releaseVelocity: Vec2
  worldRevision: UInt64
  intentRevision: UInt64
  roundID: UUID
}
PredictionResult {
  requestID: UUID
  provenanceHash: String
  resultLabel: Stable|Wobbly|CollapseRisk|Uncertain
  trajectory: [WorldFrame]
  simulatedTicks: Int
  computationDuration: Duration
}
```

### 11.2 Invariants
```text
LIVE_WORLD_POINTERS ∩ PREVIEW_WORLD_POINTERS = ∅
Preview.isRunning ⇒ liveWorld.isFrozenAtSnapshotBoundary
Preview.success ⇒ chargeDelta = -1 exactly once
Preview.failureOrCancelledOrStale ⇒ chargeDelta = 0
Preview.resultApplied ⇒ sameRound && sameWorldRevision && sameIntent
GhostRenderer.physicsCollisionBodies = 0
ActualDrop.scoreSource = LiveGameRulesOnly
AllPhysicsBodies.haveFiniteState = true
EveryCommittedDrop.hasUniqueID = true
```

Strictly speaking, independently allocated engine objects won't share ownership, but immutable catalog assets can be shared safely. The first invariant means **mutable physics-world object handles**, not all memory addresses whatsoever.

### 11.3 Logging schema
For each debug prediction run: request ID, round ID, physics build, model version, body count, horizon ticks, candidate pose, snapshot integrity hash, p50/p95 step time, result classification, error, and parity deviations when control run exists. Do not log unrelated personal data. Strip or gate verbose logs in production.

---

## 12. Risk catalog and response plans

| Risk | Symptom | Prevention/response |
|---|---|---|
| Contact cache mismatch | Ghost settles, real tower tips | Reconstruct solver state or report uncertainty |
| Different shape fixture | Preview collision differs | Single versioned catalog, hash check |
| Variable time step | 120-Hz phone behaves differently | Fixed-step simulation |
| UI race | Stale ghost after reposition | Request/revision fingerprint validation |
| Excessive contact complexity | Preview blocks touch | Body budget, timeout, profiling |
| Invalid object mass | Exploding physics | Validation, finite bounds, test catalog |
| Sleep-state divergence | Stack starts wobbling unexpectedly | Snapshot awake/sleep status and parity tests |
| Chaotic edge thresholds | Confident but wrong classification | Threshold margin, uncertainty, repeat fixtures |
| Preview consumes live charge on failure | Player loses fairness | Commit charge only after valid result |
| Double commit | Two objects spawn | Serialized idempotent Drop transaction |
| Ghost collisions | Preview changes actual world | Render-only node namespace, no physics body |
| Background cancellation | Frozen or corrupted game | Lifecycle tests and safe pause |
| Asset/engine license | App Store/legal blockers | License inventory and ADR |

---

## 13. Requirements and test traceability

| Source IDs | Physics obligation | Evidence |
|---|---|---|
| FR-010–021 | Accurate, bounded authoritative placement/settle/loss | PHY-001–010, PHY-019 |
| FR-030–034 | Valid definitions and collision geometry | Catalog validation, PHY-005 |
| FR-040–048 | Isolated simulated Future Vision | PHY-006–009, PHY-016 |
| FR-049–055 | Charges, stale results, error handling, parity | PHY-012–017, PHY-020 |
| NFR-010–018 | FPS, latency, no UI stalls, bounded resource use | Device Instruments profiles |
| NFR-020–026 | World isolation, reproducibility, state integrity | Immutable snapshot and parity reports |
| NFR-050–057 | Testable architecture and release gates | CI test report, build/ADR evidence |

---

## 14. Implementation tasks, outputs and go/no-go

### Milestone P0 — Pure model and test data
**Output:** Physics coordinate convention, object fixture schema, 5–7 starter objects, typed `DropIntent`, physics world adapter and fixtures.

### Milestone P1 — Two-world test harness
**Output:** Load or create a tower, snapshot it, reconstruct a second world, step both with same release, export trajectory difference report.

### Milestone P2 — Future Vision iPhone prototype
**Output:** Native iPhone app with object aiming, rotate, explicit drop, ghost simulation playback, three charge counter, and safe cancellation.

### Milestone P3 — Trust and performance
**Output:** Stable/wobbly/collapse/uncertain classification, a measured parity suite, frame and latency profiles on at least two physical iPhone tiers.

### Milestone P4 — Product polish gate
**Output:** 10–15 tested whimsical objects, audio/haptics, accessible HUD, scoring, pause/retry, persistence and short tutorial.

**Go/no-go rule:** A beautiful demo is **not** a successful physics prototype if preview is fabricated, live state is mutated by forecasting, or confidence mismatches are unmeasured.

---

## 15. Open questions requiring evidence, not guesses

1. Can SpriteKit alone provide accurate isolated replay without nonpublic engine state?
2. Which specific 2D solver version has the best Swift/iOS support and acceptable commercial license?
3. Can preview-world reconstruction preserve warm-start/contact effects adequately?
4. What physics/body/tick parameters meet p95 on an older supported iPhone?
5. How much divergence is visually tolerable before players perceive unfairness?
6. How frequently should “Uncertain” be shown to protect trust without diminishing fun?
7. Does prediction actually improve player decisions and enjoyment?
8. What balance between physical realism and playful object exaggeration is most satisfying?
9. Can a standard stable release world pause indefinitely during prediction without confusing other game rules?
10. What minimum iOS target and device matrix maximize quality without excessive maintenance?

---

## 16. Definition of physics completion

The physics subsystem is **designed** when its interfaces and acceptance fixtures exist; **implemented** when real native iOS code runs; **verified** when engine/preview parity and performance data pass explicitly documented tolerances; **released** only after full game QA and App Store submission.

**Minimum acceptable outcome:** a player can place, rotate, preview and drop an object on an actual iPhone; the preview is computed by a distinct instance of the same physics engine using a controlled snapshot; charge accounting and result invalidation are safe; the predicted ghost and actual drop exhibit measured, trustworthy consistency.

**Next engineering action:** implement the smallest two-world parity experiment and write ADR-0001 from real test results before committing to a particular physics engine.


---

## 17. SpriteKit prototype: conservative loss policy (2026-10-30)

**Current implementation, NOT the final prediction solver:** scene physics are in SpriteKit points, gravity is `dy = -620` points/s², and the dropped object alone is evaluated by `DropRules`. The following is intentionally narrower than the final tower-support graph model:

1. A newly released object's center crossing `baseY - 75` causes loss; sideways travel and other previously placed pieces do not cause immediate loss.
2. Ordinary success requires active support contact, linear speed below 38 scene-points/s, angular speed below 0.85 rad/s and a calm dwell of at least 0.32 s after 0.55 s elapsed.
3. After 2.8 s a recently contacted or supported slow object (speed below 70 points/s) may resolve, protecting against contact flicker.
4. After 5.5 s an object can resolve only if geometry indicates nearby plausible support and both linear/angular speed are very low. A motionless unsupported object in open space must **not** be counted as a success.
5. Otherwise simulation continues until an actual lower-bound miss; no forced time-based game-over is invented.

The numerical values are **tuning heuristics**, not engineering guarantees and not cross-engine compatible. The new `DropRulesTests` exercise these decisions independently of SpriteKit. Add real-scene integration tests and benchmark corner cases. Long-lived suspended bodies that never fall or settle require investigation, not silent false scoring.

**Physics design debt:** current contact detection looks at vertical body-center relation and can misclassify side contacts. True support should use contact normals and a grounded support graph, especially for wedge/diamond pieces. World snapshot parity remains entirely unimplemented. The eventual physics engine decision must account for complete contact state, fixed stepping, simultaneous multi-body interactions and world cloning.


## 18. SpriteKit live-world repair and boundary — 2026-10-30

The experimental live world previously contained repeated landing detectors and specialized first-block acceptance; these produced inconsistent scoring and unbounded disabled controls. The new baseline contains:

- One static platform with explicit collision and contact filters.
- One dynamic body per physical piece, created from authored shape geometry and attached exactly at release.
- A uniform post-step landing evaluator and pure geometry/rules module.
- A short observed translation/rotation window instead of trusting contact callbacks or stale velocity alone.
- A real world-space miss boundary rather than time-based game-over.
- Moderate scene-point gravity, normalized mass, friction, and damping.
- No freezing or making placed pieces permanently static: later impacts can still affect the tower.

This is not an isolated-world prediction implementation; precise collision normals, true support graphs, snapshot parity and deterministic step control remain for the production physics experiment. Real iPhone tests are explicitly required before these heuristics can be considered validated. See [QA smoke checklist](qa-smoke-checklist.md).


---

## 19. Ball jitter and slower arcade gravity — latest tuning, 2026-10-30

**Current implementation authority:** \`StackcidentApp/Game/GameFeel.swift\` in GitHub. Historical gravity values in earlier sections document the evolution of the prototype and are no longer authoritative. The currently proposed scene-point tuning uses gravity **−195 points/s²** (previously −420), an initial spawn clearance of 230 points, and 170 points above the high point of a growing stack.

**Reasoning:** At constant gravitational acceleration, an idealized free-fall time over vertical distance \`h\` is \`sqrt(2h/|g|)\`. Changing both acceleration and release height is required to make a perceptibly slower yet readable drop. SpriteKit contact, damping, moving supports and display frame timing can change observed timing; estimate is not a measurement.

**Sphere stabilization measures:**
1. Keep the sphere as a true circle fixture, with authored geometry reused at release.
2. Apply zero restitution and lower sliding friction than box-shaped pieces; do not force it to stick to surfaces or use a static body.
3. Use additional angular damping on the sphere to dissipate tiny contact-induced rotational energy while preserving rolling under meaningful forces.
4. Use normal \`SKPhysicsBody\` resting behavior only when a **grounded and very slow** object has already passed landing acceptance. Explicitly set near-zero residual velocity to zero and mark \`isResting\`; new impacts are allowed to wake dynamic bodies.
5. Disable continuous collision detection in this low-speed toy-scale prototype pending explicit thin-object tunneling tests; this is not a universal production optimization.
6. Treat persistent jitter under wedge/ball/beam stacks as an **open physics issue until actually measured**. Damping alone is not a mathematical guarantee, and polygon-corner penetration/stacking configurations can still be poorly conditioned.

**Feedback design:** the scene holds congratulatory labels for 1.75 seconds and fades over another 0.65 seconds; SwiftUI messages persist until the user initiates the next drop or a real failure. The separate "UP NEXT" pill gives the next piece's name without overwriting the result.

**Acceptance source:** FR-094–099, NFR-068–072 in [requirements.md](../requirements.md) and tests FEEL-01–09. No on-device jitter analysis or frame capture has been performed within this session.
