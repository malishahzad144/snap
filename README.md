# 📸 SnapFilter — Modern AR Camera Filter App
### Flutter Android Application | Full Source Code

---

## 🗂️ Project Structure

```
snapfilter/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # Root widget
│   ├── core/
│   │   ├── theme.dart                     # Global dark theme & colors
│   │   └── constants.dart                 # App-wide constants
│   ├── features/
│   │   ├── camera/
│   │   │   ├── camera_provider.dart       # Camera lifecycle, zoom, flash, ML Kit stream
│   │   │   └── camera_screen.dart         # Main camera UI
│   │   ├── filters/
│   │   │   ├── filter_provider.dart       # Active filter & enhancement state
│   │   │   ├── models/
│   │   │   │   └── filter_model.dart      # FilterModel data class + enums
│   │   │   ├── color_filters/
│   │   │   │   └── color_filter_data.dart # All 4×5 color matrices + registry
│   │   │   ├── face_filters/
│   │   │   │   └── face_filter_painter.dart # AR CustomPainter overlays
│   │   │   └── widgets/
│   │   │       ├── filter_bar.dart        # Horizontal scrollable filter strip
│   │   │       └── enhancement_panel.dart # Brightness/contrast/saturation sliders
│   │   └── preview/
│   │       └── preview_screen.dart        # Photo review, save, share
│   └── services/
│       └── image_service.dart             # Save to gallery, share, Instagram, WhatsApp
├── android/
│   ├── app/
│   │   ├── build.gradle                   # App-level Gradle (minSdk 24, targetSdk 34)
│   │   └── src/main/
│   │       ├── AndroidManifest.xml        # All permissions + FileProvider
│   │       ├── kotlin/.../MainActivity.kt
│   │       └── res/
│   │           ├── values/styles.xml
│   │           └── xml/file_paths.xml     # FileProvider paths
│   ├── build.gradle                       # Project-level Gradle
│   ├── settings.gradle
│   └── gradle.properties
├── assets/stickers/                       # Add PNG stickers here
└── pubspec.yaml                           # All dependencies
```

---

## ✨ Features

### 🎨 22 Filters
| Category   | Filters |
|------------|---------|
| Color      | Original, Vivid, Noir, Vintage, Cool, Warm, Fade, Neon, Rose, Cinema |
| Artistic   | Sketch, Glitch, Vignette |
| Face AR    | Beauty, Dog Ears 🐶, Sunglasses 😎, Rainbow 🌈, Heart Eyes 😍 |
| Mood/New   | Dreamy ✨, Infrared 🔴, OilPaint 🎨, PixelSort 🔷 |

### 📷 Camera
- Real-time preview with live filter overlay
- Front / back camera switching
- Pinch-to-zoom (up to 5×)
- Flash: Off / Auto / On cycling
- ML Kit face detection at ~24 fps

### 🖼️ Enhancement Sliders
- Brightness | Contrast | Saturation | Blur

### 💾 Media
- Capture JPEG to temp → preview screen
- Save to `SnapFilter` gallery album
- Share via system sheet, Instagram, WhatsApp

### 🚀 Innovative Filters (not in Snapchat)
1. **Dreamy** — soft pastel glow with warm-cool color shift
2. **Infrared** — false-color infrared film simulation (foliage turns red)
3. **OilPaint** — impressionist oil-painting color boost
4. **PixelSort** — glitchy RGB channel rotation art

---

## 🔧 Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | 3.19+ |
| Dart SDK | 3.2+ |
| Android Studio | Hedgehog+ |
| Java / JDK | 17 |
| Android SDK | API 24–34 |
| NDK | 25.1.8937393 |
| Gradle | 8.3 |

---

## 🚀 Build & Run Instructions

### Step 1 — Install Flutter
```bash
# Download Flutter SDK from https://docs.flutter.dev/get-started/install
# Then add to PATH:
export PATH="$HOME/flutter/bin:$PATH"
flutter doctor   # Verify everything is green
```

### Step 2 — Get the project
```bash
# Unzip the downloaded source code
cd snapfilter
```

### Step 3 — Install dependencies
```bash
flutter pub get
```

### Step 4 — Connect Android device or start emulator
```bash
# List connected devices
flutter devices

# Or start an emulator (Android API 24+)
# In Android Studio: AVD Manager → Create & Launch
```

### Step 5 — Run in debug mode
```bash
flutter run
```

### Step 6 — Build release APK (direct install)
```bash
# Build APK signed with debug key (works for direct install)
flutter build apk --release --split-per-abi

# Output files:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  ← modern phones
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk ← older phones
# build/app/outputs/flutter-apk/app-x86_64-release.apk     ← emulators
```

### Step 7 — Install APK on Android device
```bash
# Via ADB (USB):
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Or copy the APK to the phone and open it
# (Enable "Install unknown apps" in Settings → Security)
```

### Step 8 — Build universal APK (single file, larger)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚠️ Common Issues & Fixes

### ML Kit face detection slow on emulator
→ Use a **physical Android device** for best performance.
The ML Kit `FaceDetectorMode.fast` is optimized for real hardware.

### Camera permission denied
→ Go to Settings → Apps → SnapFilter → Permissions → Allow Camera

### `minSdk` error
→ Ensure `minSdk 24` in `android/app/build.gradle` (already set)

### Gradle build fails (NDK missing)
```bash
# In Android Studio:
# SDK Manager → SDK Tools → NDK (Side by side) → Install 25.1.8937393
```

### `flutter pub get` fails (network issues)
```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get
```

---

## 🔌 Adding New Filters (Modular Design)

### Add a color matrix filter:
1. Add entry to `FilterType` enum in `filter_model.dart`
2. Add matrix constant in `color_filter_data.dart`
3. Add `FilterModel(...)` entry in `ColorFilterData.allFilters`

Done! The filter bar, preview, and saving all work automatically.

### Add a face AR filter:
1. Add to `FilterType` enum
2. Add `FilterModel` with `colorMatrix: null`
3. Add a `case FilterType.yourFilter:` in `FaceFilterPainter._paintFace()`
4. Implement your `void _yourFilter(Canvas, Rect, Face, ...)` method

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `camera ^0.10.5` | Camera preview & capture |
| `google_mlkit_face_detection ^0.11.0` | Real-time face landmark detection |
| `image ^4.2.0` | Image manipulation utilities |
| `gal ^2.3.0` | Save photo to device gallery |
| `share_plus ^9.0.0` | System share sheet + direct app sharing |
| `permission_handler ^11.3.1` | Runtime permissions |
| `provider ^6.1.2` | State management |
| `path_provider ^2.1.4` | Temp & app directories |

---

## 📄 License
MIT — Free to use, modify, and distribute for personal and commercial projects.

---

*Built with Flutter 3.x • Dart 3.x • ML Kit Face Detection*
