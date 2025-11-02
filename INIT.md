Below is a single, copy-pasteable **Cursor prompt** to bootstrap and ship the **“Stack Jumper”** mobile game in **Godot 4.3** end-to-end.

---

## CURSOR AGENT PROMPT — Build “Stack Jumper” in Godot 4.3 (Mobile)

**Role:** You are a senior Godot engineer + release manager.
**Goal:** Create and ship a polished, lightweight mobile game **Stack Jumper** in **2–3 weeks scope**. Implement everything: project setup, gameplay, UI, SFX, difficulty, save data, exports for Android/iOS, store assets (placeholders), and a README.

### 0) Project Constraints

* **Engine:** Godot **4.3** (stable). Use **GDScript** only.
* **Target:** **Android** (min SDK 24) & **iOS** (iOS 13+). Portrait mode only. 60 FPS target.
* **Art style:** Simple flat shapes + gradients; generate programmatically or use tiny PNGs/SVGs under `/assets/`.
* **Perspective:** **Plain side-view** vertical climber.
* **Controls:** Single-tap = jump. Optional: **double-jump** once per air time. No virtual joystick.
* **No backend.** Save locally (JSON). Optional: share score via OS share sheet.
* **Size goal:** < 50MB Android AAB, < 200MB iOS IPA.
* **Monetization (optional):** a single “Watch Ad to Continue” entry point (behind a feature flag, default **off** with stub). No tracking/SDK by default.

### 1) High-Level Game Design

**Core loop:** Player jumps from platform to platform as the stack rises. Miss = fall = Game Over.
**Platforms:** Move horizontally at varying speed; each new platform spawns slightly above previous.
**Camera:** Follows player upward; despawn objects below the bottom of the screen.
**Scoring:** +1 per landed platform; bonus coins (optional). **Best score** persisted.
**Difficulty ramp:** Gradually increase platform speed, reduce platform width, increase vertical gaps, introduce special platforms (breakable, conveyor, bounce).
**Juice:** Screen shake on land/miss (light), particle bursts, simple dynamic background gradient scrolling, subtle squash-and-stretch on landing, short haptic pulse.

### 2) Repository & Structure

Create a new Godot project with this tree:

```
/project.godot
/addons/                   # keep empty (no external deps)
/assets/fonts/             # Inter or NotoSans (OFL), and a pixel font
/assets/sfx/               # jump.wav, land.wav, coin.wav, gameover.wav (generated if needed)
/assets/icons/             # app icon 1024x1024 source + export sizes
/src/autoload/
    GameState.gd           # singleton: state machine, score, pause, save/load
    Save.gd                # wrapper around FileAccess JSON
/src/scenes/
    Main.tscn              # boot -> Menu -> Game -> GameOver
    Menu.tscn
    Game.tscn
    HUD.tscn               # score, pause, best, buttons
    Player.tscn
    Platform.tscn          # base platform
    PlatformSpawner.tscn
    Coin.tscn
/src/scripts/
    Main.gd
    Menu.gd
    Game.gd
    HUD.gd
    Player.gd
    Platform.gd
    PlatformSpawner.gd
    Coin.gd
/src/util/
    ObjectPool.gd
    Fx.gd                  # camera shake, particles helpers
/export/
    android/               # export presets, keystore instructions
    ios/                   # export presets, signing notes
/README.md
/LICENSE
```

### 3) Scenes & Nodes (Godot 4.3)

**Player.tscn**

* `CharacterBody2D` (Player) with `CollisionShape2D`, `Sprite2D` (or `Polygon2D`), `Particles2D`, `AudioStreamPlayer`.
* Exposed vars: `move_speed`, `jump_force`, `double_jump_enabled`, `coyote_time_ms`, `jump_buffer_ms`.
* States: `on_ground`, `has_double_jumped`.
* Methods: `_physics_process`, `jump()`, `apply_gravity()`, `handle_collisions()`.

**Platform.tscn**

* `StaticBody2D` root; child `Sprite2D` + `CollisionShape2D`.
* Variants by `type` enum: `NORMAL`, `CONVEYOR_LEFT/RIGHT` (applies horizontal delta to player), `BREAKABLE` (falls after landing), `BOUNCE` (stronger jump).
* Exposed vars: `width`, `speed`, `direction`, `lifetime_on_break`.

**PlatformSpawner.tscn**

* `Node2D` with timers; responsible for:

  * Spawn next platform above last Y with random X range inside camera width.
  * Horizontal move parameters per difficulty curve.
  * Occasionally spawn `Coin.tscn` above platform.

**HUD.tscn**

* Labels: `ScoreLabel`, `BestLabel`.
* Buttons: `PauseButton`, `ResumeButton`, `HomeButton`, `ShareButton`.
* “Watch Ad to Continue” button (hidden unless feature flag true & stub returns success).

**Game.tscn**

* `Node2D` root: contains `Player`, `PlatformSpawner`, `Camera2D` (smoothing), `CanvasLayer` for HUD, `ColorRect`/`ParallaxBackground` gradient sky.
* Handles game states: start, playing, paused, game over.

**Menu.tscn**

* Title, big `Play` button, `Sound` toggle, `Vibration` toggle, `Reset Best` (with confirm), `Credits`.
* Decorative animated background (slow parallax).

**Main.tscn**

* Loads autoloads, goes to `Menu.tscn`.

### 4) Input & Mobile

* Project Settings → Input Map: add `ui_tap` (mouse left, screen touch).
* Tap anywhere to jump; second tap mid-air triggers **double jump** if enabled.
* Add **vibration** helper on Android/iOS (use `Input.vibrate_handheld()` guarded with `OS.has_feature("mobile")`).

### 5) Core Logic Details

**Physics**

* Gravity: 1200–1800 px/s² (tweak).
* Jump: initial impulse `jump_force` ~ 520–680.
* Horizontal drift: small air control toward platform center (optional).

**Camera & World**

* `Camera2D` follows player Y; lock X center.
* Clean-up: any node whose `global_position.y > camera_bottom + 200` → pool/free.

**Difficulty Curves** (time or score based):

* `platform_min_width` shrinks from 240 → 120.
* `platform_speed` increases from 40 → 180 px/s. Direction alternates.
* `gap_y` grows from 120 → 220.
* Inject special platforms with probability curve:

  * Start 100% NORMAL; after score 10: 10% CONVEYOR; after 20: 10% BREAKABLE; after 30: 10% BOUNCE.

**Scoring**

* Landing on a *new* platform increments score; show floating `+1` label.
* Coins worth `+5`. Play `coin.wav`, small sparkle.

**Game Over**

* Trigger when player falls below camera bottom by 100 px or collides with “death zone”.
* Show Game Over panel with score, best, buttons: `Retry`, `Home`, optional `Continue` (ad stub).

### 6) Autoloads

**GameState.gd**

* Signals: `score_changed(int)`, `best_changed(int)`, `state_changed(String)`.
* Vars: `score`, `best`, `is_paused`, `allow_continue`.
* Methods: `new_run()`, `add_score(n)`, `end_run()`.
* On `end_run()`: if `score > best` then `best = score; Save.save_best(best)`.

**Save.gd**

* JSON file at `user://save.json` with keys: `best`, `settings` (sound on/off, vibration on/off).
* Methods: `load_save()`, `save_best(value)`, `save_settings(map)`.

### 7) Utilities

**ObjectPool.gd**

* Generic pool for `Platform` and `Coin`. Methods: `acquire()`, `release(node)`.

**Fx.gd**

* `shake(camera, intensity, duration)`, `squash(node, x_scale, y_scale, dur)`, `emit_land_particles(pos)`.

### 8) Audio/Visual

* Generate or include tiny SFX (can synthesize with free tools).
* Use subtle gradient bg that shifts hue slowly with score.
* Landing: pitch-randomized `land.wav`, slight squash, small shake.
* Miss: desaturate background briefly.

### 9) Polishing & Accessibility

* Settings: toggle **Sound**, **Vibration** (persist).
* Color-blind-safe palette; avoid red/green confusion.
* Large buttons; hit areas ≥ 44x44 pt.
* Pausable at any time; resume keeps platform states.

### 10) Optional “Continue” via Reward Ad (stub)

* Implement an interface `AdService.gd` with methods `is_available()`, `show_rewarded(callback)`. Provide a **no-SDK stub** returning `false` by default. All UI respects `FEATURE_ADS=false`. Keep code structured so adding AdMob/Unity Ads later only replaces the adapter.

### 11) Persistence & Share

* Save `best` locally.
* Implement **Share** button (Android/iOS) using `OS.shell_open` with formatted text (score + store link placeholder). On iOS this opens Notes/Message/mail; acceptable for MVP.

### 12) QA Checklist (Automated & Manual)

* Write a minimal **Godot unit test** (GUT optional not required) or simple scripted checks:

  * Platform spawner never places unreachable platforms.
  * Score increments once per *first* landing on a platform.
  * Pool never leaks nodes.
* Manual test plan:

  * First-run experience, sound/vibration toggles, pause/resume, screen rotation locked, performance on low-end device, airplane mode, app resume from background.

### 13) Build/Export

* Add **Export Presets**:

  * **Android**: AAB, min SDK 24, target SDK latest; permissions minimal (no internet unless using share deep link). Keystore instructions in `/export/android/README.md`.
  * **iOS**: Release build, disable bitcode, portrait only; set icons & launch screens; signing notes in `/export/ios/README.md`.
* Provide a script or README steps to:

  * Install export templates.
  * Generate icons (1024 → sizes) and assign.
  * Build commands via Godot headless (document).

### 14) App Store Readiness

* Provide `/README.md` section with:

  * App name, short & long description, keywords.
  * Content rating (non-violent, for all ages).
  * Privacy: no data collected; no tracking.
  * Screenshots checklist (5 portrait sizes).
  * Versioning: `1.0.0`.

### 15) Deliverables (Definition of Done)

* ✅ Godot 4.3 project compiles & runs on desktop and mobile.
* ✅ Stable 60 FPS on typical devices (no GC spikes).
* ✅ Core loop complete; difficulty ramps to challenging but fair.
* ✅ Local save of **best score**; Settings persisted.
* ✅ Polished UI (Menu, HUD, Pause, Game Over).
* ✅ Export presets for Android/iOS with icons & launch screens.
* ✅ README with build & store submission steps.
* ✅ No third-party SDKs by default; ads feature guarded by flag.

---

## Implementation Tasks for You (execute in order)

1. **Initialize project** and repo; set project settings (portrait, physics FPS 120, vsync on, display stretch “canvas_items”, base resolution 1080x1920).
2. **Create autoloads** `GameState.gd`, `Save.gd`; wire signals.
3. **Implement Player.tscn + Player.gd** with jump, double-jump, coyote time, jump buffering, landing detection (check floor collisions).
4. **Implement Platform.tscn** with variant types and visuals; add `on_player_landed()` hook to trigger score & effects.
5. **Implement PlatformSpawner.tscn** with difficulty curves and object pooling; ensure platforms are always reachable.
6. **Implement Game.tscn** world + camera follow + cleanup below camera; add `Fx.gd` effects.
7. **Create HUD.tscn** and connect to `GameState` signals; buttons: pause/resume/home/share.
8. **Create Menu.tscn** with settings toggles; wire to `Save.gd`.
9. **Add SFX** and haptics; polish feel (squash/stretch, shakes).
10. **Add optional Coin.tscn** and scoring bonus; simple particle sparkle.
11. **Game Over flow** with retry & optional continue (ads stub).
12. **Persistence** of best score & settings.
13. **QA pass** + fix; ensure no leaked nodes (use `queue_free` or pool).
14. **Export presets** + icons + README.
15. **Produce 6 portrait screenshots** via an in-editor capture script or manual capture.

---

## Coding Standards

* Clear node names; no magic numbers (expose via `@export`).
* Signals for cross-scene communication; avoid singletons except `GameState` & `Save`.
* Comment key sections; include brief docstrings.
* Keep per-frame allocations minimal; reuse vectors; use object pooling.
* Guard platform-specific code with `OS.has_feature`.

---

## Acceptance Tests (run & verify)

* Start → Play → jump 30+ platforms; platform types appear as designed.
* Pause/resume works; FPS stable; audio respect toggle; vibration works on Android.
* Kill app → reopen: **best score** persists; settings persist.
* Export Android AAB and iOS archive without errors.

---

**Now begin implementing. Create all files, write the code, wire scenes, and produce the README and export presets. When done, show me:**

* Short demo video/gif or instructions to run.
* AAB/IPA build steps in README.
* Notes on any trade-offs and tuning constants for difficulty.
