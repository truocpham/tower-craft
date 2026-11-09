# Building Tower Craft for iPad Air

Private family build for an iPad Air, made on a Mac (MacBook Pro M3 Pro) and installed with a free Apple ID. No App Store or TestFlight.

> **Not tested here.** The export preset and these steps were written on a Windows machine, where the iOS export and a device install cannot be run. Only the desktop import and unit tests were run. Expect to adjust small details (Xcode menu names, Godot option names) on the first real build, and fix this guide when you do.

## What the project already sets

- `game/export_presets.cfg`
  - Preset **iPad** (iOS): iPad only (`targeted_device_family=1`), exports an Xcode project to `build/ios/` (`export_project_only`), minimum iOS 14, arm64, no Wi-Fi or push capabilities, no Files app or iTunes sharing, and no permission strings (no network, camera, microphone or location usage text).
  - Preset **macOS**: universal build for testing on the Mac, ad-hoc signed, no notarization.
  - Both presets leave out `tests/*`.
  - Bundle identifier is `com.example.towercraft`. Change it to something unique to you (for example `com.yourname.towercraft`), because a free Apple ID cannot reuse an identifier another account already owns.
- `game/project.godot`
  - 1080x1920 base size, stretch mode `canvas_items`, aspect `expand`, scale mode `fractional`, so the layout fills any iPad shape and a resized desktop window without black bars or blurry scaling.
  - Orientation: sensor (portrait and landscape, both directions) via `window/handheld/orientation`.
  - Home indicator hidden on iOS.
  - Mobile renderer. High resolution comes from `canvas_items` stretch, which renders at the native Retina size.
- Safe areas: UI code must read `DisplayServer.get_display_safe_area()` and keep controls inside it (the notch-free iPad Air still has rounded corners and the home indicator area).

## 1. Install the tools on the Mac

1. Install **Xcode** from the Mac App Store (large download). Open it once and accept the license. Then run `xcode-select --install` if the command line tools are missing.
2. Install **Godot 4.7 or newer (standard, not .NET)** from godotengine.org, or `brew install --cask godot`. The project is verified on 4.7.
3. In Godot: **Editor > Manage Export Templates > Download and Install** for the same version. The iOS export needs the templates.
4. Clone this repository and open `game/project.godot` in Godot. Let it import.

## 2. Export the Xcode project

1. In Godot, **Project > Export**. The **iPad** preset should be listed (it comes from `game/export_presets.cfg`).
2. Set **Bundle Identifier** to your unique id.
3. Set **App Store Team ID** (see the next section; for a free Apple ID this is your "Personal Team" ID, 10 characters).
4. Click **Export Project**, and save to `build/ios/TowerCraft.xcodeproj`. (Command line alternative from the repo root: `godot --headless --path game --export-debug iPad ../build/ios/TowerCraft.xcodeproj`.)

`build/` is generated output, do not commit it.

## 3. Sign with a free Apple ID

1. Open Xcode > **Settings > Accounts**, press **+**, choose **Apple ID**, and sign in. A **Personal Team** appears.
2. Open `build/ios/TowerCraft.xcodeproj` in Xcode.
3. Select the project, then the **TowerCraft** target > **Signing & Capabilities**. Tick **Automatically manage signing** and pick your Personal Team.
4. If Xcode says the bundle identifier is not available, change it to another unique value (in Xcode and in the Godot preset).

Your Team ID is shown at developer.apple.com/account under Membership details once signed in, or in Xcode's team picker.

## 4. Turn on Developer Mode on the iPad

1. Connect the iPad to the Mac with a cable once, unlock it, and tap **Trust** when asked.
2. Xcode must see the device (Window > Devices and Simulators). This makes the **Developer Mode** switch appear.
3. On the iPad: **Settings > Privacy & Security > Developer Mode**, switch on, restart, and confirm after the restart.

## 5. Install on the iPad

By cable:

1. In Xcode choose the iPad as the run destination (top toolbar) and press **Run** (Cmd+R).
2. First launch only: on the iPad open **Settings > General > VPN & Device Management**, tap your Apple ID under Developer App, and tap **Trust**. Launch the app again.

Over Wi-Fi (after one cable pairing):

1. In Xcode, **Window > Devices and Simulators**, select the iPad, and tick **Connect via network**.
2. Keep the Mac and iPad on the same Wi-Fi network. The iPad then appears as a destination without the cable. The game itself never uses the network.

## 6. The 7-day expiry and the weekly reinstall

Apps signed with a free Apple ID expire after **7 days**. After that the app will not open until it is installed again. Weekly routine:

1. Connect the iPad (cable, or Wi-Fi if paired) and open the Xcode project.
2. Press **Run** again. This re-signs and reinstalls over the old copy. Saved profiles and scores stay on the device, as long as the app is not deleted first. Do not delete the app before reinstalling.
3. There is also a limit of a few apps and app identifiers per free account per week, which one game does not reach.

## 7. Optional: paid Apple Developer account

A paid account (Apple Developer Program, about 99 USD per year) removes the weekly reinstall: signing lasts a year, and TestFlight becomes possible for sharing with family iPads without a cable. It is not needed for this project. If you buy it, put its Team ID in the Godot preset and sign in Xcode with that team.

## Testing on the Mac first

Use the **macOS** preset (**Project > Export**, macOS) or just press play in Godot. Resize the window to check portrait and landscape shapes before going to the iPad.

## Checklist when something fails

- "No export templates": install them (step 1.3).
- Xcode signing errors: confirm the Personal Team is selected and the bundle id is unique.
- "Developer Mode disabled": see step 4.
- App opens then closes after a week: it expired, do step 6.
