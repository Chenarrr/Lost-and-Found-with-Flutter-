# Find It - Lost & Found Flutter App

Find It is a Flutter-based mobile application designed specifically for the Kurdistan region to help people find lost items and report found items. The app provides an intuitive platform for posting, searching, and commenting on lost and found items with the goal of reuniting people with their belongings.

## Architecture

This is a **single-file Flutter application** (~2500 lines) with all core logic in `lib/main.dart`, organized in clearly marked sections. The app is fully client-side, using `shared_preferences` for local data persistence with no backend requirements.

## Features

- **User Authentication:** Simple sign-up and login with local storage
- **Post Management:** Create "lost" or "found" posts with item details, location, and up to 3 images
- **Smart Filtering:** Browse all posts with city filters and search functionality
- **Interactive Comments:** Comment system for community interaction and information sharing
- **Activity Dashboard:** Track your own posts and comments in a dedicated activity screen  
- **User Profiles:** Simple profile management with user information display
- **WhatsApp Integration:** Direct contact with item posters via WhatsApp deep links
- **Report System:** Community-driven reporting for inappropriate or fake posts
- **Kurdish Language Support:** Uses Andika font for optimal Kurdish text rendering
- **Auto-formatting:** Smart phone number formatting for Kurdistan region (11-digit format)

## Tech Stack

- **Framework:** Flutter 
- **State Management:** Provider with ChangeNotifier
- **Local Storage:** shared_preferences
- **UI Components:** Material Design with custom styling
- **Fonts:** Google Fonts (Andika)
- **Image Handling:** cached_network_image + image_picker
- **Navigation:** Standard Flutter navigation

## Key Dependencies

```yaml
dependencies:
  provider: ^6.1.2           # State management
  shared_preferences: ^2.3.2 # Local data persistence  
  google_fonts: ^6.2.1       # Andika font family
  timeago: ^3.7.0            # Human-readable timestamps
  url_launcher: ^6.3.1       # WhatsApp integration
  image_picker: ^1.1.2       # Gallery image selection
  cached_network_image: ^3.4.1 # Network image caching
  uuid: ^4.5.1               # Unique ID generation
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- [Dart SDK](https://dart.dev/get-dart) (3.0+)
- An IDE: [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extension

### Installation

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd Lost-and-Found-with-Flutter-
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the app
   ```bash
   flutter run
   ```

### Development Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator  
flutter test             # Run widget tests
flutter analyze          # Check for lint issues
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app (macOS only)
```

## Project Structure

```
lib/
├── main.dart                    # Single-file app with all logic (~2500 lines)
├── config/
│   └── app_colors.dart         # Design system with semantic color tokens
├── models/                      # Data models with JSON serialization
│   ├── comment.dart            
│   ├── post.dart               
│   └── user_model.dart         
├── providers/
│   └── app_state.dart          # ChangeNotifier for business logic
├── routes/                      # Navigation components
│   ├── main_page.dart          
│   └── root_router.dart        
├── screens/                     # UI screens
│   ├── activity_screen.dart    
│   ├── create_post_sheet.dart  
│   ├── home_screen.dart        
│   ├── post_detail_screen.dart 
│   ├── profile_screen.dart     
│   ├── settings_screen.dart    
│   └── auth/                   # Authentication screens
└── widgets/                     # Reusable UI components
    ├── phone_input_formatter.dart
    └── post_card.dart          
```

### Architecture Patterns

- **State Management:** Provider pattern with ChangeNotifier
- **Data Flow:** SharedPreferences ↔ AppState ↔ UI Widgets  
- **Navigation:** Standard Flutter MaterialPageRoute
- **Styling:** Centralized design tokens with GoogleFonts.andika()
- **Image Handling:** Network URLs + local file paths with caching

## Design System

### Color Scheme
- **Lost Items:** Red theme (`#EF4444`) for lost item posts
- **Found Items:** Green theme (`#10B981`) for found item posts  
- **Primary:** Blue theme for general UI elements
- **Typography:** Andika font family (Kurdish language optimized)

### UI Conventions
- Border radius: `12px` (inputs), `16px` (cards), `24px` (buttons/chips)
- Cards: White background with subtle shadow
- Phone format: Kurdistan 11-digit format (`0750 222 34 44`)
- Image limit: Maximum 3 images per post
