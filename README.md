# Find It — Lost & Found Flutter App

Find It is a Flutter mobile application for the Kurdistan region that helps people report and discover lost and found items. The app is fully client-side — no backend required — using `shared_preferences` for local data persistence.

---

## Features

- **User authentication** — sign up and login with local storage; credentials persist across logout so users can log back in
- **Post management** — create "lost" or "found" posts with item details, location, and up to 3 images
- **Smart filtering** — browse all posts with city filter chips and a live search bar
- **Comments** — community interaction with a per-post comment thread
- **Activity dashboard** — track your own posts and comments in dedicated tabs
- **User profile** — display name, phone, email, and your own posts at a glance
- **WhatsApp integration** — deep-link directly to the poster's WhatsApp
- **Report system** — community-driven flagging for fake or inappropriate posts
- **Phone formatting** — auto-formats Kurdistan 11-digit numbers (`0750 222 34 44`)

---

## Tech Stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Material 3) |
| State management | Provider + ChangeNotifier |
| Local storage | shared_preferences |
| Fonts | Google Fonts — Inter |
| Images | cached_network_image + image_picker |
| Navigation | Flutter MaterialPageRoute |
| Timestamps | timeago |
| IDs | uuid v4 |

---

## Project Structure

```
lib/
├── main.dart                      # App entry point, theme setup
├── config/
│   └── app_colors.dart            # Centralized design-system color tokens
├── models/                        # Immutable data models with copyWith + JSON
│   ├── comment.dart
│   ├── post.dart                  # Includes PostType enum (lost | found)
│   └── user.dart
├── providers/
│   └── app_state.dart             # All business logic via ChangeNotifier
├── routes/
│   ├── main_page.dart             # Bottom-nav shell (Home / Activity / Profile)
│   └── root_router.dart           # Auth-gate routing
├── screens/
│   ├── home_screen.dart
│   ├── post_detail_screen.dart
│   ├── activity_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── create_post_sheet.dart
│   └── auth/
│       ├── auth_screen.dart
│       └── welcome_screen.dart
└── widgets/
    ├── post_card.dart
    └── phone_input_formatter.dart

test/
├── widget_test.dart               # App-level smoke tests
├── models/
│   ├── post_test.dart
│   ├── user_test.dart
│   └── comment_test.dart
└── providers/
    └── app_state_test.dart
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.x (Dart ≥ 3.9.2)
- Android Studio or VS Code with the Flutter extension

### Installation

```bash
git clone <repository-url>
cd Lost-and-Found-with-Flutter-
flutter pub get
flutter run
```

### Common commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device / emulator
flutter test             # Run all tests (44 tests)
flutter test --coverage  # Run tests and generate coverage/lcov.info
flutter analyze          # Static analysis (0 issues expected)
dart format .            # Auto-format all Dart files
flutter build apk        # Build release APK
flutter build web        # Build web release
```

---

## Design System

### Colors (`lib/config/app_colors.dart`)

| Token | Usage |
|---|---|
| `lostPrimary` | Red — lost item badges and accents |
| `foundPrimary` | Green — found item badges and accents |
| `primaryBlue` | Blue — primary actions, buttons, nav |
| `accentIndigo` | Indigo — gradient accents |
| Text, border, and card tokens | Neutral grays throughout |

### Typography

Inter (via Google Fonts) is the single font family used across the entire app.

### UI conventions

- Border radius: `12` (inputs), `16` (cards), `24` (buttons / bottom sheet)
- Cards: white background with a subtle drop shadow
- Images: maximum 3 per post; network URLs use `CachedNetworkImage`, local files use `Image.file`

---

## CI / CD

### Continuous Integration (`.github/workflows/ci.yml`)

Runs on every push and pull request to `main`:

1. Check formatting — `dart format --set-exit-if-changed .`
2. Static analysis — `flutter analyze --fatal-infos`
3. Run all tests with coverage — `flutter test --coverage`
4. Upload coverage report to Codecov

### Continuous Deployment (`.github/workflows/cd.yml`)

Triggered on GitHub Release or manual dispatch:

- **Android** — `flutter build apk --release`, uploaded as a workflow artifact
- **Web** — `flutter build web --release`, uploaded as a workflow artifact

---

## Refactor & Quality Improvements (Feb 2026)

The following production-readiness improvements were applied across the codebase.

### Models

- All model fields made `final` (immutable by default).
- `Post.comments` and `Post.reports` are now `List.unmodifiable(...)` — accidental in-place mutation throws at runtime.
- Added `copyWith()` to `Post`, `User`, and `Comment`.
- Added `PostType` enum (`lost` / `found`) replacing the raw `String` type field. JSON serialisation uses `PostType.name`; deserialisation uses a Dart 3 switch expression with a safe fallback.
- Renamed `user_model.dart` → `user.dart` and `UserModel` → `User` for consistency with the other model filenames.

### State management (`app_state.dart`)

- Replaced all `post.type == 'lost'` string comparisons with `post.type == PostType.lost`.
- Replaced `firstWhere` (throws on miss) with `indexWhere` + early-return guard — eliminates crash risk when a post ID is not found.
- `addComment` and `reportPost` now use `copyWith()` instead of mutating list fields in place.
- **Auth bug fixed:** `logout()` previously deleted the user's credentials from `SharedPreferences`, making re-login impossible. Credentials are now stored under a separate key (`findit_registered_user`) that survives logout. The active session (`findit_session`) is the only thing cleared on logout.

### Memory leaks fixed

- `main_page.dart` — removed `TickerProviderStateMixin` and an `AnimationController` that was created inside `_openCreatePost` but never disposed.
- `home_screen.dart` — added `dispose()` to call `_searchController.dispose()`.
- `post_detail_screen.dart` — added `dispose()` for `_commentController`.

### Code style

- Font standardised: all `GoogleFonts.andika()` calls replaced with `GoogleFonts.inter()` to match the app theme.
- All hardcoded `Color(0xFF...)` values replaced with `AppColors` constants.
- Private fields renamed to follow the `_camelCase` convention (`searchCtrl` → `_searchController`, `_type` → `_postType`, `_selected` → `_selectedIndex`, etc.).
- Typed record syntax `({Comment comment, Post post})` used in `activity_screen.dart` instead of `Map<String, dynamic>`.
- All untyped function parameters given explicit types.
- `analysis_options.yaml` extended with `avoid_print`, `prefer_single_quotes`, `prefer_const_constructors`, `prefer_final_fields`, `prefer_final_locals`, `require_trailing_commas`, and related rules.

### Tests (44 passing, 0 failing)

| File | What is tested |
|---|---|
| `test/models/post_test.dart` | `PostType` values, construction, unmodifiable lists, JSON round-trip, `copyWith` |
| `test/models/user_test.dart` | Construction (with/without email), JSON round-trip, `copyWith` |
| `test/models/comment_test.dart` | Construction, JSON round-trip, `copyWith` |
| `test/providers/app_state_test.dart` | Init + seed data, signup, login (phone, email, wrong identifier), logout, addPost, deletePost, addComment, reportPost (including deduplication) |
| `test/widget_test.dart` | App loads, welcome screen, Get Started navigation, auth screen fields, form validation |
