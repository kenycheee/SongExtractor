# SongExtractor

SongExtractor is a **cross-platform audio extraction application** built with **Flutter**.  
It allows users to extract audio from various input sources and save or play the result locally.  
The project targets **Android, iOS, Web, Windows, Linux, and macOS** — all from a single codebase.

---

## Features

### 🔹 Multi-Platform Support
Runs natively on:
- Android
- iOS
- Web
- Windows
- Linux
- macOS

### 🔹 Audio Extraction Engine
Low-level extraction handled through native plugins (C++ / Kotlin / Swift).

### 🔹 Clean and Simple UI
Lightweight Flutter interface focused on ease of use and performance.

### 🔹 Testing Ready
Includes a `test/` directory for both unit and integration tests.

---

## Tech Stack

| Category | Tools |
|----------|----------------------------|
| Framework | Flutter (Dart) |
| Native Modules | C++, Kotlin, Swift |
| Platforms | Mobile, Web, Desktop |
| Testing | flutter_test |
| Package Manager | pubspec.yaml |

---

## Getting Started

Run the following commands in sequence:

```bash
# Clone repository
git clone https://github.com/kenycheee/SongExtractor.git
cd SongExtractor

# Install dependencies
flutter pub get

# Run development build
flutter run
