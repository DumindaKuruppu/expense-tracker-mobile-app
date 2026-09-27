# Expense Tracker Mobile App - CyphLab Assessment

A production-ready, modern Expense Tracker mobile application built with **Flutter**, **Provider**, and **Cloud Firestore**. Designed for seamless personal finance management, offering real-time synchronization, dynamic monthly summaries, category filtering, search, and category spending analytics.

---

## Table of Contents
- [Architecture & Design Overview](#architecture--design-overview)
- [Key Features](#key-features)
- [Project Directory Structure](#project-directory-structure)
- [Dependencies & Packages Used](#dependencies--packages-used)
- [Setup & Installation Guide](#setup--installation-guide)
- [Firebase Firestore Configuration](#firebase-firestore-configuration)
- [AI Tool Disclosure](#ai-tool-disclosure)

---

## Architecture & Design Overview

The application follows the **MVVM (Model-View-ViewModel)** architectural pattern using **Provider** for clean state management and separation of concerns:

- **Model Layer (`models/`)**: Encapsulates data schema and Firestore serialization logic (`toMap`, `fromFirestore`, `fromMap`, `copyWith`).
- **Service Layer (`services/`)**: Isolates database communication inside `FirestoreService`. Implements real-time streams, async CRUD operations, and an in-memory fallback mechanism to ensure app stability across unconfigured environments.
- **Provider Layer (`providers/`)**: `ExpenseProvider` manages state, dynamic month filtering, search filtering, category selection, and calculates spending analytics (monthly total, month-over-month % trend, category distribution).
- **View / Presentation Layer (`screens/`, `widgets/`)**: Modular Material 3 UI widgets reacting to provider changes with explicit Loading, Empty, and Error states.

---

## Key Features

1. **CRUD Operations**:
   - Add new expense with Title, Amount, Category, Date, and optional Note.
   - Edit existing expense records with pre-filled forms.
   - Delete expense via swipe-to-delete gesture or confirmation dialog.

2. **Cloud Firestore Integration**:
   - Real-time data synchronization using Firestore snapshots stream.
   - Isolated service class (`FirestoreService`) managing database queries.
   - Graceful fallback mode ensures uninterrupted app operation.

3. **Dashboard & Summary**:
   - Dynamic monthly total calculations based on selected month.
   - Month-over-month trend comparison percentage badge (`+X% vs last month`).
   - Month & Year selector to view historical spending.

4. **Filtering & Search**:
   - Filter by category chips (Food & Dining, Transport, Bills & Utilities, Entertainment, Shopping, Health & Fitness, Education, Other).
   - Real-time search bar filtering across title, note, and category.
   - One-tap "Clear Filters" action.

5. **Form Validation & UX States**:
   - Strict input validation (positive non-zero numbers, mandatory non-empty title/category/date).
   - Dedicated UI states: Loading indicator, Empty State illustration, and Error View with retry option.
   - Keyboard dismissing on background tap.

6. **Bonus Analytics Feature**:
   - Category spending distribution pie chart powered by `fl_chart`.
   - Interactive touch sections and top spending category highlight card.
   - Category breakdown list with spending progress bars and percentages.

---

## Project Directory Structure

```
lib/
├── constants/
│   ├── app_colors.dart         # Material 3 color palette & gradients
│   └── app_constants.dart      # Category definitions, icons, colors & currency
├── models/
│   └── expense_model.dart      # Expense entity with Firestore serialization
├── services/
│   └── firestore_service.dart  # Firestore database streams & CRUD operations
├── providers/
│   └── expense_provider.dart   # Provider state, filters & monthly calculations
├── screens/
│   ├── home_screen.dart        # Dashboard, summary card, search & expense list
│   ├── add_edit_expense_screen.dart # Form with validation & date picker
│   └── stats_screen.dart       # fl_chart pie chart & category spending breakdown
├── widgets/
│   ├── summary_card.dart       # Gradient card showing monthly total & trends
│   ├── expense_card.dart       # Expense list item with category icon & amount
│   ├── category_chip.dart      # Interactive filter chip widget
│   ├── empty_state.dart        # Empty state view with action button
│   ├── error_view.dart         # Error state view with retry option
│   └── confirm_delete_dialog.dart # Delete confirmation modal
└── main.dart                   # Application entry point & theme setup
```

---

## Dependencies & Packages Used

| Package | Version | Purpose |
| :--- | :--- | :--- |
| [`provider`](https://pub.dev/packages/provider) | `^6.1.2` | Reactive State Management |
| [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) | `^5.6.5` | Cloud Firestore NoSQL Database |
| [`firebase_core`](https://pub.dev/packages/firebase_core) | `^3.12.1` | Firebase SDK initialization |
| [`fl_chart`](https://pub.dev/packages/fl_chart) | `^0.70.2` | Spending distribution pie chart |
| [`intl`](https://pub.dev/packages/intl) | `^0.19.0` | Currency formatting & date parsing |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | `^1.0.8` | iOS style icons support |

---

## Setup & Installation Guide

### Prerequisites
- Flutter SDK (`>= 3.5.0`)
- Dart SDK (`>= 3.5.0`)
- Android Studio / VS Code with Flutter extension
- An Android Emulator, iOS Simulator, or Physical Device

### Quick Start Commands

1. **Clone Repository & Navigate to Folder**:
   ```bash
   git clone <repository-url>
   cd expense_tracker_mobile_app
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Unit & Widget Tests**:
   ```bash
   flutter test
   ```

4. **Launch Application**:
   ```bash
   flutter run
   ```

---

## Firebase Firestore Configuration

To connect the app to your custom Firebase project:

1. Create a Firebase Project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Cloud Firestore Database** in test mode or with security rules permitting read/write to the `expenses` collection.
3. Configure FlutterFire CLI:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. Place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.

> **Note**: The app includes built-in fallback handling. If run without Firebase configuration, it automatically operates seamlessly in mock mode with sample expenses, allowing instant testing without setup hurdles.

---

## AI Tool Disclosure

In accordance with CyphLab technical assessment requirements, AI coding tools (Google Gemini in Android Studio) were utilized during the development of this project for:
- Accelerating structural boilerplate generation and Material 3 widget styling.
- Designing unit test cases for model serialization and provider state verification.
- Drafting clean documentation and architecture guides.

All business logic, data models, state management flows, and visual components were reviewed, tested, and validated to adhere to Flutter best practices.
