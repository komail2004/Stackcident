# Stackcident — Functional and Non-Functional Requirements
**Document ID:** STK-SRS-001  
**Version:** 1.0 — Baseline specification  
**Date:** 2026-10-29  
**Status:** Proposed and testable requirements; not an implementation claim  
**Platform scope:** **Native Apple iOS app for iPhone, exclusively.** No Android, web-playable, desktop, or cross-platform runtime is in scope for V1.  
**Companion:** [overview.md](overview.md)  
**Owner:** Stackcident project

> Stackcident is an iPhone-only, portrait-first, touch-controlled, physics-based stacking game. Players position and rotate absurd objects, drop them onto a tower, and may use scarce **Future Vision** charges to watch a separate, short physics simulation of a possible future before committing. The simulation must never mutate live gameplay.

## 0. Normative language, IDs, scope and traceability

- **SHALL / MUST**: mandatory for the indicated release scope.
- **SHOULD**: strongly recommended; document deviations.
- **MAY**: optional.
- **MVP**: mandatory for first playable, testable iPhone prototype.
- **V1**: mandatory before first public iOS App Store release.
- **V1+**: explicitly excluded from V1; proposed future enhancement.
- **P0**: release-blocking correctness, safety, or core function.
- **P1**: expected launch feature.
- **P2**: optional polish or later milestone.
- All acceptance tests use IDs `AT-...`, matching `FR-...` and `NFR-...`.
- Numerical performance targets are **engineering acceptance targets** to verify on actual hardware, not promises.
- This specification takes precedence over preliminary alternatives in overview.md for scope and acceptance; any intentional change requires a documented decision and revision to both documents.

### 0.1 iOS-only commitment
Stackcident SHALL:
1. Be authored in **Swift** with **SwiftUI** for native navigation and UI.
2. Use an iOS-compatible native 2D rendering/physics stack (SpriteKit candidate; selection gated by physics parity).
3. Compile and run as an actual signed **iOS/iPhone application** in Xcode.
4. Use native iOS lifecycle, touch, audio/haptics, accessibility, safe-area and persistence capabilities.
5. Remain playable **fully offline** after installation for core single-player functionality.
6. Be verified on at least two physical iPhone performance tiers before App Store release.
7. Support portrait orientation initially; iPad adaptation is outside V1 scope.
8. Avoid treating a responsive website or PWA as an acceptable substitute for the iOS app.
9. Use TestFlight for pre-release device distribution, with Apple Developer Program requirements fulfilled before external testing and release.
10. Choose a specific minimum supported iOS release before implementation; document it in build settings and compatibility matrix, not as an unverified guess.

### 0.2 Players and stakeholders
- **Player:** wants immediate, repeatable fun and an understandable preview before risky moves.
- **First-time player:** needs a short playable onboarding path.
- **Returning player:** expects persisted personal bests, settings, and consistent controls.
- **Player using accessibility settings:** requires alternative controls and useful non-color risk indicators.
- **Developer/tester:** requires reproducible simulation fixtures and performance diagnostics.
- **App Store reviewer:** must be able to experience complete playable functionality without privileged credentials or inaccessible external services.

### 0.3 Exclusions
No user-generated AI conversations, live banking, chat, advertising SDK, online account requirement, cross-platform build, user-to-user messaging, multiplayer, server-based game authority, paid prediction consumables, or real-money rewards in MVP/V1. App Store commerce, Game Center, advanced puzzles, daily challenges, saved replay exports, and trained ML prediction are separate V1+ decisions unless explicitly promoted by revision.

---

# PART I — FUNCTIONAL REQUIREMENTS (WHAT THE APP DOES)

## 1. App lifecycle, menus and navigation

**FR-001 [MVP/P0] Native entry:** The iOS app SHALL launch directly into Stackcident's native UI without a login, external browser, or network connection.  
**AT-FR-001:** Install on physical iPhone, enable Airplane Mode, cold launch and reach menu.

**FR-002 [MVP/P0] Menu actions:** The home screen SHALL provide functional Play, How to Play and Settings entry points. No dead-end placeholder buttons shall appear.  
**AT-FR-002:** Tap each action and verify an expected destination/back path.

**FR-003 [MVP/P0] Game state machine:** Distinct states SHALL include menu, tutorial, aiming, predicting, dropping, settling, paused, ended; illegal transitions SHALL be ignored or explicitly handled.  
**AT-FR-003:** Automated state-transition matrix covers normal and invalid sequences.

**FR-004 [MVP/P0] Pause/resume:** Pause SHALL freeze game progression and show Resume, Restart and Home actions; resumed world SHALL not jump due to elapsed wall clock time.  
**AT-FR-004:** Pause during wobble, wait 30 seconds, resume and confirm continuity within physics tolerance.

**FR-005 [MVP/P1] App interruptions:** Backgrounding, phone calls, audio interruption and returning to foreground SHALL not silently consume Future Vision charges or trigger unintended drops.  
**AT-FR-005:** Background during aiming, preview calculation and settling.

**FR-006 [V1/P1] Navigation/safe area:** All screens SHALL respect iPhone safe areas including Dynamic Island/notches and home-indicator zone.  
**AT-FR-006:** Snapshot and manual interaction tests across selected notched and non-notched simulator profiles plus physical devices.

**FR-007 [MVP/P1] Immediate restart:** A game-over screen SHALL expose a prominent Retry action that starts a clean round without redoing onboarding.  
**AT-FR-007:** Lose three times, each restart produces fresh score, tower, rules and valid initial object.

## 2. Core simulation and controls

**FR-010 [MVP/P0] Rigid-body world:** The game SHALL simulate gravity, rotation, solid contact, friction and collision response for stacked objects.  
**AT-FR-010:** Scripted drop fixtures demonstrate falling, support, sliding, rotational instability and impact.

**FR-011 [MVP/P0] Placement:** Before release, player SHALL be able to reposition the offered object horizontally within visible legal bounds.  
**AT-FR-011:** Drag across entire range; object remains within allowed spawn region.

**FR-012 [MVP/P0] Rotation:** Player SHALL rotate the object with obvious on-screen controls; final intent includes exact angle.  
**AT-FR-012:** Rotate asymmetrical shape and confirm its visual/collision pose follows.

**FR-013 [MVP/P0] Explicit drop:** DROP control SHALL commit exactly one object per activation, at its current placement and orientation. No inadvertent release from repositioning.  
**AT-FR-013:** Rapid taps, multitouch, finger lift and background tests create at most one committed body.

**FR-014 [MVP/P0] Input lock:** While physics is dropping/settling or preview is computing, conflicting input SHALL not mutate active drop intent.  
**AT-FR-014:** Try rotate/drop repeatedly during transitions; world remains consistent.

**FR-015 [MVP/P0] Camera:** View SHALL follow growing tower smoothly with clamped playfield bounds; critical danger/off-platform area SHALL remain visually understandable.  
**AT-FR-015:** Simulate tall stack and verify no hidden committed piece, unreadable HUD or sudden camera jump.

**FR-016 [MVP/P0] Settlement:** The game SHALL determine when a drop has sufficiently settled or exceeded a documented maximum wait; it SHALL not hang indefinitely on microscopic oscillations.  
**AT-FR-016:** Highly unstable/never-sleep fixture progresses to resolution within configured bound.

**FR-017 [MVP/P0] Loss rules:** Explicit, consistent rules SHALL identify when a stack is lost. Decorative particles SHALL not trigger loss.  
**AT-FR-017:** Fixtures for off-platform piece, collapse, edge contact, and harmless debris.

**FR-018 [MVP/P0] Score:** Survived, fully resolved placements SHALL increment base score exactly once; rejected or failed drops SHALL not falsely score.  
**AT-FR-018:** Confirm score at first drop, late collapse and restart.

**FR-019 [MVP/P1] Object queue:** Every round SHALL provide next objects from a documented seeded or curated sequence and SHALL not spawn objects with invalid or intersecting starting poses.  
**AT-FR-019:** Run 1,000 offline generated opening states through validity checks.

**FR-020 [V1/P1] Difficulty:** Challenge SHALL grow through object properties, combinations and stack geometry, not hidden mid-run physics changes or forced loss.  
**AT-FR-020:** Audit rules/physics constants over sequence and conduct human fairness tests.

**FR-021 [MVP/P0] Single authoritative world:** Exactly one live gameplay world SHALL determine actual outcomes and scores. Preview results cannot directly commit gameplay changes.  
**AT-FR-021:** State checksum unchanged after any preview/cancel sequence.

## 3. Objects, content and collisions

**FR-030 [MVP/P0] Object catalog:** Each object SHALL have a stable ID, visual definition, collision geometry, mass/density, center of mass, friction, restitution and spawn constraints.  
**AT-FR-030:** Schema validation rejects missing/invalid fields and impossible mass/geometry.

**FR-031 [MVP/P1] Starter content:** Playable vertical slice SHALL include at least 10 meaningfully different collision/behavior shapes; public V1 target is 15–25 tuned objects.  
**AT-FR-031:** Catalog audit and in-game playability review.

**FR-032 [MVP/P0] Collision integrity:** Collision boundaries SHALL plausibly correspond to displayed shapes, avoiding unexplained hovering and deep overlaps.  
**AT-FR-032:** Visual overlay debug tests for every asset.

**FR-033 [V1/P1] Content validation:** Each added object SHALL pass stable, marginal and collapse scenario tests, including Future Vision parity.  
**AT-FR-033:** Per-object test checklist signed off.

**FR-034 [V1/P1] Balanced difficulty:** Rare or advanced objects SHALL not appear before corresponding difficulty tier unless explicitly part of a curated tutorial or challenge.  
**AT-FR-034:** Seeded generation tests inspect tier distribution.

## 4. Future Vision — defining feature

**FR-040 [MVP/P0] Entry:** Before an object has been committed, the player SHALL be able to request Future Vision when at least one charge remains and simulation is supported.  
**AT-FR-040:** Request succeeds in aiming state; button disabled elsewhere.

**FR-041 [MVP/P0] Isolated simulation:** Future Vision SHALL instantiate or restore a distinct prediction physics world from a complete immutable snapshot; it SHALL NEVER fast-forward the live world and roll it back.  
**AT-FR-041:** Live world hash before/after preview equals exactly, except intentional UI/charge state.

**FR-042 [MVP/P0] Same physics:** Preview SHALL use the same underlying physics rules, object geometry, collision filters and timestep model as the authoritative world.  
**AT-FR-042:** Architecture inspection and parity fixtures.

**FR-043 [MVP/P0] Snapshot completeness:** Snapshot SHALL capture positions, angles, velocities, dynamics, solver configuration, objects, relevant random state, moving constraints, and a world revision ID; any unrepresentable state SHALL fail safely.  
**AT-FR-043:** Serialize/reconstruct representative moving and settled worlds and compare state.

**FR-044 [MVP/P0] Intended drop fidelity:** Simulated release SHALL use the same intended object, pose and release rules that real DROP uses.  
**AT-FR-044:** Compare intent fingerprint passed to preview and authoritative drop.

**FR-045 [MVP/P0] Prediction horizon:** Preview SHALL simulate a bounded, configurable short window, initial target 2–3 seconds, and SHALL record pose samples for the ghost replay.  
**AT-FR-045:** Verify sample timestamps and final frame at set horizon.

**FR-046 [MVP/P0] Visual playback:** The preview SHALL visibly differentiate simulated ghost bodies from solid real bodies and label it as a simulated future.  
**AT-FR-046:** Usability test asks player to identify real versus simulated world.

**FR-047 [MVP/P0] Classification:** The prediction service SHALL classify results as Stable, Wobbly, Collapse Risk or Uncertain using documented thresholds.  
**AT-FR-047:** Known fixtures and boundary cases yield defined outcomes.

**FR-048 [MVP/P0] No false guarantees:** Game SHALL not present physics forecasts as perfect certainties or show numerical success probabilities without calibrated statistical evaluation.  
**AT-FR-048:** UI text review and test of near-threshold scenario.

**FR-049 [MVP/P0] Charges:** MVP SHALL start each run with three charges; one SHALL be consumed only after a prediction is successfully delivered, never for error/cancellation. Count SHALL never become negative.  
**AT-FR-049:** Successful, cancelled, timed-out, repeated tap and background cases.

**FR-050 [MVP/P0] Stale result rejection:** Changing position/angle, tower state or round SHALL invalidate previous predictions; late results tagged to an older revision SHALL be discarded.  
**AT-FR-050:** Move piece while simulation runs and verify no stale result is presented as current.

**FR-051 [MVP/P0] Failure fallback:** Timeout, invalid snapshot, solver exception or memory pressure SHALL result in clear “Prediction unavailable” feedback without losing the run or charging tokens.  
**AT-FR-051:** Fault-injection tests for each failure.

**FR-052 [MVP/P1] Prediction controls:** User SHALL be able to dismiss ghost preview, inspect it long enough to understand, and then continue aiming.  
**AT-FR-052:** Preview → dismiss → rotate → drop behaves normally.

**FR-053 [V1/P0] Parity acceptance:** Automated prediction-vs-actual drop comparisons SHALL be run over a documented fixture suite and representative physical iPhones; thresholds for outcomes, trajectory deviations and acceptable ambiguous classifications SHALL be fixed from prototype evidence before shipping.  
**AT-FR-053:** Versioned parity report with pass/fail criteria and no known severe misleading previews.

**FR-054 [V1/P1] Performance constraints:** Preview SHALL have bounded time, memory and frames; no freeze or unexpectedly long unresponsive state is acceptable.  
**AT-FR-054:** Instrument p50/p95 prediction latency on device tiers, and exercise worst-case tower.

**FR-055 [V1/P1] Transparent caveat:** If user changes the pose after viewing prediction, UI SHALL clearly remove or invalidate preview; brief explanatory copy SHALL clarify that outcomes may differ with timing or setup changes.  
**AT-FR-055:** UI interaction and copy review.

**FR-056 [V1+/P2] Branch previews:** Multiple possible futures and calibrated learned risk estimates MAY be explored only after base preview accuracy is demonstrated.  
**AT-FR-056:** Separate product decision; not launch-blocking.

## 5. User feedback, scoring and results

**FR-060 [MVP/P1] Feedback:** Game SHALL distinguish an ordinary successful drop, a notable wobble, a loss and a preview without relying solely on color.  
**AT-FR-060:** Play in grayscale/silent mode and identify outcomes.

**FR-061 [MVP/P1] Game over:** Final screen SHALL display achieved score, previous best where available and clear Retry/Home actions.  
**AT-FR-061:** Best score persists after restart and full app relaunch.

**FR-062 [V1/P1] Moments of delight:** Appropriate sound/haptic feedback SHALL communicate pickup, landing and collapse, subject to user's preferences and system capability.  
**AT-FR-062:** Toggle sound/haptics and confirm suppression.

**FR-063 [V1+/P2] Replay:** Local bounded state recording MAY support an instant replay and share/export only after core performance is stable.  
**AT-FR-063:** Optional feature separately tested for fidelity, user consent and storage limits.

**FR-064 [V1+/P2] Daily challenges:** A seeded level MAY offer identical objects, rules and scoring within a defined version. Cross-device fairness MUST be validated before online rankings.  
**AT-FR-064:** Same seed produces same offered sequence and documented configuration.

## 6. Tutorial, settings and persistence

**FR-070 [MVP/P1] Interactive onboarding:** First run SHALL teach drag, rotate, drop and Future Vision through interactive steps; tutorial SHALL be skippable/replayable.  
**AT-FR-070:** New tester completes a successful first drop and preview without live coaching.

**FR-071 [MVP/P1] Settings:** Game SHALL expose sound, haptic and reduced-motion preferences, and provide a direct way back to menu.  
**AT-FR-071:** Change toggles, relaunch, verify persisted choices.

**FR-072 [MVP/P0] Local best score:** Personal best and essential settings SHALL persist on-device across normal app termination and updates.  
**AT-FR-072:** Finish run, force quit, reopen; records intact.

**FR-073 [V1/P1] Versioned storage:** Persisted data SHALL have a versioned schema and safe migration or recovery strategy; invalid records SHALL not crash startup.  
**AT-FR-073:** Load prior versions, missing keys and corrupted test fixtures.

**FR-074 [V1/P1] Offline baseline:** Menu, tutorial, core play, prediction, personal best and settings SHALL require no Wi-Fi, account or server.  
**AT-FR-074:** Airplane Mode full-session regression test.

**FR-075 [V1/P1] Session interruption policy:** When app is killed during a run, either restore a validated safe session snapshot or explicitly restart; no ambiguous phantom score, double drop or spent charge.  
**AT-FR-075:** Termination during aiming, preview, fall and settlement.

**FR-076 [V1/P1] Data reset:** Settings SHALL offer a deliberate confirmation step before clearing local progress/data, if reset functionality is included.  
**AT-FR-076:** Cancel leaves data unchanged; confirm deletes specified data.

## 7. Monetization and external iOS services

**FR-080 [V1/P1] Honest product value:** The core play and Future Vision experience SHALL not depend on subscriptions or network API calls.  
**AT-FR-080:** Full core play with no purchases and Airplane Mode under chosen distribution model.

**FR-081 [V1/P1] Pricing decision gate:** Choose paid upfront versus free/lifetime unlock based on player testing and current App Store rules before implementing purchase UI. Prices are proposals, not commitments.  
**AT-FR-081:** Recorded product decision and corresponding working purchase paths.

**FR-082 [Conditional V1/P0] StoreKit compliance:** If in-app digital content is sold, purchase, entitlement verification, restoration and error handling SHALL use an appropriate Apple in-app-purchase implementation (StoreKit 2 candidate).  
**AT-FR-082:** Sandbox purchases, cancellation, failed transaction, reinstall/restore and entitlement validation.

**FR-083 [V1/P0] Competitive fairness:** Predictions that materially alter competitive scoring SHALL not be sold as extra advantages on equivalent public leaderboards.  
**AT-FR-083:** Economy/score rules audit.

**FR-084 [V1+/P2] Game Center:** Leaderboards and achievements MAY be added after local gameplay is reliable; offline core functionality SHALL remain intact without Game Center sign-in.  
**AT-FR-084:** Signed-out player still plays normally.

**FR-085 [V1/P1] Release access:** App Store review SHALL be able to access full gameplay and required purchases via standard review/sandbox workflows, without private credentials.  
**AT-FR-085:** Reviewer-style clean install walkthrough.

## 8. Error handling and observability

**FR-090 [MVP/P0] Safe failures:** Unexpected errors in optional systems SHALL fail without corrupting live physics, player score or local saves.  
**AT-FR-090:** Inject failure in audio, prediction and optional storage.

**FR-091 [MVP/P1] User-readable states:** Loading, unavailable preview, paused state, first-run/tutorial and loss SHALL have understandable messages.  
**AT-FR-091:** Manual accessibility and error-copy review.

**FR-092 [V1/P1] Local diagnostics:** Development builds SHALL expose frame time, simulation time, object count, world revision and preview/actual comparison tools without transmitting private user information.  
**AT-FR-092:** QA can reproduce and characterize a failed physics fixture.

**FR-093 [V1/P1] No fake completion:** Disabled or unfinished features SHALL not appear as completed, interactive menu actions.  
**AT-FR-093:** Every visible button invokes supported functionality.

---

# PART II — NON-FUNCTIONAL REQUIREMENTS (HOW WELL IT MUST WORK)

## 9. Platform, implementation and compatibility

**NFR-001 [V1/P0] iOS-native delivery:** The distributed artifact SHALL be a signed native iOS app installable on supported iPhones and distributed via TestFlight/App Store. A browser game, PWA, Android package or Vercel site does not satisfy this requirement.  
**Verification:** Xcode archive, TestFlight install and physical iPhone launch.

**NFR-002 [MVP/P0] Swift-first codebase:** Game client SHALL use Swift; SwiftUI SHALL host the native app, navigation and overlays. The chosen 2D engine SHALL integrate with iOS natively.  
**Verification:** Build review, source inspection.

**NFR-003 [V1/P0] Supported versions:** Minimum iOS version and exact supported device family SHALL be documented and enforced in project settings prior to release.  
**Verification:** Info.plist/build setting and compatibility test matrix.

**NFR-004 [V1/P1] Portrait first:** Play SHALL support portrait iPhone layouts and scale across targeted display sizes. Unsupported orientations SHALL not produce broken UI.  
**Verification:** Layout snapshots and rotation test.

**NFR-005 [V1/P1] Apple ecosystem compliance:** App SHALL meet the App Review Guidelines and current privacy/permission/store disclosure rules applicable at release time.  
**Verification:** Pre-submit review checklist against current official rules.

**NFR-006 [V1/P1] No nonessential entitlements:** Request no location, contacts, photos, microphone, or tracking permission unless a specifically implemented feature requires it and user action justifies it.  
**Verification:** Entitlement/permission audit.

## 10. Performance, resource limits and responsiveness

**NFR-010 [V1/P0] Interactive frame-rate target:** Target steady **60 FPS** during normal gameplay on selected reference iPhones; define device matrix and test conditions before declaring a pass. If device thermal/power limits require fallback, gameplay SHALL remain responsive.  
**Verification:** Instruments profiling on device with early, medium and late towers.

**NFR-011 [MVP/P0] Fixed simulation timestep:** Physics SHALL use a documented consistent timestep independent of draw frame rate.  
**Verification:** Instrument tick intervals and run reproducible fixtures.

**NFR-012 [V1/P0] Preview latency target:** Initial goal: complete a 2-second, 10–30-body preview in **less than 1 second at p95** on selected supported reference hardware; benchmark and revise only through documented architectural decision.  
**Verification:** 100+ preview samples per device/scenario, report p50/p95/p99.

**NFR-013 [V1/P0] UI responsiveness:** No routine preview computation SHALL block main-thread interaction for more than **100 ms** on reference devices; loading/cancel affordance remains available.  
**Verification:** Main Thread Checker and Instruments traces.

**NFR-014 [V1/P1] Bounded computation:** Preview simulation SHALL enforce a fixed step budget, cancellation, timeout, and memory cap appropriate to device class.  
**Verification:** Stress tests with unusually tall/complex towers.

**NFR-015 [V1/P1] Load-time target:** Initial target to show interactive main menu in **3 seconds at p95 on reference devices after warm launch**; benchmark separately for cold launch.  
**Verification:** Automated launch metrics on selected phones.

**NFR-016 [V1/P1] Resource efficiency:** Game SHALL not grow memory indefinitely across repeated retries, previews or screen changes; test at least 100 sequential runs and prediction cycles.  
**Verification:** Memory graph, leak checks, extended soak tests.

**NFR-017 [V1/P1] Thermal/battery:** Repeated play SHALL be profiled for sustained frame-rate decline and battery/thermal impacts. Physics complexity SHALL scale down or recover gracefully when necessary.  
**Verification:** 30-minute sustained session with profiling and temperature state records.

**NFR-018 [V1/P1] Smooth transitions:** UI and camera movement SHALL not produce disruptive frame stalls under ordinary gameplay.  
**Verification:** Frame-time trace review during tall stacks, preview playback and collapse.

## 11. Reliability, determinism and integrity

**NFR-020 [MVP/P0] Live state isolation:** Requesting, completing, cancelling or failing Future Vision SHALL not mutate live rigid-body state, scoring or pending object choice; permitted charge/UI changes SHALL be isolated.  
**Verification:** Byte-equivalent canonical game-state digest before/after preview.

**NFR-021 [V1/P0] Reproducible fixtures:** Identical simulation inputs and configuration on the same supported environment SHOULD yield reproducible outcome trajectories within measured tolerances.  
**Verification:** Repeated controlled fixtures with reported deltas.

**NFR-022 [V1/P0] Prediction trust:** Known cases of substantially false confident previews SHALL block release; uncertainty should be presented near sensitivity thresholds.  
**Verification:** Versioned coverage/parity report plus human observation.

**NFR-023 [V1/P0] No silent data corruption:** Crashes, interruptions and storage faults SHALL not destroy otherwise valid saved records or falsely record high scores.  
**Verification:** Simulated incomplete/corrupt writes and kill/relaunch.

**NFR-024 [V1/P1] Defensive input processing:** Invalid content configurations, nonfinite numerical values, illegal angles and extreme body settings SHALL be rejected or clamped before simulation.  
**Verification:** Fuzz/property tests and catalog schema validation.

**NFR-025 [V1/P1] Graceful degradation:** Failure of optional audio, haptics, Game Center or preview animation SHALL not prevent basic physical stacking and navigation.  
**Verification:** Disable or fault each peripheral feature.

**NFR-026 [V1/P1] Reproducible builds:** Release source revision, Xcode version, iOS SDK, asset versions and physics configuration SHALL be recorded in release notes/build metadata.  
**Verification:** Release artifact audit.

## 12. Security and privacy

**NFR-030 [V1/P0] Offline-first privacy:** Core game SHALL neither require account creation nor send gameplay/personal information to a server.  
**Verification:** Network inspection during core Airplane Mode and connected sessions.

**NFR-031 [V1/P0] Data minimization:** Store only necessary settings, scores, unlocks and gameplay data. No collection of bank details, identity documents, contacts, or location.  
**Verification:** Storage model and permission audit.

**NFR-032 [V1/P0] Secrets:** No API secret, App Store private key or signing secret SHALL be committed into the repository or embedded in released client code.  
**Verification:** Secret scanning and signing configuration review.

**NFR-033 [V1/P1] Local protection:** Durable data SHALL use appropriate iOS app sandbox and data-protection behavior, and the app SHALL not create unprotected public exports without intentional user action.  
**Verification:** File protection/storage review.

**NFR-034 [V1/P1] Permission transparency:** New permissions or network integrations require prior purpose documentation, plain-language consent where applicable, and privacy disclosure updates.  
**Verification:** Privacy checklist for each new feature.

**NFR-035 [V1/P1] Sharing consent:** Any later replay export SHALL only occur via an explicit user action with an iOS share-sheet or save workflow.  
**Verification:** Verify no background uploads or automatic external sharing.

**NFR-036 [V1/P1] Third-party SDK discipline:** Avoid unnecessary advertising, tracking or analytics SDKs; evaluate privacy manifests and data use before adding dependencies.  
**Verification:** Dependency inventory and App Store privacy labels review.

## 13. Usability, accessibility and presentation quality

**NFR-040 [V1/P0] Readable core UI:** Critical controls and indicators SHALL be legible on supported iPhone sizes, without clipping, overlap or unsafe touch positions.  
**Verification:** Device/simulator UI matrix.

**NFR-041 [V1/P0] Control discoverability:** New testers SHALL identify how to aim and drop from the tutorial and obvious controls; failures SHALL produce actionable feedback.  
**Verification:** Moderated usability study with task completion notes.

**NFR-042 [V1/P1] Touch target sizing:** Interactive controls SHOULD meet Apple's current applicable touch target guidance, with comfortably spaced alternatives for rotation and drop.  
**Verification:** Design audit and touch testing on smallest supported phone.

**NFR-043 [V1/P1] Accessibility semantics:** Menus/settings SHALL expose meaningful VoiceOver labels, traits and focus behavior. Gameplay SHALL offer accessible alternative controls to gestures where feasible and document limitations honestly.  
**Verification:** VoiceOver walkthrough with manual testing.

**NFR-044 [V1/P1] Reduced motion:** Respect Reduce Motion or expose reduced effects for screen shake, rapid camera zoom, ghosts and other intense transitions.  
**Verification:** Test with system Reduce Motion enabled.

**NFR-045 [V1/P1] Color independence:** Risk indicators SHALL not depend on color alone; labels/icons/patterns SHALL communicate status.  
**Verification:** Grayscale and color-vision simulation review.

**NFR-046 [V1/P1] Audio/haptic alternatives:** Audio or vibration SHALL never be the sole means of perceiving a critical result; both may be disabled.  
**Verification:** Silent, no-haptics playthrough.

**NFR-047 [V1/P1] Consistent look:** Animations, collision geometry, visual contrast and object silhouettes SHALL convey credible gameplay rather than misleading physical shapes.  
**Verification:** Visual QA + collision debug overlays.

**NFR-048 [V1/P1] Inclusive content:** Humor, commentary and graphics SHALL avoid harassing, discriminatory or disturbing material inconsistent with the intended audience/age rating.  
**Verification:** Content audit and age-rating review.

**NFR-049 [V1/P1] Localization readiness:** All user-facing text SHOULD be extractable/localizable rather than hard-coded into images; V1 language coverage requires a separate product choice.  
**Verification:** String resource inspection.

## 14. Maintainability, testability and code quality

**NFR-050 [MVP/P0] Module boundaries:** Physics, predictive simulation, gameplay rules, UI and persistence SHALL have distinguishable interfaces; UI must not reimplement or shadow authoritative physics calculations.  
**Verification:** Architecture and dependency review.

**NFR-051 [MVP/P0] Automated parity tests:** CI or local automation SHALL run stable, edge, rolling, multi-contact and collapse simulations comparing preview to matching actual drops.  
**Verification:** Executable fixtures with machine-readable pass/fail reports.

**NFR-052 [V1/P1] Test pyramid:** Unit tests SHALL cover score, charge economy, state transitions, invalidation, persistence and catalog validation; UI tests cover critical flow.  
**Verification:** Test reports for named requirements.

**NFR-053 [V1/P1] Code standards:** Formatting, naming, static warnings and error handling SHOULD follow a documented Swift code standard; no ignored build warnings with known correctness implications.  
**Verification:** PR checklist/build output.

**NFR-054 [V1/P1] Dependency control:** Dependencies SHALL have pinned or tracked versions, evaluated licenses, and a documented reason for use; prefer standard iOS frameworks for core features.  
**Verification:** Package manifest/license review.

**NFR-055 [V1/P1] Documentation hygiene:** Requirements, overview, physics decisions, testing reports and release procedures SHALL be version-controlled. Proposed features SHALL not be documented as shipped.  
**Verification:** Documentation audit each milestone.

**NFR-056 [V1/P1] Observability for developers:** Debug instrumentation SHALL make it possible to inspect body IDs, positions, contacts, per-frame timings and parity differences without including it in normal player UI.  
**Verification:** Reproduce a test fixture with debug overlay.

**NFR-057 [V1/P1] Release CI:** A repeatable macOS/Xcode build-and-test path SHOULD be maintained; code signing secrets SHALL be managed outside the source repository.  
**Verification:** Clean checkout/build and documented signing workflow.

## 15. Apple deployment, App Store and commercial quality

**NFR-060 [V1/P0] Installable release:** Release SHALL be an Xcode-produced archive of the iOS app, signed with the appropriate Apple configuration, and pass TestFlight installation and launch.  
**Verification:** Archive + TestFlight records.

**NFR-061 [V1/P0] App Store readiness:** Provide accurate app name, icons, screenshots from actual gameplay, age rating, privacy disclosures, support contact, review notes and current required declarations.  
**Verification:** Submission checklist.

**NFR-062 [V1/P0] Honest claims:** No claim of “real AI learning,” perfect future knowledge or guaranteed physics outcome unless implemented and validated. “Future Vision — physics simulation preview” is the baseline wording.  
**Verification:** Marketing/app-store text review.

**NFR-063 [Conditional V1/P0] Purchase integrity:** If monetization uses a lifetime in-app unlock, App Store product identifiers, purchase verification, restore and entitlement persistence SHALL be tested using StoreKit sandbox.  
**Verification:** Transaction matrix including cancellation/refund where supported.

**NFR-064 [V1/P1] Cost control:** Core functionality SHALL require no runtime AI API, backend, hosted model or paid per-user service.  
**Verification:** Dependency/network audit and operating-cost sheet.

**NFR-065 [V1/P1] IP and licensing:** All art, audio, fonts and physics dependencies SHALL have appropriate rights or licenses for commercial App Store distribution.  
**Verification:** Asset manifest with sources and licenses.

**NFR-066 [V1/P1] Supportability:** V1 SHALL include in-app support/contact and privacy information and documented app version.  
**Verification:** Review build and functional links.

**NFR-067 [V1/P1] Store identity:** Name Stackcident is a working selection until App Store name/trademark checks clear; no assertion of exclusivity without research.  
**Verification:** Product/legal sign-off.

---

# PART III — ACCEPTANCE PLAN AND DELIVERY GOVERNANCE

## 16. Primary user journeys / end-to-end acceptance

**E2E-01 First play**  
Given a clean iPhone install and no internet, when the player launches the game, the menu appears; the player can complete tutorial, place and rotate an object, drop it, see a physical response and continue or fail correctly.

**E2E-02 Future Vision rescues a run**  
Given a valid aim state and one or more charges, when the player previews a risky drop, the real tower remains unchanged; the ghost playback and risk text appear; the player alters position; the stale preview clears; the subsequent real drop follows authoritative physics and a successful preview decrements exactly one charge.

**E2E-03 Failed preview**  
Given an overloaded or deliberately failed simulation, when Future Vision is triggered, the player sees an understandable unavailable message, loses no charge, and can still drop/restart.

**E2E-04 Core persistence**  
Given a completed round setting a personal best, when the user closes and reopens the app, the score and settings persist; no network is needed.

**E2E-05 Interruptions**  
Given a partially aimed object or a pending preview, when the app backgrounds and resumes, it does not perform an unrequested drop or consume a prediction.

**E2E-06 Accessibility**  
Given Reduce Motion, VoiceOver enabled for menus, and sound/haptics turned off, the player can navigate menus and understand critical outcomes through text/visual indicators and alternative controls.

**E2E-07 iOS distribution**  
Given the release candidate, it archives in Xcode, installs through TestFlight on supported iPhones, launches in Airplane Mode, and plays without a server.

**E2E-08 Fair losing conditions**  
Given a tower near the loss threshold, physically harmless debris does not instantly end a round; genuine structural collapse triggers the documented loss rule once, with no double scoring.

**E2E-09 Repeated predictions**  
Given a preview charge balance, rapid repeated taps create no duplicate concurrent charging or stale overlays; one displayed valid preview costs one charge.

**E2E-10 Store flow (conditional)**  
Given a free-with-unlock model, a sandbox purchase unlocks intended content, cancellation does not, and reinstall/restore follows Apple entitlements correctly.

## 17. Traceability and priority map

| Milestone | Blocking functional IDs | Blocking non-functional IDs | Exit evidence |
|---|---|---|---|
| Physics proof of concept | FR-010–018, FR-021, FR-040–048, FR-050–051 | NFR-002, NFR-011, NFR-020, NFR-050–051 | Real iPhone demo + initial parity fixtures |
| Playable MVP | FR-001–007, FR-019, FR-030–031, FR-049, FR-060–061, FR-070–072 | NFR-001–002, NFR-030, NFR-040–041 | Full first-run-to-retry path offline |
| V1 engineering hardening | FR-020, FR-032–034, FR-053–055, FR-073–075 | NFR-003–006, NFR-010–018, NFR-021–026, NFR-031–057 | Device benchmarks, reliability tests, accessibility review |
| App Store release | FR-080–085 (applicable), FR-090–093 | NFR-060–067 | TestFlight and App Store submission checklist |
| Post-V1 | FR-056, FR-063–064, FR-084 | Conditional updates | New decision records and revised requirements |

**Requirement coverage rule:** before any milestone is marked complete, each mandatory ID for that milestone needs one of: automated passing test, signed manual QA evidence, or documented exception with reason/owner. No silent omissions.

## 18. Detailed test fixtures for Future Vision

- **PV-01 Centered stable:** Rectangular block drops onto aligned flat stack; ghost and actual remain within agreed pose tolerances.
- **PV-02 Marginal overhang:** Near-edge placement yields wobble/uncertain class, not unjustified certainty.
- **PV-03 Rolling sphere:** Ball rolls off after contact; preview captures roll direction and whether loss occurs.
- **PV-04 Rotated asymmetry:** Uneven object at different angles produces appropriately different contact response.
- **PV-05 Moving stack:** Pre-existing body has nonzero velocity; recreated preview includes it.
- **PV-06 Chain reaction:** Three or more contacts lead to collapse; all bodies resolve without missing collision.
- **PV-07 High stack:** 30-body target; latency and memory within documented device budget.
- **PV-08 Prediction cancel:** Cancel calculation, charge untouched and live state identical.
- **PV-09 Pose change:** Result computed for old pose never overlays new pose.
- **PV-10 Sleep-state parity:** Sleeping/waking transitions produce acceptably consistent outcomes.
- **PV-11 Background and resume:** Preview interrupted by iOS lifecycle remains safe.
- **PV-12 Corrupt snapshot:** Service returns unavailable without crash.
- **PV-13 Multiple rapid taps:** Charge consumption is idempotent per accepted request.
- **PV-14 Uncertain boundary:** Highly sensitive near-fall outcome reports uncertainty where warranted.
- **PV-15 Real-vs-preview audit:** Record body trajectory deltas and class agreement for each fixture.

## 19. Required evidence and metrics

Before engineering sign-off, record:
1. Supported Xcode, iOS SDK, minimum iOS and exact iPhone test devices.
2. Preview physics model, fixed timestep, solver settings and complete snapshot contract.
3. p50/p95/p99 prediction latency under typical and worst-case scenes.
4. Gameplay frame-time distribution and worst-case frame stalls.
5. Preview/live parity: final-class agreement, body transform deviation and false-confident prediction count.
6. Memory usage after repeated runs and preview cycles.
7. Accessibility audit results and any known gameplay limitations.
8. TestFlight crash reports and physical-device issues.
9. Testers' ability to complete tutorial unaided, recognize ghost forecasts, and express willingness to retry.
10. App Store, asset rights and privacy/purchase review.

Quantitative parity and minimum fun/retention gates are deliberately **TBD until prototype measurements**; they must be made explicit before V1, not fabricated today.

## 20. Open product/engineering decisions

| ID | Decision needed | Initial recommendation | Timing |
|---|---|---|---|
| D-01 | Physics engine | Choose after isolated-world parity experiment; SpriteKit is candidate, not guaranteed | Before gameplay architecture |
| D-02 | Minimum iOS version | Set using actual Xcode and framework support, then test | Before project settings finalized |
| D-03 | Devices | Modern and older supported physical iPhones | Before performance gate |
| D-04 | Drop mechanic | Explicit DROP button | MVP |
| D-05 | Preview horizon | 2–3 s; bound by latency | Physics prototype |
| D-06 | Charge balance | Three per run | MVP playtesting |
| D-07 | Settlement and loss thresholds | Instrument physics before selecting numbers | Physics prototype |
| D-08 | Art style | Premium toy-box 2D, clean silhouettes | Vertical slice |
| D-09 | Monetization | Free + lifetime unlock vs paid upfront; no competitive pay-to-win | Before public launch |
| D-10 | Social/Game Center | Post-V1 | After core retention validation |
| D-11 | Portrait-only scope | iPhone portrait V1; iPad future | Now |
| D-12 | ML/AI layer | Simulation first; learned model only with measurable benefit | Post-validation |

## 21. Risks, assumptions and change control

### Assumptions
- The game is authored and tested using macOS/Xcode.
- A supported iPhone is available for performance, audio, haptic and TestFlight validation.
- V1 can be commercially useful without a backend.
- A 2D physics representation provides sufficient fun and clarity.
- “Future Vision” is implemented by simulation and accurately labeled.

### Critical risks
- Snapshot reconstruction misses hidden physics state and confident preview diverges.
- Complex stacks produce long preview times or main-thread freezes.
- Objects are visually amusing but mechanically unfair.
- The gameplay is technically correct but lacks replay value.
- App Store name, legal, licensing or reviewer issues delay release.

### Mitigation
- Build the two-world physics parity proof first.
- Instrument failures and budgets from day one.
- Playtest with non-developers before visual expansion.
- Keep physics fair and actual drop authoritative.
- Review Apple rules, asset licensing and store identity before submission.

### Revision policy
- Assign IDs to new requirements; do not silently reuse existing IDs.
- If scope or acceptance changes, record a version bump with the reason and affected tests.
- Maintain this requirements document and `overview.md` consistently.
- Mark implementation status separately: **proposed / in development / implemented / tested / shipped**.
- Do not present any unimplemented behavior as already functional.

---

## 22. Final acceptance definition

**MVP passes only when** a signed native iPhone build supports the complete aim → rotate → optional genuine two-world Future Vision → drop → physically simulated settle/collapse → score/loss → immediate retry loop, offline, with verified charge accounting and measured prediction parity.

**V1 public release passes only when** the above is polished, comprehensible to first-time players, device-tested, accessible to the extent documented, privacy-conscious, performant under defined conditions, and meets applicable App Store and monetization requirements.

**Fundamental distinction:** Stackcident is **an iOS game, not a web app**, and the flagship “see the future” interaction is **a legitimate physics preview, not an invented visual or an unsupported artificial-intelligence accuracy claim**.
