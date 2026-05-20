<div align="center">

# 💪 FitForge

![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State_Management-00B4AB?logo=riverpod&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Local_Database-003B57?logo=sqlite&logoColor=white)
![GoRouter](https://img.shields.io/badge/GoRouter-Navigation-02569B?logo=flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-Platform-3DDC84?logo=android&logoColor=white)

> **Why not you?**

A personal fitness tracker built with Flutter — plan your workouts, log your sets, and watch your strength grow over time.


<img src="readme_assets/demo.gif" alt="FitForge demo" width="300">
</div>

---

## 📥 Download

**No Google Play account needed.** Download the latest APK directly from [GitHub Releases](../../releases/latest) and install it on your Android device.

> ⚙️ You'll need to enable **Install from unknown sources** in your Android settings.

---

## ✨ Features

### 🗓️ Workout Planning
- Create workout plans assigned to specific days of the week
- Add exercises with custom sets, reps, starting weight, and increment
- Assign exercises to muscle groups (Chest, Back, Shoulders, Biceps, Triceps, Legs, Core)
- Add exercise descriptions and YouTube tutorial links
- Attach custom images to exercises from your gallery

### 🏋️ Workout Logging
- Log sets in real time with actual weight and reps
- Mark sets as completed with a single tap
- Add optional notes to each session
- View total volume for the current session
- Auto-fills from your last session as a starting point

### 📈 Automatic Progression
- Progression calculator suggests weight increases based on your performance
- Configurable progression threshold (how many sets must be completed before increasing)
- Configurable small and large increments (e.g. 2.5 kg and 5.0 kg)
- Progression banner shown before your sets when a suggestion is available

### 📊 Progress Tracking
- Line chart showing max weight per session
- Bar chart showing volume per session (last 7 sessions)
- Stat cards: max weight, number of sessions, strength growth %
- Personal record card with date
- Filter by period: 1 month, 3 months, 6 months, or all time
- Track multiple exercises across all plans

### 💬 Motivational Quotes
- Built-in motivational quotes rotate daily
- Add your own custom quotes
- Toggle individual quotes on/off
- Your quotes take priority over built-in ones

### 🌍 Localization
- Three languages supported: English, Serbian (Latin), Serbian (Cyrillic)
- Language selector in Settings
- All UI strings fully translated

### ⚙️ Settings
- Small and large weight increments
- Progression threshold slider
- Language selection
- Motivational quote management
- Full data reset option

### 🚀 Onboarding
- 3-screen onboarding for new users
- Explains the Plan → Workout → Progress flow
- Skip option available
- Only shown on first launch

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 / Dart 3 |
| State management | Riverpod 2 |
| Navigation | GoRouter 13 |
| Local database | SQLite (sqflite) |
| Charts | fl_chart |
| Localization | flutter_localizations + intl |
| Image picker | image_picker |
| Splash screen | flutter_native_splash |
| App icon | flutter_launcher_icons |

---

## 🏗️ Architecture

Feature-first, layered architecture:

```
lib/
├── core/
│   ├── models/
│   ├── router/
│   ├── theme/
│   └── utils/
├── data/
│   ├── local/
│   │   ├── dao/
│   │   └── database_helper.dart
│   ├── models/
│   └── repositories/
├── features/
│   ├── onboarding/
│   ├── progress/
│   ├── settings/
│   ├── workout_log/
│   └── workout_plan/
├── l10n/
└── shared/
    └── widgets/
```

**Data flow:** UI → Riverpod Provider → Repository → DAO → SQLite

---

## 🗄️ Database Schema

| Table | Description |
|---|---|
| `workout_plans` | Plans with day of week |
| `exercises` | Exercises with muscle group, description, YouTube URL |
| `default_sets` | Default sets per exercise (reps, weight, increment) |
| `workout_logs` | Logged sessions per exercise per date |
| `workout_sets` | Individual sets within a log |
| `motivational_quotes` | User-defined motivational quotes |

---

## 🚀 Getting Started

```bash
# Clone the repo
git clone https://github.com/pero-grubac/fit_forge.git
cd fit_forge

# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run on connected device
flutter run
```

---

## 📦 Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

Release APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

