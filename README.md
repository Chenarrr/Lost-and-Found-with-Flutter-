# Find It — Lost & Found for Kurdistan

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A community-driven mobile app that helps people in Kurdistan report and recover lost and found items. Users post items they've lost or found, browse listings by category, and contact each other directly via WhatsApp — all without passwords.

---

## Features

- **Phone-only authentication** — sign up and log in using SMS OTP. No passwords ever stored.
- **Post listings** — create Lost or Found posts with photos, category, location (city + street), and a description.
- **Browse & filter** — view all posts on the home feed; filter by Lost/Found and by category.
- **Post detail** — full post view with image gallery, location, and a comment section.
- **WhatsApp contact** — one-tap button to open a WhatsApp chat with the post owner.
- **Activity feed** — see comments and interactions on your own posts.
- **Profile** — view and manage all posts you've created.
- **Image upload** — photos are hosted on ImgBB (no Firebase Storage billing required).
- **Real-time updates** — Firestore live listeners keep posts and comments in sync.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (Material 3) |
| State Management | Provider (`ChangeNotifier`) |
| Authentication | Firebase Auth — Phone / OTP |
| Database | Cloud Firestore |
| Image Hosting | ImgBB API (free tier) |
| HTTP Client | `http` package |
| Environment Variables | `flutter_dotenv` |
| Fonts | Google Fonts — Inter |
| Deep Links | `url_launcher` (`whatsapp://`) |
| Image Picking | `image_picker` |
| Image Caching | `cached_network_image` |

---

## Architecture

```
lib/
├── config/
│   └── app_colors.dart        # Centralized color tokens (Material 3)
├── models/
│   ├── post.dart              # Post, PostType enum, PostCategory enum
│   ├── user.dart              # AppUser with Firestore serialization
│   └── comment.dart           # Comment with Firestore serialization
├── providers/
│   └── app_state.dart         # Single ChangeNotifier — auth, posts, OTP flow
├── routes/
│   ├── root_router.dart       # Auth guard: shows WelcomeScreen or MainPage
│   └── main_page.dart         # Bottom nav shell (Home, Activity, Profile)
├── screens/
│   ├── auth/
│   │   ├── welcome_screen.dart
│   │   ├── auth_screen.dart   # Login / Signup tabs
│   │   └── otp_screen.dart    # 6-digit OTP entry
│   ├── home_screen.dart       # Feed with filters
│   ├── post_detail_screen.dart
│   ├── create_post_sheet.dart # Bottom sheet for new posts
│   ├── activity_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── post_card.dart          # Reusable feed card
    └── phone_input_formatter.dart
```

### Data flow

```
Firebase Auth ──► AppState (ChangeNotifier)
Firestore     ──►     │
                      ▼
                 Provider.of<AppState>
                      │
             ┌────────┼────────┐
             ▼        ▼        ▼
         HomeScreen  Profile  Activity
```

`AppState` holds a single real-time listener on the Firestore `posts` collection and exposes `currentUser`, `posts`, and all mutation methods. All screens read from it via `Provider.of` or `context.select`.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- A Firebase project with **Authentication** (Phone) and **Cloud Firestore** enabled
- An [ImgBB](https://imgbb.com) account and API key (free)
- Xcode (for iOS builds)

### 1. Clone and install dependencies

```bash
git clone https://github.com/your-username/Lost-and-Found-with-Flutter-.git
cd Lost-and-Found-with-Flutter-
flutter pub get
```

### 2. Configure environment variables

Create a `.env` file in the project root (this file is git-ignored):

```env
IMGBB_API_KEY=your_imgbb_api_key_here
```

> Get your free API key at [api.imgbb.com](https://api.imgbb.com).

### 3. Connect Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Phone** authentication under *Authentication → Sign-in method*.
3. Enable **Cloud Firestore** and deploy the security rules (see below).
4. Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`.
5. Run `flutterfire configure` or manually update `lib/firebase_options.dart`.

### 4. iOS — URL scheme (required for Phone Auth)

Open `ios/Runner/Info.plist` and confirm the `REVERSED_CLIENT_ID` from your `GoogleService-Info.plist` is registered as a URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

This allows Firebase to redirect back to the app after the reCAPTCHA web flow.

### 5. Run the app

```bash
# iOS simulator
flutter run

# Physical device
flutter run --release
```

---

## Firebase Setup

### Firestore security rules

Deploy the rules from `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

Key rules:
- **Users** — only the authenticated owner can write to their own document.
- **Posts** — anyone authenticated can create; only the post owner can update/delete.
- **Comments** — anyone authenticated can add; only the comment author can delete.

### Testing Phone Auth on a simulator

APNs (push notifications) don't work on simulators, so SMS OTP won't arrive. Use **test phone numbers** instead:

1. Firebase Console → Authentication → Sign-in method → Phone → Test phone numbers.
2. Add a number (e.g. `+9647501234567`) with a fixed code (e.g. `123456`).
3. Use that number in the app — Firebase bypasses reCAPTCHA and accepts the fixed code.

---

## Image Uploads

Images are uploaded to ImgBB using the REST API. Each image is named `{itemName}_{userPhone}` for traceability. The `IMGBB_API_KEY` is loaded at runtime from `.env` via `flutter_dotenv` and is never committed to source control.

```
User picks image
      │
      ▼
_uploadToImgBB()  ─── POST https://api.imgbb.com/1/upload
      │                    body: { image: base64, name: "{itemName}_{phone}" }
      ▼
Returns CDN URL  ─► stored in Firestore post document
```

---

## WhatsApp Integration

The post detail screen has a **Contact via WhatsApp** button that:

1. Tries the native `whatsapp://send?phone=...&text=...` deep link.
2. Falls back to `https://wa.me/...` in the browser if WhatsApp is not installed.

The phone number is stripped of spaces before being passed to the URL.

---

## Project Conventions

- **Null safety** — all models are null-safe; `fromJson` uses safe casts (`as String? ?? ''`).
- **Disposal** — `AppState` cancels both `_authSubscription` and `_postsSubscription` in `dispose()` to prevent memory leaks.
- **No hardcoded secrets** — API keys live in `.env`, never in source files.
- **ValueKey on list items** — `PostCard` widgets are keyed by `post.id` to help Flutter diff the list efficiently.
- **Type-safe selectors** — `context.select<AppState, bool>` is used instead of `Object?` to prevent unnecessary rebuilds.

---

## Environment Variables Reference

| Variable | Required | Description |
|---|---|---|
| `IMGBB_API_KEY` | Yes | ImgBB API key for image uploads |

---

## Contributing

1. Fork the repository.
2. Create a branch: `git checkout -b feature/your-feature`.
3. Commit your changes: `git commit -m "Add your feature"`.
4. Push and open a pull request.

Please do not commit `.env` or any file containing API keys or credentials.

---

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.
