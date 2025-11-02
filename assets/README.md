# Assets Directory

This directory contains game assets (fonts, sound effects, icons).

## Required Assets

### Icons (`icons/`)
- **icon.png** (1024x1024) - Source icon for generating all export sizes
- Generate export sizes using Godot's icon generator or manually:
  - Android: Various sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
  - iOS: See iOS export README for required sizes

### Sound Effects (`sfx/`)
- **jump.wav** - Jump sound effect
- **land.wav** - Landing sound effect
- **coin.wav** - Coin collection sound
- **gameover.wav** - Game over sound

**Note**: These files are placeholders. You can:
- Generate simple sounds using online tools (e.g., sfxr, jsfxr)
- Use free sound libraries (Freesound.org, OpenGameArt.org)
- Create minimal 8-bit style sounds programmatically

### Fonts (`fonts/`)
- Recommended: **Inter** or **NotoSans** (OFL licensed, free to use)
- Optional: Pixel font for retro aesthetic

**Note**: Game will use Godot default font if no custom fonts are added. To use custom fonts:
1. Add font file to this directory
2. Update project settings or UI theme

## Asset Guidelines

- **Keep file sizes small** - Target < 50MB total for Android
- **Use compression** - PNG for icons, OGG/compressed WAV for audio
- **Optimize textures** - Use appropriate formats and compression in Godot
- **Test on devices** - Ensure assets load quickly on low-end devices

