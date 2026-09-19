# 🛣️ RoadCare — Smart Civic Infrastructure Reporting Platform

[![Live Demo](https://img.shields.io/badge/🌐_Live_App-roadcare--2d68d.web.app-2563EB?style=for-the-badge)](https://roadcare-2d68d.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-Leaflet%2FFlutterMap-7EBC6F?style=for-the-badge&logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue?style=for-the-badge)](https://flutter.dev)

---

### 🚀 **Live Production Deployment URL:**
👉 **[https://roadcare-2d68d.web.app](https://roadcare-2d68d.web.app)** *(Alternative: [https://roadcare-2d68d.firebaseapp.com](https://roadcare-2d68d.firebaseapp.com))*

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
| **Hosting & CDN** | Firebase Hosting (Global CDN) |
| **Design System** | Custom Material 3 Design (`RoadCareColors`) |

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
      allow read: if true;
      allow create: if true;
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

### Deploy to Firebase Hosting (Live Web App)

1. Build the web release:
   ```bash
   flutter build web --release
   ```

2. Deploy directly:
   ```bash
   firebase deploy --only hosting
   ```
   **Live URL:** `https://roadcare-2d68d.web.app`

---

### Build Production Android APK / Google Play App Bundle

1. **Generate Release APK**:
   ```bash
   flutter build apk --release
   ```
   *The APK will be generated at:* `build/app/outputs/flutter-apk/app-release.apk`

2. **Generate Google Play App Bundle (.aab)**:
   ```bash
   flutter build appbundle --release
   ```
   *The Bundle will be generated at:* `build/app/outputs/bundle/release/app-release.aab`
