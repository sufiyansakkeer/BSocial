# BSocial - Social Media Application

BSocial is a social media application built using Flutter and Firebase. It allows users to connect, share, and interact with each other through posts, comments, and likes. The application utilizes the Provider package for state management and Firebase as the backend for data storage and authentication.
<table>
  <tr>
    <td>
      <img src="https://github.com/sufiyansakkeer/BSocial/assets/89620555/c1409727-bc31-48b2-b69e-bc250b2063f1" alt="Image 1" width="300px">
    </td>
    <td>
      <img src="https://github.com/sufiyansakkeer/BSocial/assets/89620555/a5a199c9-33a2-435a-af91-96b9e923e593" alt="Image 2" width="300px">
    </td>
    <td>
      <img src="https://github.com/sufiyansakkeer/BSocial/assets/89620555/d53d96a6-57f1-4de8-b3d4-399b3ffb83c9" alt="Image 1" width="300px">
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/sufiyansakkeer/BSocial/assets/89620555/5ca56286-1c73-422d-8dc6-f8f3c153c8c7" alt="Image 2" width="300px">
    </td>
    <td>
      <img src="https://github.com/sufiyansakkeer/BSocial/assets/89620555/eae6c60d-f522-4eb6-8044-bf9ec7606854" alt="Image 1" width="300px">
    </td>
    <td>
      <img src="https://github.com/sufiyansakkeer/BSocial/assets/89620555/ce0e9b05-0b90-4425-be95-99bf02d941bf" alt="Image 2" width="300px">
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/sufiyansakkeer/BSocial/assets/89620555/b63a6057-c675-4a58-97f9-65c41677687b" alt="Image 1" width="300px">
    </td>
    <td>
      <img src="https://github.com/sufiyansakkeer/BSocial/assets/89620555/447e19c2-9ee2-40c3-91ca-9e09da33301f)" alt="Image 2" width="300px">
    </td>
  </tr>
</table>

## Features

- **User Authentication:** BSocial provides secure user authentication using Firebase Authentication. Users can create an account, log in, and log out of the application.
- **Create and Share Posts:** Users can create posts, add images or text content, and share them with their followers or publicly.
- **Post Interactions:** BSocial allows users to like posts, comment on them, and view the number of likes and comments for each post.
- **Follow and Unfollow Users:** Users can follow other users to see their posts in their feed and unfollow them if desired.
- **Explore and Discover:** BSocial provides an explore feature to discover new posts and users based on different categories or tags.
- **User Profile:** Each user has a profile page displaying their posts, followers, and following. Users can also update their profile information and profile picture.

## Prerequisites

Before running the application, ensure that you have the following installed:

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: [Install Dart](https://dart.dev/get-dart)
- Firebase Account: [Create a Firebase Account](https://firebase.google.com/)

## Getting Started

To get started with the project, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/sufiyansakkeer/BSocial
   ```

2. Change to the project directory:

   ```bash
   cd BSocial
   ```

3. Install the dependencies:

   ```bash
   flutter pub get
   ```

4. Set up Firebase:
   - Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Enable Firebase Authentication and Firestore for your project.
   - Obtain the Firebase configuration file (google-services.json for Android or GoogleService-Info.plist for iOS) and add it to the respective platform folders in your Flutter project.
   - Update the Firebase configuration in the `lib/services/firebase_service.dart` file with your own Firebase project configuration.

5. Run the application:

   ```bash
   flutter run
   ```

## Folder Structure

The project follows a standard Flutter folder structure:

- `lib`: Contains the main Dart code for the application.
  - `models`: Contains the data models used by the application.
  - `providers`: Contains the providers for managing application state.
  - `screens`: Contains the UI screens for different features of the application.
  - `services`: Contains the services for handling Firebase authentication and Firestore operations.
  - `utils`: Contains utility functions or classes used across the application.
  - `main.dart`: The entry point of the application.

## Dependencies

The application uses the following dependencies:

- `flutter`: The Flutter SDK.
- `provider`: A package for state management in Flutter.
- `firebase_core`: FlutterFire plugin for initializing Firebase services.
- `firebase_auth`: FlutterFire plugin for Firebase Authentication.
- `cloud_firestore`: FlutterFire plugin for Firestore database.
- Other Flutter dependencies required for UI and functionality (specified in the `pubspec.yaml` file).

These dependencies are listed in the `pubspec.yaml` file. To install them, run the following command:

```bash
flutter pub get
```

## Contributing

Contributions to this project are welcome. If you find any issues or have suggestions for improvements, please submit an issue or create a pull request.

## License



This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute the code.
