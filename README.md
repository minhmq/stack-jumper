# Stack Jumper

A polished, lightweight mobile platformer game built with **Godot 4.3**. Jump from platform to platform as you climb higher and higher!

## 🎮 Game Description

**Stack Jumper** is a vertical climbing platformer where players tap to jump between moving platforms. Miss a platform and you fall! Features include:

- **Simple one-tap controls** - Tap anywhere to jump
- **Double jump** - Jump again mid-air for better control
- **Dynamic difficulty** - Platforms get faster and narrower as you progress
- **Special platforms** - Conveyor belts, breakable platforms, and bounce pads
- **Collectible coins** - Bonus points and sparkle effects
- **Polished feel** - Screen shake, squash & stretch, haptics, and particles
- **Local persistence** - Your best score is saved automatically

## 🚀 Quick Start

### Requirements

- **Godot 4.3** (stable) - [Download](https://godotengine.org/download)
- For mobile export: Android SDK / Xcode (see export READMEs)

### Running the Game

1. Open `project.godot` in Godot 4.3
2. Press **F5** or click **Play** to run
3. Default resolution: 1080x1920 (portrait mobile)

## 📁 Project Structure

```
/stack-jumper/
├── project.godot          # Godot project configuration
├── src/
│   ├── autoload/          # Singletons (GameState, Save)
│   ├── scenes/            # All .tscn scene files
│   ├── scripts/           # All .gd script files
│   └── util/              # Utilities (ObjectPool, Fx)
├── assets/
│   ├── fonts/             # Font files (Inter/NotoSans recommended)
│   ├── sfx/               # Sound effects
│   └── icons/             # App icons
├── export/
│   ├── android/           # Android export docs
│   └── ios/               # iOS export docs
└── README.md              # This file
```

## 🎯 Core Features

### Gameplay

- **Jump Mechanics**: Single tap = jump. Second tap in air = double jump
- **Platform Types**:
  - **Normal**: Standard platforms
  - **Conveyor**: Moves player horizontally
  - **Breakable**: Disappears after landing
  - **Bounce**: Extra-high jump
- **Difficulty Curve**: Speed, gap size, and platform width adjust based on score
- **Coins**: Collect for bonus points (+5 each)

### Settings & Persistence

- Toggle sound effects
- Toggle vibration/haptics
- Best score saved locally (JSON in `user://save.json`)
- Reset best score option

### Visual & Audio

- Dynamic gradient background (shifts with score)
- Particle effects on landing
- Camera shake on impact
- Squash & stretch animations
- Minimal SFX (jump, land, coin, gameover)
- Haptic feedback (mobile only)

## 🔧 Building & Exporting

### Desktop (for testing)

Just press **F5** in Godot Editor.

### Android

See [`export/android/README.md`](export/android/README.md) for detailed instructions.

**Quick steps:**
1. Install Godot Android export templates
2. Generate keystore
3. Configure export preset (Project → Export)
4. Export AAB or APK

**Target size**: < 50MB AAB

### iOS

See [`export/ios/README.md`](export/ios/README.md) for detailed instructions.

**Quick steps:**
1. Install Godot iOS export templates
2. Set up Xcode certificates
3. Configure export preset
4. Export project → open in Xcode → Archive

**Target size**: < 200MB IPA

## 📱 App Store Information

### App Store Listing

**Name**: Stack Jumper  
**Short Description** (80 chars): "Jump from platform to platform in this addictive vertical climber!"  
**Long Description**:

> Stack Jumper is a fast-paced vertical platformer that challenges your timing and precision. Tap to jump between moving platforms as you climb higher and higher. Each platform moves at different speeds, and as you progress, the game gets more challenging with narrower platforms and special obstacles.
> 
> **Features:**
> - Simple one-tap controls
> - Double-jump for advanced players
> - Dynamic difficulty that adapts to your skill
> - Special platform types: conveyor belts, breakable platforms, and bounce pads
> - Collect coins for bonus points
> - Polished visuals and smooth gameplay
> 
> How high can you climb? Beat your best score and challenge your friends!

**Keywords**: platformer, jumping game, arcade, mobile game, casual game, vertical climber, endless jumper

**Category**: Games → Arcade  
**Content Rating**: 
- **PEGI**: 3 (Everyone)
- **ESRB**: E (Everyone)
- **iOS**: 4+ (no objectionable content)

### Screenshots Checklist

Required sizes (portrait):

1. **iPhone 6.7" (1284 x 2778)** - Primary screenshot
2. **iPhone 6.5" (1242 x 2688)**
3. **iPhone 5.5" (1242 x 2208)**
4. **iPad Pro 12.9" (2048 x 2732)**
5. **iPad Pro 11" (1668 x 2388)**
6. **Google Play**: 16:9 (1080 x 1920 minimum)

**Screenshot Tips:**
- Show gameplay in action
- Display high scores
- Show different platform types
- Include UI elements (score, best)

### Privacy & Data

- **No data collected** - Game runs entirely offline
- **No tracking** - No analytics SDKs
- **No ads** - Optional "Watch Ad to Continue" feature is behind a flag (disabled by default)
- **Local storage only** - Best score and settings saved to device

### Version History

- **v1.0.0** - Initial release

## 🐛 Known Issues & Trade-offs

### Trade-offs Made

1. **No external fonts by default** - Uses Godot default font (can add Inter/NotoSans)
2. **Placeholder SFX** - Audio files need to be generated/added (see assets/sfx/)
3. **Simple visuals** - Uses ColorRect/Polygon2D instead of sprites (easy to replace)
4. **Ads feature stub** - Interface exists but no SDK integrated (see `AdService.gd` stub pattern in code)

### Tuning Constants

Key values in scripts that affect gameplay feel:

- **Player.gd**:
  - `jump_force`: 600.0 (adjust for jump height)
  - `gravity`: 1500.0 (adjust fall speed)
  - `coyote_time_ms`: 150.0 (forgiving jump window)
  - `jump_buffer_ms`: 100.0 (input buffer)

- **PlatformSpawner.gd**:
  - `min_gap_y` / `max_gap_y`: 120-220 (vertical spacing)
  - `base_platform_width` / `min_platform_width`: 240 → 120 (shrinks over time)
  - `base_platform_speed` / `max_platform_speed`: 40 → 180 (speed curve)

## 🧪 Testing Checklist

- [ ] First-run experience (no saved data)
- [ ] Jump mechanics (single, double, coyote time)
- [ ] Platform types spawn correctly
- [ ] Score increments properly
- [ ] Best score persists after app close
- [ ] Settings (sound/vibration) persist
- [ ] Pause/resume works
- [ ] Game over flow
- [ ] Performance: stable 60 FPS on target devices
- [ ] Portrait orientation locked
- [ ] Haptics work on Android/iOS
- [ ] Share functionality (opens share sheet)
- [ ] No memory leaks (check with profiler)

## 🔮 Future Enhancements (Optional)

- Leaderboards (local or online)
- Achievements
- Customizable player colors
- Power-ups (slow-mo, shield)
- Seasonal themes
- Tutorial/onboarding
- Background music
- More platform types

## 📄 License

See [LICENSE](LICENSE) file. (Recommended: MIT or CC0 for a simple game)

## 🤝 Credits

Built with **Godot Engine 4.3**  
Game design and implementation: See INIT.md for full specification

## 📞 Support

For issues or questions, check the code comments or refer to Godot documentation.

---

**Ready to play?** Open `project.godot` and press **F5**!

