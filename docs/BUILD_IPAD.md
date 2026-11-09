# Building Tower Craft for iPad Air

Private family build for an iPad Air, made on a Mac (MacBook Pro M3 Pro) and installed with a free Apple ID. No App Store or TestFlight.

> **Not tested here.** The export preset and these steps were written on a Windows machine, where the iOS export and a device install cannot be run. Only the desktop import and unit tests were run. Expect to adjust small details (Xcode menu names, Godot option names) on the first real build, and fix this guide when you do.

> **TL;DR**
> 1. Install Xcode and Godot 4.7 on the Mac.
> 2. Export the **iPad** preset from Godot.
> 3. Sign in Xcode with your Apple ID and press Run.
> 4. **The app expires after 7 days.** Press Run again every week.

## What the project already sets

`game/export_presets.cfg`:

- Preset **iPad** (iOS): iPad only (`targeted_device_family=1`).
- Exports an Xcode project to `build/ios/` (`export_project_only`).
- Minimum iOS 14, arm64.
- No Wi-Fi or push capabilities, no Files app or iTunes sharing.
- No permission strings (no network, camera, microphone or location usage text).
- Preset **macOS**: universal build for testing on the Mac, ad-hoc signed, no notarization.
- Both presets leave out `tests/*`.
- Bundle identifier is `com.example.towercraft`.

> **Warning:** Change the bundle identifier to something unique to you (for example `com.yourname.towercraft`). A free Apple ID cannot reuse an identifier another account already owns.

`game/project.godot`:

- 1080x1920 base size, stretch mode `canvas_items`, aspect `expand`, scale mode `fractional`. The layout fills any iPad shape and a resized desktop window without black bars or blurry scaling.
- Orientation: sensor (portrait and landscape, both directions) via `window/handheld/orientation`.
- Home indicator hidden on iOS.
- Mobile renderer. High resolution comes from `canvas_items` stretch, which renders at the native Retina size.

Safe areas:

- UI code must read `DisplayServer.get_display_safe_area()` and keep controls inside it.
- The iPad Air has no notch, but it still has rounded corners and a home indicator area.

## 1. Install the tools on the Mac

1. Install **Xcode** from the Mac App Store (large download).
2. Open Xcode once and accept the license.
3. If the command line tools are missing, run `xcode-select --install`.
4. Install **Godot 4.7 (standard, not .NET)** from godotengine.org, or run `brew install --cask godot`. The project is verified on 4.7.
5. In Godot, choose **Editor > Manage Export Templates > Download and Install** for the same version.
6. Clone this repository.
7. Open `game/project.godot` in Godot and let it import.

> **Tip:** The iOS export needs the export templates (step 5).

## 2. Export the Xcode project

1. In Godot, choose **Project > Export**.
2. Select the **iPad** preset. It comes from `game/export_presets.cfg`.
3. Set **Bundle Identifier** to your unique id.
4. Set **App Store Team ID**. For a free Apple ID this is your "Personal Team" ID (10 characters).
5. Click **Export Project**.
6. Save to `build/ios/TowerCraft.xcodeproj`.

> **Tip:** Command line alternative, from the repo root: `godot --headless --path game --export-debug iPad ../build/ios/TowerCraft.xcodeproj`

> **Warning:** `build/` is generated output. Do not commit it.

## 3. Sign with a free Apple ID

1. Open Xcode > **Settings > Accounts**.
2. Press **+** and choose **Apple ID**.
3. Sign in. A **Personal Team** appears.
4. Open `build/ios/TowerCraft.xcodeproj` in Xcode.
5. Select the project, then the **TowerCraft** target > **Signing & Capabilities**.
6. Tick **Automatically manage signing**.
7. Pick your Personal Team.
8. If Xcode says the bundle identifier is not available, change it to another unique value, in Xcode and in the Godot preset.

> **Tip:** Your Team ID is shown at developer.apple.com/account under Membership details once signed in, or in Xcode's team picker.

## 4. Turn on Developer Mode on the iPad

1. Connect the iPad to the Mac with a cable.
2. Unlock the iPad and tap **Trust** when asked.
3. In Xcode, open **Window > Devices and Simulators** and check the iPad is listed. This makes the **Developer Mode** switch appear.
4. On the iPad, open **Settings > Privacy & Security > Developer Mode**.
5. Switch it on and restart the iPad.
6. Confirm Developer Mode after the restart.

## 5. Install on the iPad

By cable:

1. In Xcode, choose the iPad as the run destination (top toolbar).
2. Press **Run** (Cmd+R).
3. On the iPad, open **Settings > General > VPN & Device Management** (first launch only).
4. Tap your Apple ID under Developer App, then tap **Trust**.
5. Launch the app again.

Over Wi-Fi (after one cable pairing):

1. In Xcode, open **Window > Devices and Simulators**.
2. Select the iPad and tick **Connect via network**.
3. Keep the Mac and iPad on the same Wi-Fi network.
4. Pick the iPad as the run destination. It now appears without the cable.

> **Tip:** The game itself never uses the network.

## 6. The 7-day expiry and the weekly reinstall

> **Warning:** Apps signed with a free Apple ID expire after **7 days**. After that the app will not open until it is installed again.

Weekly routine:

1. Connect the iPad (cable, or Wi-Fi if paired).
2. Open the Xcode project.
3. Press **Run** again. This re-signs and reinstalls over the old copy.

> **Warning:** Do not delete the app before reinstalling. Saved profiles and scores stay on the device only if the app is not deleted first.

> **Tip:** A free account also has a limit of a few apps and app identifiers per week. One game does not reach it.

## 7. Optional: paid Apple Developer account

- A paid account (Apple Developer Program, about 99 USD per year) removes the weekly reinstall.
- Signing then lasts a year.
- TestFlight becomes possible, for sharing with family iPads without a cable.
- It is not needed for this project.
- If you buy it, put its Team ID in the Godot preset and sign in Xcode with that team.

## Testing on the Mac first

1. Press play in Godot, or choose **Project > Export** and the **macOS** preset.
2. Resize the window to check portrait and landscape shapes before going to the iPad.

## Checklist when something fails

- "No export templates": install them (step 1.5).
- Xcode signing errors: confirm the Personal Team is selected and the bundle id is unique.
- "Developer Mode disabled": see step 4.
- App opens then closes after a week: it expired, do step 6.
