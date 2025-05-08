# BSocial - Social Media Application Documentation

## Table of Contents

1. [Introduction](#introduction)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Technical Stack](#technical-stack)
5. [Project Structure](#project-structure)
6. [Authentication Flow](#authentication-flow)
7. [Post Management Flow](#post-management-flow)
8. [User Interaction Flow](#user-interaction-flow)
9. [Chat System Flow](#chat-system-flow)
10. [Offline Functionality](#offline-functionality)
11. [State Management](#state-management)
12. [Navigation](#navigation)
13. [Data Storage](#data-storage)
14. [Error Handling](#error-handling)
15. [Configuration](#configuration)
16. [UI/UX Design](#uiux-design)
17. [Testing](#testing)
18. [Getting Started](#getting-started)

## Introduction

BSocial is a feature-rich social media application built with Flutter that allows users to connect, share posts, chat, and interact with each other. The application follows clean architecture principles and provides a seamless user experience with both online and offline capabilities.

## Architecture

BSocial follows a layered clean architecture approach with the following layers:

1. **Presentation Layer**: Contains UI components, screens, and state management (Bloc)
2. **Domain Layer**: Contains business logic, entities, and use cases
3. **Data Layer**: Contains repositories, data sources, and models

This separation of concerns ensures:

- Testability
- Maintainability
- Scalability
- Independence from external frameworks

## Features

### Authentication

- Email/Password registration and login
- Google Sign-In integration
- Password reset functionality
- Session management
- Profile creation and customization

### Post Management

- Create posts with images and descriptions
- View posts in a feed
- Like/unlike posts
- Comment on posts
- Delete posts
- View post details

### User Interaction

- Follow/unfollow users
- View user profiles
- Search for users
- View followers and following lists
- Update profile information

### Chat System

- Real-time messaging
- Chat room creation
- Message read status
- Chat history
- Delete messages and chat rooms

### Offline Functionality

- Cached data access when offline
- Synchronization when back online
- Graceful degradation of features in offline mode

## Technical Stack

### Frontend

- **Framework**: Flutter 3.29+
- **State Management**: Bloc/Cubit with flutter_bloc
- **Navigation**: go_router
- **Local Storage**: Hive
- **Network**: http, internet_connection_checker
- **UI Components**: Custom widgets, animations

### Backend

- **Firebase Authentication**: User authentication
- **Cloud Firestore**: Database for posts, users, chats
- **Firebase Storage**: Media storage
- **Firebase Messaging**: Push notifications
- **Firebase Crashlytics**: Error reporting

## Project Structure

The project follows a feature-first organization within the clean architecture layers:

```
lib/
├── core/                  # Core functionality and utilities
│   ├── config/            # App configuration
│   ├── constants/         # App constants
│   ├── errors/            # Error handling
│   ├── network/           # Network utilities
│   ├── services/          # Core services
│   ├── theme/             # App theme
│   └── utils/             # Utility functions
├── data/                  # Data layer
│   ├── datasources/       # Data sources
│   │   ├── local/         # Local data sources
│   │   └── remote/        # Remote data sources
│   ├── models/            # Data models
│   │   └── hive/          # Hive models for local storage
│   └── repositories/      # Repository implementations
├── di/                    # Dependency injection
├── domain/                # Domain layer
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Use cases
└── presentation/          # Presentation layer
    ├── blocs/             # Bloc state management
    ├── features/          # Feature screens
    │   ├── auth/          # Authentication screens
    │   ├── chat/          # Chat screens
    │   ├── home/          # Home screens
    │   ├── post/          # Post screens
    │   ├── profile/       # Profile screens
    │   └── search/        # Search screens
    ├── routes/            # Navigation routes
    └── widgets/           # Reusable widgets
```

## Authentication Flow

1. **User Registration**:

   - User enters username, email, password, and selects a profile image
   - Data validation occurs on the client side
   - User data is sent to Firebase Authentication
   - Profile image is uploaded to Firebase Storage
   - User document is created in Firestore
   - User is redirected to the home screen

2. **User Login**:

   - User enters email and password
   - Credentials are validated against Firebase Authentication
   - User document is fetched from Firestore
   - User status is updated to "online"
   - User is redirected to the home screen

3. **Google Sign-In**:

   - User clicks Google Sign-In button
   - Google authentication flow is initiated
   - On successful authentication, user data is retrieved
   - If the user is new, a document is created in Firestore
   - User is redirected to the home screen

4. **Sign Out**:

   - User clicks sign out button
   - User status is updated to "offline"
   - Firebase Authentication session is terminated
   - User is redirected to the login screen

5. **Password Reset**:
   - User enters email address
   - Password reset email is sent via Firebase Authentication
   - User receives email with reset instructions

## Post Management Flow

1. **Create Post**:

   - User navigates to the add post screen
   - User selects an image and adds a description
   - Image is uploaded to Firebase Storage
   - Post document is created in Firestore
   - Post is added to the local cache
   - User is redirected to the feed

2. **View Feed**:

   - Posts are fetched from Firestore and cached locally
   - Posts are displayed in chronological order (newest first)
   - User can pull to refresh for the latest posts
   - Posts show the username, profile image, content, and interaction counts

3. **Like/Unlike Post**:

   - User taps the like button on a post
   - Post document is updated in Firestore
   - UI is updated to reflect the change
   - Like count is incremented/decremented

4. **Comment on Post**:

   - User navigates to the post detail screen
   - User enters a comment
   - Comment is saved to Firestore
   - Comments are displayed in chronological order

5. **Delete Post**:
   - User navigates to their own post
   - User selects delete option
   - Post document is deleted from Firestore
   - Post image is deleted from Firebase Storage
   - Post is removed from the local cache
   - UI is updated to reflect the change

## User Interaction Flow

1. **Follow/Unfollow User**:

   - User navigates to another user's profile
   - User clicks the follow/unfollow button
   - User document is updated in Firestore for both users
   - UI is updated to reflect the change
   - Follower/following counts are updated

2. **View User Profile**:

   - User navigates to a profile page
   - User information is fetched from Firestore
   - User's posts are fetched and displayed
   - Follower/following counts are displayed
   - Follow/unfollow button is displayed if not the current user

3. **Search for Users**:

   - User navigates to the search screen
   - User enters a search query
   - Search is performed against usernames in Firestore
   - Results are displayed in real-time
   - User can click on a result to view the profile

4. **Update Profile**:
   - User navigates to their profile
   - User selects edit profile option
   - User can update username, profile image, and status
   - Changes are saved to Firestore
   - Profile image is updated in Firebase Storage if changed

## Chat System Flow

1. **Create Chat Room**:

   - User navigates to another user's profile
   - User clicks the message button
   - System checks if a chat room already exists
   - If not, a new chat room is created in Firestore
   - User is redirected to the chat screen

2. **Send Message**:

   - User enters a message in the chat screen
   - Message is sent to Firestore
   - Chat room's last message and timestamp are updated
   - Message appears in the chat for both users

3. **View Chat History**:

   - User navigates to the chat list screen
   - Chat rooms are fetched from Firestore
   - Rooms are sorted by last message timestamp
   - User clicks on a chat room to view the conversation
   - Messages are fetched and displayed in chronological order

4. **Mark Messages as Read**:

   - User opens a chat conversation
   - Unread messages are marked as read in Firestore
   - UI is updated to reflect read status
   - Unread message count is updated

5. **Delete Chat**:
   - User long-presses on a chat in the list
   - User selects delete option
   - Chat room and messages are deleted from Firestore
   - UI is updated to reflect the change

## Offline Functionality

1. **Data Caching**:

   - All fetched data is cached locally using Hive
   - Each data type has its own Hive box
   - Data is stored with timestamps for cache invalidation

2. **Offline Access**:

   - When offline, app reads from local cache
   - UI indicates offline mode
   - Features that require network connectivity are disabled or show appropriate messages

3. **Synchronization**:

   - When connection is restored, app syncs with remote data
   - New data is fetched and cache is updated
   - Pending operations are executed if possible

4. **Graceful Degradation**:

   - App detects network status using internet_connection_checker
   - Features gracefully degrade based on connectivity
   - Error messages are user-friendly and suggest offline mode actions

5. **Mock Data Sources**:
   - When Firebase initialization fails, mock data sources are used
   - These provide basic functionality without requiring network connectivity
   - User is informed that they are in offline mode

## State Management

BSocial uses the BLoC (Business Logic Component) pattern for state management:

1. **BLoC Architecture**:

   - Each feature has its own BLoC
   - BLoCs handle business logic and state transitions
   - Events trigger state changes
   - UI reacts to state changes

2. **Key BLoCs**:

   - **AuthBloc**: Manages authentication state
   - **PostBloc**: Manages post creation, retrieval, and interactions
   - **SearchBloc**: Manages user search functionality
   - **ChatBloc**: Manages chat functionality

3. **State Flow**:

   - UI sends events to BLoC
   - BLoC processes events and updates state
   - UI rebuilds based on new state
   - Error states are handled gracefully

4. **Dependency Injection**:
   - GetIt is used for dependency injection
   - BLoCs are registered as singletons
   - Repositories and use cases are injected into BLoCs

## Navigation

BSocial uses go_router for navigation:

1. **Router Configuration**:

   - Routes are defined in app_router.dart
   - Each route corresponds to a screen
   - Routes can have parameters and nested routes

2. **Navigation Flow**:

   - Home screen is the root route
   - Authentication screens are separate routes
   - Feature screens are nested under the home route
   - Deep linking is supported

3. **Route Guards**:

   - Authentication state determines accessible routes
   - Unauthenticated users are redirected to login
   - Authenticated users are redirected to home if trying to access auth screens

4. **Navigation Methods**:
   - context.go() for navigating to a new route
   - context.push() for pushing a route onto the stack
   - context.pop() for returning to the previous route

## Data Storage

BSocial uses a combination of remote and local storage:

1. **Remote Storage**:

   - **Firestore**: Stores user data, posts, comments, and chat messages
   - **Firebase Storage**: Stores images (profile pictures and post images)

2. **Local Storage**:

   - **Hive**: Provides fast, encrypted local storage
   - Separate boxes for different entity types
   - Data is cached with timestamps for invalidation

3. **Data Models**:

   - Each entity has a corresponding model
   - Models handle serialization/deserialization
   - Hive models extend entities for local storage

4. **Cache Strategy**:
   - Cache-first, network-fallback strategy
   - Data is fetched from cache first
   - If cache is empty or stale, data is fetched from network
   - Cache is updated with new data

## Error Handling

BSocial implements comprehensive error handling:

1. **Error Types**:

   - **ServerFailure**: For network and server errors
   - **CacheFailure**: For local storage errors
   - **AuthFailure**: For authentication errors
   - **NetworkFailure**: For connectivity issues

2. **Error Propagation**:

   - Errors are caught at the data layer
   - Converted to failures and propagated up
   - Either type from dartz package is used for success/failure results

3. **User Feedback**:

   - Errors are displayed as snackbars or dialogs
   - User-friendly messages explain the issue
   - Retry options are provided when appropriate

4. **Logging**:
   - Errors are logged using the logger package
   - In production, errors are reported to Firebase Crashlytics
   - Logs include context for debugging

## Configuration

BSocial uses environment-specific configuration:

1. **Environment Types**:

   - Development
   - Staging
   - Production

2. **Configuration Parameters**:

   - API URLs
   - Cache duration
   - Feature flags
   - Analytics settings

3. **Feature Flags**:

   - Offline mode
   - Analytics
   - Crash reporting
   - Performance monitoring

4. **Build Variants**:
   - Debug builds use development configuration
   - Release builds use production configuration
   - Custom builds can specify configuration

## UI/UX Design

BSocial features a modern, clean UI design:

1. **Design System**:

   - Material 3 design language
   - Custom theme with light and dark modes
   - Consistent spacing and typography
   - Responsive layouts

2. **Components**:

   - Custom buttons with different variants
   - Card-based post display
   - Bottom navigation for main sections
   - Pull-to-refresh for content updates

3. **Animations**:

   - Page transitions
   - Micro-interactions for buttons
   - Loading indicators
   - Like button animations

4. **Accessibility**:
   - Semantic labels for screen readers
   - Sufficient contrast ratios
   - Scalable text
   - Support for system preferences

## Testing

BSocial includes comprehensive testing:

1. **Unit Tests**:

   - Tests for use cases
   - Tests for repositories
   - Tests for BLoCs
   - Mocks using mockito

2. **Widget Tests**:

   - Tests for UI components
   - Tests for screen flows
   - Tests for user interactions

3. **Integration Tests**:

   - End-to-end tests for key user flows
   - Tests with mock and real data sources

4. **Test Coverage**:
   - Aim for high test coverage
   - Focus on critical business logic
   - Continuous integration runs tests automatically

## Getting Started

To get started with BSocial development:

1. **Prerequisites**:

   - Flutter SDK 3.29+
   - Dart SDK
   - Firebase account
   - Android Studio or VS Code

2. **Setup**:

   - Clone the repository
   - Run `flutter pub get` to install dependencies
   - Configure Firebase (add google-services.json and GoogleService-Info.plist)
   - Run `flutter pub run build_runner build` to generate code

3. **Running**:

   - Use `flutter run` for development
   - Use `flutter run --release` for production-like experience
   - Use `flutter test` to run tests

4. **Contributing**:
   - Follow the coding style guide
   - Write tests for new features
   - Submit pull requests with clear descriptions
   - Keep documentation up to date
