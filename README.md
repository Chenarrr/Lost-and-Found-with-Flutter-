# Find It - Lost & Found App

`Find It` is a Flutter-based mobile application designed to help people in Kurdistan find their lost items and report items they have found. It provides a simple and intuitive platform for users to post, search, and comment on lost and found items, with the goal of reuniting people with their belongings.

The application is fully client-side, using `shared_preferences` to store all data locally on the user's device.

### Features

*   **User Authentication:** Simple sign-up and login functionality.
*   **Post Creation:** Users can create posts for "lost" or "found" items, including details like item name, description, location, and images.
*   **Browse & Filter:** A main feed displays all posts, with options to filter by city or search for specific items.
*   **Post Details:** View detailed information about a post, including images and user comments.
*   **Commenting System:** Users can leave comments on posts to ask questions or provide information.
*   **Activity Tracking:** A dedicated screen shows the user's own posts and comments.
*   **User Profile:** A simple profile screen displays user information.
*   **Contact via WhatsApp:** A button to directly open a WhatsApp chat with the item's poster.
*   **Reporting:** Users can report posts that are inappropriate or fake.

## Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install)
*   [Dart SDK](https://dart.dev/get-dart)
*   An IDE like [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/) with the Flutter plugin.

### Installation

1.  Clone the repo
    ```sh
    git clone https://your_repository_url/flutter_application.git
    ```
2.  Navigate to the project directory
    ```sh
    cd flutter_application
    ```
3.  Install dependencies
    ```sh
    flutter pub get
    ```

## Usage

To run the application, use the following command:

```sh
flutter run
```

This command will launch the application on a connected device or emulator.

## Testing

To run the widget tests, use:

```sh
flutter test
```

## Project Structure

The project follows the standard Flutter project structure.

- `lib/`: Contains the Dart source code for the application.
- `android/`, `ios/`, `web/`, etc.: Platform-specific code.
- `pubspec.yaml`: Defines project dependencies and metadata.
- `test/`: Contains tests for the application.

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.