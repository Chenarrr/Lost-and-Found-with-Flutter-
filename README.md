# Find It — Lost & Found Flutter App

Find It is a Flutter app that helps users report and discover lost and found items.
The app currently runs fully client-side with local persistence (`shared_preferences`) and is optimized for clear UX, consistent design, and stable behavior.

## What This Version Improves

- Easier user flows on key screens (`Auth`, `Create Post`, `Post Details`, `Activity`)
- Unified color and component styling across the app
- More resilient startup routing (`RootRouter` waits for state hydration)
- Stronger input normalization for signup/login (trimmed phone/email handling)
- Better error feedback for actions like report, comment, image pick, and WhatsApp launch

## Features

- Local signup/login session flow (with OTP simulation)
- Create lost/found posts with category, location, and up to 3 images
- Search and city filtering on Home
- Post detail with comments, reporting, and WhatsApp contact
- Activity tab for personal posts and comment history
- Profile + settings with logout confirmation

## Tech Stack

- Flutter (Material 3)
- Provider (`ChangeNotifier`) for state management
- `shared_preferences` for local storage
- `cached_network_image`, `image_picker`, `url_launcher`
- `google_fonts` (Inter), `timeago`, `uuid`

## Project Structure

```text
lib/
├── main.dart
├── config/
│   └── app_colors.dart
├── models/
│   ├── comment.dart
│   ├── post.dart
│   └── user.dart
├── providers/
│   └── app_state.dart
├── routes/
│   ├── main_page.dart
│   └── root_router.dart
├── screens/
│   ├── activity_screen.dart
│   ├── create_post_sheet.dart
│   ├── home_screen.dart
│   ├── post_detail_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   └── auth/
│       ├── auth_screen.dart
│       ├── otp_screen.dart
│       └── welcome_screen.dart
└── widgets/
    ├── phone_input_formatter.dart
    └── post_card.dart

test/
├── models/
├── providers/
└── widget_test.dart
```

## Setup

### Prerequisites

- Flutter SDK `>=3.x`
- Dart SDK `>=3.9.2`
- Android Studio or VS Code with Flutter extension

### Install and run

```bash
git clone <repository-url>
cd Lost-and-Found-with-Flutter-
flutter pub get
flutter run
```

## Development Commands

```bash
dart format .
flutter analyze
flutter test
flutter test --coverage
flutter build apk --release
flutter build web --release
```

## Design System Notes

- Single font family: **Inter**
- Color tokens are centralized in `lib/config/app_colors.dart`
- Shared component style is defined in `ThemeData` (`lib/main.dart`)
- Lost/found states use dedicated semantic colors (red/green)
- Neutral surfaces and borders are consistent across cards, forms, and chips

## State and Persistence

- `AppState` hydrates session + posts from local storage at startup
- `RootRouter` shows a loading indicator until hydration completes
- Session is stored separately from registered user data
- Posts, comments, and reports are persisted locally

## Testing

Current test coverage includes:

- Model serialization and immutability
- `AppState` authentication/post/comment/report flows
- Core widget smoke flow

Run:

```bash
flutter test
```

## Production Readiness Checklist

Completed in this repo:

- Consistent theming and UI feedback patterns
- Startup hydration guard before routing
- Safer async action handling and error feedback
- Input validation and normalization on auth and post forms
- Structured CI/CD workflows (`.github/workflows/ci.yml`, `.github/workflows/cd.yml`)
- Automated tests passing

Required before real production deployment:

- Replace local auth with secure backend auth (token/session management)
- Move posts/comments/reports to backend database
- Add server-side moderation and anti-abuse controls
- Add privacy policy, terms, and data-retention policy
- Add analytics/crash reporting (e.g. Firebase Crashlytics)
- Add secrets/config management per environment
- Add offline/online sync conflict strategy
- Add accessibility audit and localization coverage
- Add integration/end-to-end tests on release pipeline

## CI/CD

- CI (`ci.yml`): format check, analyze, tests, coverage upload
- CD (`cd.yml`): release build artifacts for Android and Web

## Current Limitations

- Data is local to the device (no shared backend)
- OTP is simulated for demo flow
- Login credentials are not cryptographically secured (local demo behavior)

## License

Use your project license here (MIT/Apache-2.0/etc.).
