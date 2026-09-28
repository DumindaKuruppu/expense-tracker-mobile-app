# Expense Tracker Mobile App - CyphLab Assessment

A production-ready, modern Expense Tracker mobile application built with **Flutter**, **Provider**, **Firebase Authentication**, **Google Sign-In**, **Facebook Sign-In**, **Dark Theme Engine**, and **Cloud Firestore**. Designed for seamless personal finance management, offering user authentication, social logins, user-scoped data isolation, real-time synchronization, dynamic monthly summaries, category filtering, search, and category spending analytics.

---

## Table of Contents
- [Architecture & Design Overview](#architecture--design-overview)
- [Key Features](#key-features)
- [Project Directory Structure](#project-directory-structure)
- [Dependencies & Packages Used](#dependencies--packages-used)
- [Setup & Installation Guide](#setup--installation-guide)
- [Firebase Authentication & Social Logins Setup](#firebase-authentication--social-logins-setup)
- [AI Tool Disclosure](#ai-tool-disclosure)

---

## Architecture & Design Overview

The application follows the **MVVM (Model-View-ViewModel)** architectural pattern using **Provider** for clean state management and separation of concerns:

- **Model Layer (`models/`)**: Encapsulates data schema and Firestore serialization logic (`toMap`, `fromFirestore`, `fromMap`, `copyWith`).
- **Service Layer (`services/`)**:
  - `AuthService`: Encapsulates Firebase Authentication (Email/Password, Google Sign-In, Facebook Sign-In, Guest mode, Password Reset).
  - `FirestoreService`: Encapsulates database operations scoped per user ID (`users/{userId}/expenses`).
- **Provider Layer (`providers/`)**:
  - `ThemeProvider`: Manages dynamic Light & Dark mode themes (`ThemeMode.light` / `ThemeMode.dark`).
  - `AuthProvider`: Manages user authentication state, current user context, login, registration, social sign-ins, password reset, and logout.
  - `ExpenseProvider`: Reacts to user authentication changes via `ChangeNotifierProxyProvider`, managing filters, category breakdown, search, and monthly calculations.
- **View / Presentation Layer (`screens/`, `widgets/`)**:
  - `AuthWrapper`: Routes users to `LoginScreen` or `HomeScreen` based on authentication status.
  - `AppDrawer`: Navigation Drawer containing User Profile Header, Dashboard, Analytics, Profile Modal, Settings Dialog, Dark Mode Switcher, Sign Out, and Developer Info footer.
  - `LoginScreen`: Modern sign-in and registration interface with email/password validation, Google Sign-In button, Facebook Sign-In button, forgot password modal, and "Continue as Guest" option.
  - `HomeScreen`: Dashboard displaying monthly summary, category filters, search bar, and user-scoped expense list.

---

## Key Features

1. **Navigation Drawer & Customization**:
   - User Profile header with name, email/guest badge, and initial avatar.
   - Profile account details bottom sheet (User ID, Auth provider, Session type).
   - Settings dialog (Currency display, Filter reset action).
   - **Dark Mode Switcher**: Instant theme toggle between Material 3 Light and Dark schemes.
   - **Developer Info**: Footer card showcasing developer information, app version `v1.0.0+1`, and submission details.

2. **Firebase Authentication & Social Sign-Ins**:
   - Email and Password Sign In & Registration with full validation.
   - **Google Sign-In** integration.
   - **Facebook Sign-In** integration.
   - Password reset via email.
   - "Continue as Guest" anonymous sign-in support.

3. **User-Scoped Cloud Firestore Sync**:
   - Real-time data synchronization with expenses scoped under `users/{userId}/expenses`.
   - Complete CRUD operations (Add, Edit, Delete with swipe gesture / confirmation dialog).

4. **Dashboard & Monthly Summary**:
   - Dynamic monthly total calculation based on selected month.
   - Month-over-month trend comparison percentage badge (`+X% vs last month`).
   - Month & Year selector for historical tracking.

5. **Filtering & Search**:
   - Category filter chips (Food & Dining, Transport, Bills & Utilities, Entertainment, Shopping, Health & Fitness, Education, Other).
   - Real-time search across expense title, note, and category.

6. **Category Spending Analytics**:
   - Interactive pie chart powered by `fl_chart`.
   - Top spending category callout and progress bars per category.

---

## Project Directory Structure

```
lib/
├── constants/
│   ├── app_colors.dart         # Material 3 color palette & gradients
│   └── app_constants.dart      # Category definitions, icons, colors & currency
├── firebase_options.dart       # FlutterFire CLI generated Firebase configuration
├── models/
│   └── expense_model.dart      # Expense entity with Firestore serialization
├── services/
│   ├── auth_service.dart       # Firebase Authentication & Social Sign-In service
│   └── firestore_service.dart  # User-scoped Firestore CRUD & streams
├── providers/
│   ├── theme_provider.dart     # Light & Dark theme state controller
│   ├── auth_provider.dart      # Authentication state controller
│   └── expense_provider.dart   # Expense state, filters & calculations
├── screens/
│   ├── auth_wrapper.dart       # Auth router (Login vs Home)
│   ├── login_screen.dart       # Sign-in / Registration / Social Auth / Guest screen
│   ├── home_screen.dart        # Dashboard, search, user menu & expense list
│   ├── add_edit_expense_screen.dart # Expense form with validation
│   └── stats_screen.dart       # fl_chart pie chart & category breakdown
├── widgets/
│   ├── app_drawer.dart         # Navigation Drawer with Profile, Settings, Dark Mode & Dev Info
│   ├── summary_card.dart       # Monthly summary gradient card
│   ├── expense_card.dart       # Expense list item card
│   ├── category_chip.dart      # Filter chip widget
│   ├── empty_state.dart        # Empty state view
│   ├── error_view.dart         # Error state view
│   └── confirm_delete_dialog.dart # Confirmation modal
└── main.dart                   # Application entry point & provider setup
```

---

## Dependencies & Packages Used

| Package | Version | Purpose |
| :--- | :--- | :--- |
| [`provider`](https://pub.dev/packages/provider) | `^6.1.2` | Reactive State Management |
| [`firebase_auth`](https://pub.dev/packages/firebase_auth) | `^5.5.1` | User Authentication (Email, Google, Facebook, Guest) |
| [`google_sign_in`](https://pub.dev/packages/google_sign_in) | `^6.2.2` | Native Google Sign-In SDK integration |
| [`flutter_facebook_auth`](https://pub.dev/packages/flutter_facebook_auth) | `^7.1.1` | Native Facebook Authentication SDK integration |
| [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) | `^5.6.5` | Cloud Firestore NoSQL Database |
| [`firebase_core`](https://pub.dev/packages/firebase_core) | `^3.12.1` | Firebase SDK core initialization |
| [`fl_chart`](https://pub.dev/packages/fl_chart) | `^0.70.2` | Interactive category spending charts |
| [`intl`](https://pub.dev/packages/intl) | `^0.19.0` | Currency formatting & date parsing |

---

## Setup & Installation Guide

### Prerequisites
- Flutter SDK (`>= 3.5.0`)
- Dart SDK (`>= 3.5.0`)
- Android Studio / VS Code

### Commands

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Unit & Widget Tests**:
   ```bash
   flutter test
   ```

3. **Launch Application**:
   ```bash
   flutter run
   ```

---

## AI Tool Disclosure

In accordance with CyphLab technical assessment requirements, AI coding tools (Google Gemini in Android Studio) were utilized during the development of this project for:
- Implementing Navigation Drawer, ThemeProvider, Profile bottom sheet, and Settings dialogs.
- Implementing Firebase Authentication & Social Sign-In integrations (Google & Facebook).
- Designing unit test suites and documentation.
