# Find It — Unified Lost & Found Infrastructure

[![Flutter](https://img.shields.io/badge/Flutter-v3.27-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-v11.0-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A production-grade, community-driven platform designed to reunite lost items with their owners across Kurdistan. Built with a focus on high-performance, security-first architecture, and a premium mobile user experience.

---

## 🏗 System Architecture

The application follows a modular, reactive architecture leveraging **Provider** for state management and **Firebase** for a scalable, serverless backend.

### Core Tech Stack

- **Frontend**: Flutter (Material 3) with a custom design system.
- **State Management**: Reactive `ChangeNotifier` patterns via Provider.
- **Backend-as-a-Service**: Firebase Core.
  - **Authentication**: Secure Phone-based OTP (No-password architecture).
  - **Database**: Cloud Firestore (Real-time, NoSQL).
  - **Storage**: Cloud Storage for heavy media assets.
- **Design System**: Atomic design principles with centralized tokens in `app_colors.dart`.

---

## 🔐 Security & Data Governance

This system is built with **Production-Ready Security Rules** to ensure data integrity and user privacy.

### Firestore Security Layer

- **Identity Enforcement**: Users can only modify their own profile documents (`/users/{userId}`).
- **Content Governance**: Public read-access for listings, but write-access is restricted to authenticated owners.
- **Data Validation**: Strict schema enforcement at the database level (e.g., name length validation, type checking).

### Storage Governance

- **Access Control**: Publicly readable post-media with authenticated-only write permissions.
- **Payload Restrictions**: Hard limit of 10MB per image to prevent storage exhaustion.

---

## 🍎 iOS Implementation Guide (Apple-First)

The system is optimized for the Apple ecosystem. Follow these critical steps to ensure seamless redirect handling on iOS devices.

### 1. URL Scheme Configuration

To handle the reCAPTCHA redirect during Phone Auth, the `REVERSED_CLIENT_ID` must be registered as a URL Type in Xcode.

- **File**: `ios/Runner/Info.plist`
- **Key**: `CFBundleURLTypes` -> `CFBundleURLSchemes`
- **ID**: `com.googleusercontent.apps.400649966615-gk79sn6p96r4fre6ssqrs5nt1cnp7ov3`

### 2. Firebase Identity

The iOS application is registered with the bundle ID `com.example.flutterApplication`. Ensure the `GoogleService-Info.plist` is synchronized across all build targets.

---

## 📋 Production Launch Checklist

Before making the system live, ensure the following DevOps tasks are performed in the [Firebase Console](https://console.firebase.google.com):

1. **[REQUIRED] Upgrade to Blaze Plan**: Firebase Storage requires the Pay-As-You-Go plan to handle production image uploads.
2. **[REQUIRED] Support Email**: Verify that a support email is configured in Project Settings to prevent OAuth verification failures.
3. **[OPTIONAL] Android Integration**: If expanding to Android, register the SHA-1/SHA-256 fingerprints in the Firebase Console.

---

## 🛠 Maintenance & Deployment

### Deployment Commands

Deploy security rules updates:

```bash
firebase deploy --only firestore:rules,storage
```

### Local Development

```bash
# Sync dependencies
flutter pub get

# Execute Unit & Widget tests
flutter test

# Generate iOS Build
flutter build ios --release
```

---

## 📂 Project Structure

```text
lib/
├── config/             # Static configurations & Color Tokens
├── models/             # Immutable data structures (User, Post, Comment)
├── providers/          # Global Business Logic (AppState)
├── routes/             # Navigation Logic & Guards
├── screens/            # UI Layer (Auth, Home, Profile, etc.)
└── widgets/            # Reusable Atomic UI Components
```

---

## 📜 License

This project is licensed under the **MIT License**.
