# ShinyMac

Lock your Mac's keyboard and trackpad for safe cleaning.

## Download

**[Download ShinyMac v1.0.5](https://github.com/Cosmin-T/ShinyMac/releases/latest/download/ShinyMac-1.0.5.dmg)**

## Installation

1. Download the DMG file
2. Open the DMG
3. Drag **ShinyMac.app** to your **Applications** folder
4. Try to launch ShinyMac from Applications

### First Launch Security Warning

When you first open ShinyMac, you'll see this message:

```
"ShinyMac.app" Not opened
Apple could not verify "ShinyMac.app" is free of malware 
that may harm your Mac or compromise your privacy.
```

**To open the app:**

1. Click **Done** (don't click "Move to Bin")
2. Go to **System Settings** → **Privacy & Security**
3. Scroll down to the **Security** section
4. Click **Open Anyway** next to the ShinyMac message
5. Confirm by clicking **Open** in the dialog that appears
6. Grant Accessibility permissions when prompted

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
- Auto-unlock after 8 minutes (safety feature)

## Requirements

- macOS 10.15 or later
- Accessibility permissions

## First Launch

On first launch, macOS will ask for Accessibility permissions:

1. Go to **System Settings** → **Privacy & Security** → **Accessibility**
2. Enable **ShinyMac**
3. Restart the app

## Troubleshooting

### App still won't open after following installation steps

If you've already clicked "Open Anyway" in System Settings and it still doesn't work:

1. Make sure ShinyMac is in your Applications folder (not Downloads or DMG)
2. Try opening Terminal and running:
   ```bash
   xattr -cr /Applications/ShinyMac.app
   ```
3. Then try launching the app again

### Keyboard/trackpad not locking

1. Check Accessibility permissions in System Settings
2. Restart the app after granting permissions

### Can't unlock

- Hold both Command keys for 3 seconds
- Wait 8 minutes for auto-unlock

## Building from Source

```bash
# Build app bundle
bash build-app.sh

# Create DMG
bash create-dmg.sh
```

## License

MIT License - Free to use and modify.
