# Find It - Lost & Found Flutter App

## Architecture Overview

This is a **single-file Flutter application** (~2500 lines in `lib/main.dart`) for a lost and found items platform targeting Kurdistan. All code resides in one file with clearly marked sections using `// ============` comment blocks.

### Key Sections in main.dart
- **DESIGN SYSTEM** - `AppColors` with semantic color tokens (lost=red, found=green, primary=blue)
- **MODELS** - `Post`, `Comment`, `UserModel` with JSON serialization
- **APP STATE** - `AppState` (ChangeNotifier) handles all business logic
- **ROUTING** - Simple conditional routing via `RootRouter`
- **AUTH SCREENS** - `WelcomeScreen`, `AuthScreen` (login/signup tabs)
- **MAIN SCREENS** - `HomeScreen`, `ActivityScreen`, `ProfileScreen`
- **DETAIL/CREATE** - `PostDetailScreen`, `CreatePostSheet`

### Data Flow
```
SharedPreferences ←→ AppState (ChangeNotifier) ←→ Provider.of<AppState> ←→ UI Widgets
```
- All data persisted to `shared_preferences` with keys `findit_user` and `findit_posts`
- No backend - fully client-side with mock data seeding on first run
- State changes trigger `notifyListeners()` and automatic UI rebuilds

## Conventions & Patterns

### Styling
- Use `GoogleFonts.andika()` for all text styling (Kurdish-friendly font)
- Follow `AppColors` constants - never hardcode colors
- Standard border radius: `12` for inputs, `16` for cards, `24` for buttons/chips
- Cards use white background with subtle shadow: `color: AppColors.textPrimary.withAlpha(20)`

### Post Types
- `type: 'lost'` → Red badge (`Color(0xFFEF4444)`)
- `type: 'found'` → Green badge (`Color(0xFF10B981)`)

### Phone Number Format
- Kurdistan format: 11 digits starting with 0 (e.g., `0750 222 34 44`)
- Custom `PhoneInputFormatter` auto-formats as user types
- Validation regex: `^0\d{10}$`

### Image Handling
- Images can be network URLs (start with `http`) or local file paths
- Use `CachedNetworkImage` for URLs, `Image.file` for local
- Always provide error/placeholder widgets
- Max 3 images per post

### Navigation Pattern
```dart
Navigator.of(context).push(MaterialPageRoute(builder: (_) => TargetScreen()));
```

## Development Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter test             # Run widget tests
flutter analyze          # Check for lint issues
```

## Dependencies Purpose
| Package | Usage |
|---------|-------|
| `provider` | State management via `ChangeNotifierProvider` |
| `shared_preferences` | Local data persistence |
| `google_fonts` | Andika font family |
| `timeago` | Human-readable timestamps |
| `url_launcher` | WhatsApp deep linking |
| `image_picker` | Gallery image selection |
| `cached_network_image` | Network image caching |
| `uuid` | Generate unique IDs for posts/comments |

## When Adding Features

1. **New screens**: Add as StatelessWidget/StatefulWidget in appropriate section
2. **New data**: Extend models, update `AppState` methods, call `_savePosts()`/`_saveUser()`
3. **New UI elements**: Follow existing card/button patterns with consistent styling
4. **WhatsApp integration**: Use `wa.me` deep links with URL-encoded messages

## Known Limitations
- Test file contains placeholder counter test (not updated for app)
- No actual backend authentication (password not verified)
- Images stored as file paths (not uploaded to server)
