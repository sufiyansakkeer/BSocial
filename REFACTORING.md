# BSocial App Refactoring Guide

This document outlines the refactoring that has been done to the BSocial app and provides guidance on how to continue the refactoring process.

## Completed Refactoring

1. **Project Structure**
   - Reorganized folder structure to follow clean architecture principles
   - Created feature-first organization within the presentation layer
   - Added proper configuration files

2. **Dependency Management**
   - Updated dependencies to latest stable versions
   - Migrated to Flutter 3.29 recommendations
   - Implemented proper Gradle configuration with Kotlin DSL
   - Added dependency version catalog for better version management

3. **Code Quality**
   - Added improved linting rules
   - Added proper error handling
   - Added logging service

4. **UI/UX**
   - Enhanced theme configuration
   - Improved navigation with GoRouter

## Next Steps

### 1. Data Layer Refactoring

- Implement Freezed models for all entities
- Update repositories to use proper error handling with Either type
- Enhance Hive implementation for better offline support
- Implement proper pagination for lists (posts, comments, etc.)

```dart
// Example of a Freezed model
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    required String photoUrl,
    required List<String> followers,
    required List<String> following,
    @Default("offline") String status,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### 2. Domain Layer Refactoring

- Update use cases to follow clean architecture principles
- Implement proper error handling with Either type
- Add unit tests for all use cases

```dart
// Example of a use case
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}
```

### 3. Presentation Layer Refactoring

- Migrate from Provider to Riverpod for state management
- Implement proper state management with StateNotifier and AsyncValue
- Add proper loading and error states
- Add animations and transitions

```dart
// Example of a Riverpod provider
@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<User?> build() async {
    return _getCurrentUser();
  }

  Future<User?> _getCurrentUser() async {
    final result = await ref.read(authRepositoryProvider).getCurrentUser();
    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).signIn(email, password);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }
}
```

### 4. Testing

- Set up unit testing for all layers
- Set up widget testing for UI components
- Set up integration testing for key user flows
- Implement test coverage reporting

```dart
// Example of a unit test
void main() {
  late AuthRepository mockRepository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  test('should get current user from repository', () async {
    // Arrange
    final user = User(id: '1', email: 'test@example.com', username: 'test');
    when(mockRepository.getCurrentUser())
        .thenAnswer((_) async => Right(user));

    // Act
    final result = await useCase();

    // Assert
    expect(result, Right(user));
    verify(mockRepository.getCurrentUser());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### 5. Performance Optimization

- Implement proper memory management
- Optimize image loading and caching
- Reduce unnecessary rebuilds in the UI
- Add performance monitoring

### 6. Documentation

- Add proper documentation for all classes and methods
- Create architecture documentation
- Add usage examples

## How to Run the Refactored App

1. Make sure you have Flutter 3.29 or later installed
2. Run `flutter pub get` to install dependencies
3. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate code
4. Run `flutter run` to start the app

## Known Issues

- The app router requires generated code that needs to be created with build_runner
- Some placeholder pages need to be implemented
- Firebase configuration needs to be updated

## Resources

- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Hive Documentation](https://docs.hivedb.dev/)
