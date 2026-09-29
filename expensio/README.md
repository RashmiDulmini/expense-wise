# 💸 Expensio — Expense Tracker App

A beautifully crafted, full-featured **Expense Tracker** built with Flutter & Firebase. Designed for the **CyphLab Flutter Developer Internship** practical task.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Auth-FFCA28?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 Table of Contents

- [Features](#-features)
- [Project Setup](#-project-setup)
- [Firebase Setup](#-firebase-setup)
- [Architecture & Code Structure](#️-architecture--code-structure)
- [Technologies & Packages Used](#-technologies--packages-used)
- [Design System](#-design-system)
- [AI Tools Used](#-ai-tools-used)

---

## ✨ Features

### Core Features
| Feature | Status |
|---------|--------|
| Add, Edit & Delete expenses | ✅ |
| 9 Expense categories (Food, Transport, Shopping, Entertainment, Health, Education, Utilities, Travel, Other) | ✅ |
| Firebase Firestore real-time data sync | ✅ |
| Firebase Authentication (Email/Password + Anonymous guest) | ✅ |
| Monthly total — prominent summary card | ✅ |
| Expense history list with category badges & icons | ✅ |
| Filter by: This Week, This Month, Last Month, All Time | ✅ |
| Sort by: Date (newest/oldest), Amount (high/low) | ✅ |
| Filter by category — horizontal chip bar | ✅ |
| Live search across title, category & notes | ✅ |
| Form validation — all fields validated | ✅ |
| Loading / Empty / Error states handled gracefully | ✅ |
| Amounts displayed in **Sri Lankan Rupees (LKR)** | ✅ |
| Fully responsive — works on all screen sizes | ✅ |

### Expense Fields
| Field | Required | Notes |
|-------|----------|-------|
| Title | ✅ | Min. 2 characters |
| Amount | ✅ | Positive number (LKR) |
| Category | ✅ | Picked from icon grid |
| Date | ✅ | Date picker (no future dates) |
| Note | ❌ | Optional multi-line description |

### Bonus / Additional Features
- 📊 **Analytics screen** with:
  - Weekly spending bar chart (last 7 days)
  - Category breakdown with donut/pie chart (interactive touch)
  - Category-wise progress bars & percentage
- 🔐 **Firebase Authentication** — Email/Password + Anonymous sign-in
- 👤 **Profile screen** — shows account info, member since date & sign-out
- 🎨 **Elegant dark mode** — deep navy/slate palette with vibrant violet & teal accents
- ✨ **Micro-animations** throughout (page transitions, tile entrance, button press)
- 🗑️ **Delete confirmation dialog** with animated centered success popup
- 🖼️ **Custom header image** on the home screen

---

## 🚀 Project Setup

### Prerequisites

Make sure you have the following installed:

| Tool | Version | Download |
|------|---------|----------|
| Flutter SDK | ≥ 3.x | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | ≥ 3.x | Included with Flutter |
| Android Studio / VS Code | Latest | For running the emulator |
| Git | Latest | [git-scm.com](https://git-scm.com) |

### Step 1 — Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/expensio.git
cd expensio
```

### Step 2 — Install Dependencies

```bash
flutter pub get
```

### Step 3 — Configure Firebase

> ⚠️ **The app requires Firebase to run.** See the [Firebase Setup](#-firebase-setup) section below.

### Step 4 — Run the App

```bash
# Run on connected device or emulator
flutter run

# Run on a specific device
flutter run -d <device_id>

# List available devices
flutter devices
```

### Step 5 — Build a Release APK

```bash
flutter build apk --release
```

The APK will be output to `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🔥 Firebase Setup

> The app requires Firebase for authentication and data storage. Follow **one** of these options:

### Option A — FlutterFire CLI *(Recommended)*

```bash
# 1. Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# 2. Log in to Firebase (opens browser)
firebase login

# 3. Configure — select or create your project
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

# This auto-generates lib/firebase_options.dart ✅
```

### Option B — Manual Setup

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a new project (e.g. `expensio`)
3. Click **"Add app"** → choose **Android**
4. Enter package name: `com.example.expensio`
5. Download `google-services.json` → place it in `android/app/`
6. Enable **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable **Email/Password** ✅
   - Enable **Anonymous** ✅
7. Enable **Cloud Firestore**:
   - Go to Firestore Database → Create database
   - Start in **Test mode** (or apply security rules below)
8. Update `lib/firebase_options.dart` with your project's config values

### Firestore Security Rules

Apply these rules in Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/expenses/{expenseId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🏗️ Architecture & Code Structure

```
expensio/
├── android/                        # Android native config
│   ├── app/
│   │   ├── google-services.json    # Firebase Android config ← place here
│   │   └── build.gradle.kts
│   └── build.gradle.kts
├── assets/
│   ├── animations/                 # Lottie animation files
│   └── images/                     # App images (e.g. expense_header.png)
└── lib/
    ├── main.dart                   # Entry point, Provider setup, AppGate
    ├── firebase_options.dart       # Firebase config (auto-generated)
    ├── models/
    │   └── expense_model.dart      # Expense data model + ExpenseCategory enum
    ├── providers/
    │   └── expense_provider.dart   # Global state (ChangeNotifier)
    ├── services/
    │   └── firebase_service.dart   # Firebase Auth + Firestore CRUD layer
    ├── theme/
    │   └── app_theme.dart          # Dark theme, colors, typography, formatters
    ├── screens/
    │   ├── auth_screen.dart        # Login / Register / Guest sign-in
    │   ├── home_screen.dart        # Main expense list, search, filter, nav
    │   ├── add_edit_expense_screen.dart  # Add & Edit expense form
    │   └── analytics_screen.dart   # Charts & spending analytics
    └── widgets/
        ├── expense_list_tile.dart  # List tile + options sheet + delete dialog
        ├── summary_card.dart       # Gradient total spend summary card
        ├── category_filter_bar.dart # Horizontal scrollable category chips
        └── empty_state.dart        # Empty list state UI
```

**Architectural Pattern:**
- **Provider (ChangeNotifier)** — Lightweight, reactive state management
- **Repository Pattern** — `FirebaseService` abstracts all Firebase calls
- **Single Source of Truth** — `ExpenseProvider` holds and derives all UI state
- **Separation of Concerns** — Models, Services, Providers, Screens, Widgets in distinct layers

---

## 📦 Technologies & Packages Used

### Core Framework
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | ≥ 3.x | Cross-platform UI framework |
| **Dart** | ≥ 3.x | Programming language |

### Firebase
| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^3.8.0 | Firebase SDK initialization |
| `cloud_firestore` | ^5.5.0 | NoSQL database, real-time streams |
| `firebase_auth` | ^5.3.3 | User authentication (email + anonymous) |

### State Management
| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.2 | ChangeNotifier-based state management |

### UI & Charts
| Package | Version | Purpose |
|---------|---------|---------|
| `google_fonts` | ^6.2.1 | Inter typeface for clean typography |
| `fl_chart` | ^0.69.0 | Bar chart & pie/donut charts |
| `flutter_animate` | ^4.5.0 | Declarative micro-animations |
| `lottie` | ^3.1.3 | Lottie JSON animation playback |
| `iconsax` | ^0.0.8 | Extended icon set |

### Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| `intl` | ^0.19.0 | Date formatting & number formatting (LKR) |
| `uuid` | ^4.5.1 | Generating unique expense IDs |
| `shared_preferences` | ^2.3.3 | Local preferences storage |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

### Dev Dependencies
| Package | Purpose |
|---------|---------|
| `flutter_lints` | Recommended lint rules |
| `flutter_test` | Unit & widget testing framework |

---

## 🎨 Design System

| Token | Value | Usage |
|-------|-------|-------|
| **Font** | Inter (Google Fonts) | All text |
| **Background** | `#0D1117` | Screen backgrounds |
| **Surface** | `#161B22` | Cards, bottom sheets |
| **Surface Variant** | `#1C2128` | Input fields, chips |
| **Primary** | `#6C63FF` (violet) | Buttons, active states |
| **Accent** | `#00D4AA` (teal) | Charts, highlights |
| **Error** | `#FF4444` | Delete, error states |
| **Text Primary** | `#F0F6FC` | Main text |
| **Text Secondary** | `#8B949E` | Subtitles, hints |

**Category Colors (unique per category):**
- 🍔 Food → Warm orange  
- 🚗 Transport → Sky blue  
- 🛍️ Shopping → Hot pink  
- 🎮 Entertainment → Purple  
- 💊 Health → Emerald green  
- 📚 Education → Amber  
- ⚡ Utilities → Cyan  
- ✈️ Travel → Indigo  
- 📦 Other → Slate grey  

---

## 🤖 AI Tools Used

This project was built with assistance from the following AI tools:

| Tool | How It Was Used |
|------|----------------|
| **Google Antigravity (Gemini)** | Used for architecture planning, generating Flutter widget code, debugging build errors (Gradle version conflicts).
| **ChatGPT (GPT-4)** | Consulted for Firestore security rules best practices and Flutter state management pattern decisions |

### AI-Assisted Areas
- 🏗️ Initial project architecture 
- 🔥 Firebase integration 
- 🐛 Debugging: Gradle plugin version conflict fix (`com.google.gms.google-services 4.4.2 vs 4.5.0`)
- 📊 Analytics charts (fl_chart integration for bar & pie charts)
- ✨ Animation patterns using `flutter_animate`

---

## 🗂️ Data Model

```dart
class Expense {
  final String id;        // UUID v4
  final String title;     // Expense name
  final double amount;    // Amount in LKR (₨)
  final ExpenseCategory category;
  final DateTime date;
  final String? note;     // Optional description
  final String userId;    // Firebase Auth UID
  final DateTime createdAt;
}

enum ExpenseCategory {
  food, transport, shopping, entertainment,
  health, education, utilities, travel, other
}
```

**Firestore path:** `users/{userId}/expenses/{expenseId}`

---

## 🔒 Security

- All Firestore reads/writes are **user-scoped** — users can only access their own expenses
- Anonymous users get isolated data (cannot sync across devices — upgrade to email to persist)
- No sensitive keys are committed to source control — `google-services.json` should be in `.gitignore`

---


