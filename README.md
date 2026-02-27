# Find It — Lost & Found for Kurdistan

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![CI](https://github.com/Chenarrr/Lost-and-Found-with-Flutter-/actions/workflows/ci.yml/badge.svg)](https://github.com/Chenarrr/Lost-and-Found-with-Flutter-/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Find It** is a community-driven mobile app that helps people in Kurdistan, Iraq report and recover lost and found items. No passwords, no hassle — sign in with your phone number, post in seconds, and connect with others directly through WhatsApp.

---

## Table of Contents

- [About the App](#about-the-app)
- [Features](#features)
- [Localization](#localization)
- [How to Use](#how-to-use)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Firebase Setup](#firebase-setup)
- [Image Uploads — ImgBB](#image-uploads--imgbb)
- [Testing](#testing)
- [CI/CD](#cicd)
- [Environment Variables](#environment-variables)
- [Project Conventions](#project-conventions)
- [Contributing](#contributing)
- [License](#license)

---

## About the App

Find It was built to solve a simple but common problem in Kurdish communities: when someone loses something — a wallet, a phone, a pet, a document — there is no central, easy-to-use platform to report it or search for it. Find It fills that gap.

- Anyone can **browse posts without an account**.
- Registered users can **post**, **comment**, **contact** owners, and **manage** their own listings.
- Phone OTP authentication means zero password management — just enter your Iraqi phone number and verify the code.
- All communication happens through **WhatsApp**, the dominant messaging app in the region.

---

## Features

### Authentication
- **Phone-only sign-up / login** via SMS OTP — no email, no password
- **Resend OTP** with a 60-second countdown timer
- Iraqi phone numbers standardized to `+964` format automatically

### Posts
- **Create a post** — choose Lost or Found, pick a category, add photos, city, street, and an optional description
- **Photo upload** — pick from gallery or camera; images are uploaded to ImgBB and stored as URLs
- **Categories** — Electronics, Documents, Personal Items, Pets
- **Mark as Resolved** — post owner can close their listing once the item is recovered; a "RESOLVED" badge appears on the card and detail page
- **Delete a post** — owner can permanently remove their listing

### Home Feed
- **Real-time updates** — Firestore listeners keep the feed live without manual refresh
- **Pull-to-refresh** support
- **Search** by item name, city, or street (debounced)
- **Filter by city** — Erbil, Sulaymaniyah, Duhok, Halabja, Zakho, Koya
- **Filter by type** — All / Lost / Found
- Live stats chip showing count of Lost, Found, and total results

### Post Detail
- Full description, location, and timestamp
- Image viewer
- **Contact via WhatsApp** — opens WhatsApp directly to a pre-filled message; falls back to the web if WhatsApp is not installed
- **Comments** — any logged-in user can comment; submitted via the in-app text field or keyboard send action
- **Report** — flag a post as fake or inappropriate (one report per user)
- **Share** — native share sheet with post summary (text)

### Activity
- **My Posts** — all posts created by the logged-in user
- **My Comments** — a chronological list of every comment the user has left, with the post it belongs to

### Profile
- Avatar with name initial, phone number, and optional email
- Post stats: total, lost count, found count
- Quick link to Settings

### Settings
- **Change Name** — update display name stored in Firestore
- **Language** — switch between **English** and **Arabic (العربية)** at any time; the entire app (including RTL layout) updates instantly without restarting
- **Logout** — sign out from the current device
- **Delete Account** — permanently deletes the account, all posts, and the Firebase Auth record (with re-auth prompt if session is stale)
- **App version** shown at the bottom

### Localization
- Full **English / Arabic** support across every screen, dialog, button, and validation message
- RTL layout handled automatically by Flutter when Arabic is active
- Arabic relative timestamps via `timeago` (`"منذ دقيقتين"` instead of "2 minutes ago")
- City names, category chips, and all UI strings are translated
- The selected language is stored in app state and applied app-wide without a restart

---

## How to Use

### First Time — Sign Up

1. Open the app and tap **Get Started**.
2. Choose the **Sign Up** tab.
3. Enter your **full name**, **Iraqi phone number** (e.g. `07501234567`), and optionally your email.
4. Tap **Send Code** — you will receive an SMS OTP.
5. Enter the **6-digit code** on the next screen. Tap **Resend Code** if the code doesn't arrive within 60 seconds.
6. You are now logged in and taken to the home feed.

### Returning User — Log In

1. Open the app and tap **Get Started**.
2. Choose the **Log In** tab.
3. Enter your registered phone number and tap **Send Code**.
4. Enter the OTP to log in.

### Creating a Post

1. Tap the **Post** button (floating action button at the bottom of the home screen) or the **+** icon in the top-right.
2. Select **Lost** or **Found**.
3. Choose a **category**: Electronics, Documents, Personal Items, or Pets.
4. Enter the **item name**, **city**, and **street**.
5. Add an optional **description**.
6. Tap the camera/gallery area to attach **photos** (optional).
7. Tap **Submit** — the post appears on the feed immediately.

### Finding an Item

1. Browse the home feed or use the **search bar** to search by item name or location.
2. Use the **city chips** to narrow results to your city.
3. Switch between **All / Lost / Found** using the filter chips.
4. Tap **View** on a card to open the full post detail.
5. Tap **Contact via WhatsApp** to open WhatsApp and message the poster directly.

### Managing Your Posts

1. Go to the **Activity** tab to see all your posts and comments.
2. Go to **Profile** for a summary view of your listings.
3. Open a post you own to:
   - **Mark as Resolved** — closes the listing (the item was found/returned).
   - **Delete Post** — permanently removes the listing.

---

## Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| UI Framework | Flutter (Material 3) | Cross-platform mobile UI |
| Language | Dart 3 | Full null safety |
| State Management | Provider (`ChangeNotifier`) | App-wide reactive state |
| Authentication | Firebase Authentication (Phone / OTP) | Passwordless SMS login |
| Database | Cloud Firestore | Real-time NoSQL database |
| Image Hosting | ImgBB REST API | Free image CDN (no billing required) |
| HTTP Client | `http` package | ImgBB upload requests |
| Environment Variables | `flutter_dotenv` | Keeps API keys out of source code |
| Fonts | Google Fonts — Inter | Clean, modern typography |
| Deep Links | `url_launcher` | WhatsApp deep link + web fallback |
| Image Picking | `image_picker` | Gallery and camera access |
| Image Caching | `cached_network_image` | Smooth network image loading |
| Share | `share_plus` | Native OS share sheet |
| App Info | `package_info_plus` | Display app version in Settings |
| ID Generation | `uuid` | Unique IDs for posts and comments |
| Time Display | `timeago` | Human-friendly timestamps ("2 hours ago" / "منذ ساعتين") |
| Localization | `flutter_localizations` + `intl` | English & Arabic translations, RTL layout |

---

## Architecture

### Directory structure

```
lib/
├── main.dart                    # App entry point, theme, Firebase init
├── firebase_options.dart        # Generated Firebase config (do not edit manually)
│
├── config/
│   └── app_colors.dart          # Centralized color tokens (brand, status, neutrals)
│
├── l10n/
│   ├── app_en.arb               # English string resources
│   ├── app_ar.arb               # Arabic string resources
│   ├── app_localizations.dart   # Generated — do not edit manually
│   └── l10n.dart                # `context.l10n` extension + re-export
│
├── models/
│   ├── post.dart                # Post model — PostType & PostCategory enums, toJson/fromJson
│   ├── user.dart                # AppUser model
│   └── comment.dart             # Comment model
│
├── providers/
│   └── app_state.dart           # Single ChangeNotifier — auth, posts, OTP, mutations
│
├── navigation/
│   ├── root_router.dart         # Auth guard: WelcomeScreen ↔ MainPage
│   └── main_page.dart           # Bottom nav shell (Home, Activity, Profile tabs)
│
├── screens/
│   ├── auth/
│   │   ├── welcome_screen.dart  # Landing — routes to Login or Sign Up
│   │   ├── auth_screen.dart     # Login / Sign Up tabs with phone input
│   │   └── otp_screen.dart      # 6-digit OTP entry with 60s resend countdown
│   ├── post/
│   │   ├── post_detail_screen.dart  # Full post view, comments, WhatsApp, share
│   │   └── create_post_sheet.dart   # New post form (type, category, photos, location)
│   ├── home_screen.dart         # Feed with search, city filter, type filter
│   ├── activity_screen.dart     # My Posts + My Comments tabs
│   ├── profile_screen.dart      # User profile and post list
│   └── settings_screen.dart     # Name, logout, delete account, app version
│
├── widgets/
│   └── post_card.dart           # Reusable feed card with type/category/resolved badges
│
└── utils/
    └── phone_input_formatter.dart  # TextInputFormatter for Iraqi phone numbers

l10n.yaml                            # Flutter codegen config — arb-dir, output file
```

### Data flow

```
Firebase Auth ──► AppState._init() ──► authStateChanges()
                        │
                        ├──► _loadUser(uid) ──► currentUser (User model)
                        │
                        └──► _listenToPosts() ──► posts (List<Post>, live)
                                    │
                              Firestore snapshots
                              converted + notified
                                    │
                         Provider.of<AppState> / context.select
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              HomeScreen      ActivityScreen    ProfileScreen
```

`AppState` is the single source of truth. It:
- Listens to `authStateChanges()` and stores the subscription.
- Holds a live Firestore `snapshots()` listener on the `posts` collection.
- Exposes all write operations: `addPost`, `deletePost`, `addComment`, `reportPost`, `markPostResolved`, `updateUserName`, `deleteAccount`.
- All subscriptions are cancelled in `dispose()` to prevent memory leaks.

### Firestore data model

```
users/
  {uid}/
    id        String
    name      String
    phone     String
    email     String?
    createdAt Timestamp

posts/
  {postId}/
    id          String
    type        "lost" | "found"
    category    "electronics" | "documents" | "personalItems" | "pets"
    itemName    String
    description String?
    city        String
    street      String
    imageUrls   String[]
    userName    String
    userPhone   String
    userId      String
    createdAt   Timestamp
    isResolved  Boolean
    isHidden    Boolean   (set to true automatically when reports ≥ 10)
    comments    { id, postId, userId, userName, text, createdAt }[]
    reports     String[]  (array of userIds who reported)
```

---

## Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | ≥ 3.0 (run `flutter doctor` to verify) |
| Dart SDK | ≥ 3.0 (bundled with Flutter) |
| Xcode | ≥ 14 (for iOS builds on macOS) |
| Firebase CLI | latest (`npm i -g firebase-tools`) |
| A Firebase project | with Phone Auth + Firestore enabled |
| An ImgBB account | free at [imgbb.com](https://imgbb.com) |

### 1. Clone the repository

```bash
git clone https://github.com/Chenarrr/Lost-and-Found-with-Flutter-.git
cd Lost-and-Found-with-Flutter-
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Create the environment file

Create a `.env` file in the project root (this file is git-ignored and must never be committed):

```env
IMGBB_API_KEY=your_imgbb_api_key_here
```

> Get your free API key at [api.imgbb.com](https://api.imgbb.com). The free plan supports thousands of uploads per month.

### 4. Connect Firebase

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and create a project.
2. Enable **Phone** sign-in: *Authentication → Sign-in method → Phone → Enable*.
3. Enable **Cloud Firestore**: *Firestore Database → Create database → Start in test mode* (then add security rules).
4. Register your iOS app with the bundle ID `com.example.flutterApplication`.
5. Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
6. The `lib/firebase_options.dart` file is already generated — update it for your project if needed:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### 5. iOS URL scheme (required for Phone Auth)

Phone Auth on iOS uses a web-based reCAPTCHA flow that redirects back to the app. The `REVERSED_CLIENT_ID` from your `GoogleService-Info.plist` must be registered as a URL scheme in `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Replace `YOUR_REVERSED_CLIENT_ID` with the value from your `GoogleService-Info.plist`.

---

## Running the App

```bash
# List available devices
flutter devices

# Run on iOS simulator (debug)
flutter run

# Run on a connected physical device (debug)
flutter run -d <device-id>

# Run in release mode (better performance, closer to production)
flutter run --release

# Build a release IPA (iOS)
flutter build ipa

# Build a release APK (Android)
flutter build apk --release
```

> **Simulator note:** OTP SMS does not work on iOS simulators (APNs is unavailable). Use Firebase test phone numbers — see [Firebase Setup](#firebase-setup) below.

---

## Firebase Setup

### Firebase services used

| Service | What it does in this app |
|---|---|
| **Authentication** | Phone OTP login — verifies Iraqi numbers, assigns each user a unique UID |
| **Cloud Firestore** | Stores all posts, users, and comments — live real-time feed |
| **Security Rules** | Enforces who can read/write on Firebase servers — deployed via `firestore.rules` |
| **Firestore Index** | Composite index on `isResolved + createdAt` — required for efficient queries |

### Firestore security rules

The rules are in `firestore.rules` and are deployed with `firebase deploy --only firestore`.

| Who | Can do what |
|---|---|
| Anyone (unauthenticated) | Read all posts |
| Authenticated user | Create a post (must set `userId` = their own UID) |
| Authenticated user | Update only the `comments` or `reports` field on any post |
| Post owner | Update or delete their own post (any field) |
| User | Read, create, update, delete their own profile only |

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() { return request.auth != null; }
    function isOwner(userId) { return isAuthenticated() && request.auth.uid == userId; }

    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId)
                    && request.resource.data.name is string
                    && request.resource.data.name.size() >= 2;
      allow update: if isOwner(userId)
                    && request.resource.data.name is string
                    && request.resource.data.name.size() >= 2;
      allow delete: if isOwner(userId);
    }

    match /posts/{postId} {
      allow read: if true;
      allow create: if isAuthenticated()
                    && request.resource.data.userId == request.auth.uid
                    && request.resource.data.itemName is string
                    && request.resource.data.itemName.size() >= 2;
      allow update: if isAuthenticated() && (
        resource.data.userId == request.auth.uid
        || request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['comments', 'reports'])
      );
      allow delete: if isOwner(resource.data.userId);
    }

    match /{document=**} { allow read, write: if false; }
  }
}
```

### Firestore indexes

The app queries posts ordered by `createdAt` (descending). Firestore creates this index automatically on first query, but you can also add it manually in the Firebase Console.

### Testing Phone Auth on a simulator

APNs (push notifications) are not available on simulators, so real SMS won't arrive. Use **test phone numbers** instead:

1. Firebase Console → **Authentication** → **Sign-in method** → **Phone** → scroll to **Phone numbers for testing**.
2. Add a test number, e.g. `+9647501234567`, with a fixed verification code, e.g. `123456`.
3. Use that number in the app — Firebase skips reCAPTCHA and accepts the fixed code instantly.

---

## Image Uploads — ImgBB

The app does **not** use Firebase Storage. Firebase Storage requires a billing account, which is unavailable in Iraq. Instead, images are uploaded to [ImgBB](https://imgbb.com), a free image hosting service with a public REST API.

**Upload flow:**

```
User selects image from gallery / camera
          │
          ▼
  File bytes read → base64 encoded
          │
          ▼
  POST https://api.imgbb.com/1/upload
  body: { image: <base64>, name: "<itemName>_<userPhone>" }
          │
          ▼
  Response: { data: { url: "https://i.ibb.co/..." } }
          │
          ▼
  CDN URL saved in Firestore post document under imageUrls[]
```

Images are named `{itemName}_{userPhone}` for traceability. The API key is loaded from `.env` at runtime and is **never** compiled into the binary or committed to source control.

---

## WhatsApp Integration

Every post detail screen has a **Contact via WhatsApp** button (styled with WhatsApp green `#25D366`). It:

1. Builds a pre-filled message in the active language: `"Hi, I saw your post about: {itemName}"` (or the Arabic equivalent).
2. Strips all spaces from the phone number.
3. Tries the native deep link: `whatsapp://send?phone={number}&text={message}`.
4. Falls back to the web URL `https://wa.me/{number}?text={message}` if WhatsApp is not installed.

Iraqi phone numbers stored in Firestore use the `+964` country code prefix, which is the format expected by WhatsApp.

---

## Testing

The project has unit tests covering models and the `AppState` provider.

```bash
# Run all tests
flutter test

# Run tests with coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Test files live in `test/`:

```
test/
├── widget_test.dart              # Smoke test — app loads without crashing
├── models/
│   ├── post_test.dart            # Post.fromJson / toJson / copyWith
│   ├── user_test.dart            # User.fromJson / toJson
│   └── comment_test.dart         # Comment.fromJson / toJson
└── providers/
    └── app_state_test.dart       # AppState with mocked Firebase Auth + Firestore
```

`AppState` is dependency-injectable — pass mock `FirebaseAuth` and `FirebaseFirestore` instances to the constructor:

```dart
final app = AppState(auth: mockAuth, firestore: mockFirestore);
```

The `FLUTTER_TEST` environment variable is detected at startup to skip the real Firebase initialization in tests.

---

## CI/CD

GitHub Actions runs on every push and pull request to `main`. The workflow has two sequential jobs:

| Job | Steps |
|---|---|
| **lint** | `dart format --check`, `flutter analyze --fatal-warnings` |
| **test** | `flutter test` (requires lint to pass first) |

The CI pipeline creates a stub `.env` file (`IMGBB_API_KEY=ci_placeholder`) so that `flutter analyze` can resolve the asset without real credentials.

No secrets are required in the GitHub repository settings.

---

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `IMGBB_API_KEY` | **Yes** | ImgBB API key for image uploads |

The `.env` file is listed as a Flutter asset in `pubspec.yaml` so it is bundled into the app at build time. It is git-ignored and must never be committed.

---

## Project Conventions

- **Null safety** — all models use strict null-safe casts (`as String? ?? ''`); no `dynamic` in selectors.
- **Typed selectors** — `context.select<AppState, T>` with an explicit type parameter prevents the `_dependents.isEmpty` assertion that fires with `dynamic` during navigation.
- **Immutable models** — `Post`, `User`, and `Comment` are immutable value types with `copyWith` methods.
- **ChangeNotifier disposal** — `AppState.dispose()` cancels both `_authSubscription` and `_postsSubscription` to prevent memory leaks.
- **ValueKey on list items** — `PostCard` widgets use `ValueKey(post.id)` so Flutter can diff the list efficiently without re-building unchanged cards.
- **No secrets in source** — API keys live in `.env`, Firebase config is in `firebase_options.dart` (not sensitive, generated by FlutterFire CLI).
- **Consistent styling** — all chips use pill border radius (`999`), `showCheckmark: false` globally in `ChipThemeData`, and status colors are centralized in `AppColors`.

---

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Make your changes and run `dart format lib/` before committing.
4. Run `flutter analyze --fatal-warnings` and `flutter test` to ensure everything passes.
5. Commit: `git commit -m "Add your feature"`.
6. Push and open a pull request against `main`.

**Please do not commit:**
- `.env` or any file containing API keys or credentials
- `GoogleService-Info.plist` or `google-services.json`
- Build outputs (`build/`, `*.ipa`, `*.apk`)

---

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.
