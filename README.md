# ShinyMac

Lock your Mac's keyboard and trackpad for safe cleaning.

## Download

**[Download ShinyMac v1.0.0](https://github.com/YOUR_USERNAME/ShinyMac/releases/latest/download/ShinyMac-1.0.0.dmg)**

## Installation

1. Download the DMG file
2. Open the DMG
3. Drag **ShinyMac.app** to your **Applications** folder
4. Launch ShinyMac from Applications
5. Grant Accessibility permissions when prompted

## Usage

1. Click **START** to lock keyboard and trackpad
2. Screen goes fullscreen and black
3. Clean your keyboard/trackpad safely
4. **Hold both ⌘ Command keys for 3 seconds** to unlock

## Features

- Locks keyboard completely (all keys including F1-F12)
- Locks trackpad and mouse
- Fullscreen black interface
- Visual Command key indicators
- 3-second unlock countdown
- Auto-unlock after 5 minutes (safety feature)

## Requirements

- macOS 10.15 or later
- Accessibility permissions

## First Launch

On first launch, macOS will ask for Accessibility permissions:

1. Go to **System Settings** → **Privacy & Security** → **Accessibility**
2. Enable **ShinyMac**
3. Restart the app

## Troubleshooting

### "App can't be opened because it is from an unidentified developer"

Right-click the app and select **Open**, then click **Open** again.

Or remove quarantine:
```bash
xattr -d com.apple.quarantine /Applications/ShinyMac.app
```

### Keyboard/trackpad not locking

1. Check Accessibility permissions in System Settings
2. Restart the app after granting permissions

### Can't unlock

- Hold both Command keys for 3 seconds
- Wait 5 minutes for auto-unlock

## Building from Source

```bash
# Build app bundle
bash build-app.sh

# Create DMG
bash create-dmg.sh
```

## License

MIT License - Free to use and modify.
