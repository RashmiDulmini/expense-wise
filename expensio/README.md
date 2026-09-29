# 💸 Expensio — Expense Tracker App

A beautifully crafted, full-featured **Expense Tracker** built with Flutter & Firebase. Designed for the **CyphLab Flutter Developer Internship** practical task.

---

## ✨ Features

### Core
- ✅ **Add, Edit & Delete** expenses
- ✅ **9 Categories**: Food, Transport, Shopping, Entertainment, Health, Education, Utilities, Travel, Other
- ✅ **Firebase Firestore** — real-time data sync
- ✅ **Firebase Authentication** — email/password + anonymous guest mode
- ✅ **Monthly total** — prominent summary card
- ✅ **Expense history list** with category badges
- ✅ **Filter** by: This Week, This Month, Last Month, All Time
- ✅ **Sort** by: Date (newest/oldest), Amount (high/low)
- ✅ **Filter by category** — horizontal chip bar
- ✅ **Search** — live search across title, category, notes
- ✅ **Form validation** — all fields validated
- ✅ **Loading / Empty / Error states** handled gracefully

### Expense Fields
| Field | Required | Notes |
|-------|----------|-------|
| Title | ✅ | Min. 2 characters |
| Amount | ✅ | Positive number, max $999,999 |
| Category | ✅ | Picked from grid |
| Date | ✅ | Date picker (past dates only) |
| Note | ❌ | Optional multi-line description |

### Additional (Bonus) Features
- 📊 **Analytics screen** with:
  - Weekly bar chart (last 7 days)
  - Category donut chart (interactive touch)
  - Category breakdown with progress bars
- 🔐 **Firebase Authentication** (Email + Anonymous)
- 👤 **Profile screen** with account details & sign-out
- 🎨 **Elegant dark mode** — deep navy/slate with vibrant accents
- ✨ **Micro-animations** throughout using `flutter_animate`
- 🔍 **Live search** functionality
- 🔄 **Real-time sync** via Firestore streams

---

## 🏗️ Architecture & Code Structure

```
lib/
├── main.dart                  # Entry point, Provider setup, App gate
├── firebase_options.dart      # Firebase config (replace with your values)
├── models/
│   └── expense_model.dart     # Expense data model + Category enum
├── providers/
│   └── expense_provider.dart  # State management (ChangeNotifier)
├── services/
│   └── firebase_service.dart  # Firebase Auth + Firestore CRUD
├── theme/
│   └── app_theme.dart         # Dark theme, color palette, typography
├── screens/
│   ├── auth_screen.dart       # Login / Register / Guest
│   ├── home_screen.dart       # Main list, search, filters, navigation
│   ├── add_edit_expense_screen.dart  # Add/Edit form
│   └── analytics_screen.dart  # Charts & analytics
└── widgets/
    ├── expense_list_tile.dart  # List item with options bottom sheet
    ├── summary_card.dart       # Gradient total spend card
    ├── category_filter_bar.dart # Horizontal category chips
    └── empty_state.dart        # Empty list state
```

**Pattern**: Provider (ChangeNotifier) for state management, Repository pattern via `FirebaseService`, clean separation of concerns.

---

## 🔥 Firebase Setup

> **The app requires Firebase to function.** Follow these steps:

### Option A — FlutterFire CLI (Recommended)
```bash
# 1. Install FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configure (replace with your project ID)
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

# 3. This auto-regenerates lib/firebase_options.dart
```

### Option B — Manual
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an Android app (`com.example.expensio`)
3. Download `google-services.json` → place in `android/app/`
4. Enable **Authentication** → Email/Password + Anonymous
5. Enable **Firestore Database** (start in test mode)
6. Replace placeholder values in `lib/firebase_options.dart`

### Firestore Security Rules
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

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build APK
flutter build apk --release
```

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `cloud_firestore` | Database (CRUD + real-time streams) |
| `firebase_auth` | User authentication |
| `provider` | State management |
| `google_fonts` | Inter typeface |
| `fl_chart` | Bar & pie charts |
| `flutter_animate` | Micro-animations |
| `intl` | Date & number formatting |
| `uuid` | Unique expense IDs |
| `iconsax` | Icon set |

---

## 🎨 Design System

- **Font**: Inter (Google Fonts)
- **Background**: `#0D1117` (deep navy)
- **Surface**: `#161B22`
- **Primary**: `#6C63FF` (violet)
- **Accent**: `#00D4AA` (teal)
- **Error**: `#FF4444`
- Category colors: unique per-category palette

---

*Built with ❤️ for the CyphLab Flutter Developer Internship*
