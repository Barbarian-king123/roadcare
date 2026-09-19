# 🛣️ RoadCare — Smart Civic Infrastructure Reporting Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-Leaflet%2FFlutterMap-7EBC6F?style=for-the-badge&logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue?style=for-the-badge)](https://flutter.dev)

**RoadCare** is a production-ready, community-driven civic infrastructure application that empowers citizens to spot, photograph, and report road hazards (such as potholes, broken street lights, open manholes, damaged signs, and water leakages) directly to municipal response teams with real-time GPS coordinates and photo evidence.

---

## ✨ Features

- 📍 **Interactive Live Map**:
  - OpenStreetMap integration via `flutter_map` (zero billing / API key required).
  - Real-time GPS auto-location with animated user marker.
  - Severity-color-coded pins (High: Red, Medium: Orange, Low: Blue, Resolved: Green).
  - Tap any pin for a bottom preview sheet with distance, time ago, image thumbnail, and details.
  - Tap anywhere on the map to report an issue directly at those coordinates.
- 📸 **Cross-Platform Photo Capture & Upload**:
  - Camera & Gallery picker with compression.
  - Direct upload to Firebase Storage with byte-level cross-platform compatibility (`Android`, `iOS`, `Web`).
- 🧭 **GPS Reverse Geocoding**:
  - Automatically fetches street, area, and city names from coordinates.
- ⚡ **Real-Time Cloud Firestore Sync**:
  - Live stream updates across Home, Map, and My Reports screens.
  - Upvote/verification mechanism so community members can validate hazardous spots.
  - Offline-first fallback cache.
- 📊 **Dynamic Community Impact Dashboard**:
  - Real-time metrics counting resolved cases, in-progress repairs, and percentage fixed.
- 👤 **User Profiles & Authentication**:
  - Email/Password authentication & Google Sign-In with Firebase Auth.
  - Profile photo upload, password reset, and civic rank statistics.
- 🔍 **Filter & Sort Engine**:
  - Filter by hazard category and severity; sort by Most Recent, Most Upvoted, or Nearest.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart SDK ^3.0) |
| **Maps & GIS** | `flutter_map`, `latlong2`, `geolocator`, `geocoding` |
| **Backend & Database** | Google Cloud Firestore |
| **Media Storage** | Google Cloud Firebase Storage |
| **Authentication** | Firebase Auth & Google Sign-In |
| **Design System** | Custom Material 3 Design (`RoadCareColors`) |

---

## 📁 Project Structure

```text
lib/
├── firebase_options.dart   # Generated Firebase configuration
├── main.dart               # App entrypoint and theme definition
├── theme.dart              # Color tokens, styles, and typography
├── models/
│   └── issue.dart          # Issue model, severity/status enums, serialization
├── services/
│   ├── auth_service.dart   # Firebase Authentication & Google Sign-In
│   ├── issue_service.dart  # Cloud Firestore sync, streams & upvoting
│   └── storage_service.dart# Cross-platform Firebase Storage uploader
├── screens/
│   ├── splash_screen.dart       # Animated brand intro screen
│   ├── onboarding_screen.dart   # 3-step feature onboarding carousel
│   ├── loginscreen.dart         # Email/password & Google login
│   ├── signupscreen.dart        # New account creation
│   ├── home_screen.dart         # Live dashboard & recent reports
│   ├── map_screen.dart          # Interactive OpenStreetMap with pins
│   ├── report_issue_screen.dart # Image upload, GPS picker & report form
│   ├── issue_detail_screen.dart # Detail screen with mini-map & upvote
│   ├── my_reports_screen.dart   # Filtered user report history
│   ├── notification_screen.dart # Alerts & repair status updates
│   ├── profile_screen.dart      # User profile, avatar upload & settings
│   └── filtersortscreen.dart    # Category and sort filters
└── widgets/
    └── bottom_nav_bar.dart      # Navigation widget
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.16.0 or higher)
- [Node.js](https://nodejs.org/) & [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- Android Studio / Xcode / Chrome for target devices

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Barbarian-king123/roadcare.git
   cd roadcare/roadcare
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app in development mode:
   ```bash
   # Run on Web (Chrome)
   flutter run -d chrome

   # Run on connected Android device / emulator
   flutter run -d android

   # Run on Windows Desktop
   flutter run -d windows
   ```

---

## 🔒 Firebase Configuration & Security Rules

### Firestore Security Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /issues/{issueId} {
      allow read: if true; // Public can view reports on map and home
      allow create: if true; // Authenticated & guest users can report
      allow update: if request.auth != null || request.resource.data.diff(resource.data).affectedKeys().hasOnly(['upvotes']);
      allow delete: if request.auth != null;
    }
  }
}
```

### Firebase Storage Rules (`storage.rules`)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /issues/{allPaths=**} {
      allow read: if true;
      allow write: if true;
    }
    match /avatars/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🌐 Production Deployment Guide

### Option 1: Deploy to Firebase Hosting (Web)

1. Log in to Firebase CLI:
   ```bash
   firebase login
   ```

2. Build the optimized production web bundle:
   ```bash
   flutter build web --release
   ```

3. Deploy directly to Firebase Hosting:
   ```bash
   firebase deploy --only hosting
   ```
   *Your live web app URL will be displayed in the terminal output.*

---

### Option 2: Deploy to GitHub Pages (Web)

1. Build web with base-href:
   ```bash
   flutter build web --release --base-href "/roadcare/"
   ```
2. Push contents of `build/web` to the `gh-pages` branch.

---

### Option 3: Build Production Android APK / Google Play App Bundle

1. **Generate Release APK (for direct testing/distribution)**:
   ```bash
   flutter build apk --release
   ```
   *The APK will be generated at:* `build/app/outputs/flutter-apk/app-release.apk`

2. **Generate Google Play App Bundle (.aab)**:
   ```bash
   flutter build appbundle --release
   ```
   *The Bundle will be generated at:* `build/app/outputs/bundle/release/app-release.aab`

---

## 📄 License
This project is open-source under the MIT License.
