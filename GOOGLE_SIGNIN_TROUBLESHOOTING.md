# Google Sign-In Troubleshooting Guide

## Common Errors

### Error 1: PlatformException(network_error, com.google.android.gms.common.api.ApiException: 7: , null, null)

This error typically indicates a network-related issue with Google Sign-In. Error code 7 specifically refers to a network error that occurred during the sign-in process.

### Error 2: Unsupported operation: Cannot add to an unmodifiable list

This error occurs when trying to modify the scopes of a GoogleSignIn instance after it has been created. The scopes list is unmodifiable and must be set during initialization.

## Troubleshooting Steps

### 1. Check Internet Connection

- Ensure your device has a stable internet connection
- Try switching between Wi-Fi and mobile data
- Reset your network connection by toggling airplane mode

### 2. Update Google Play Services

The error might be caused by outdated Google Play Services on your device:

1. Open Google Play Store
2. Search for "Google Play Services"
3. Update to the latest version
4. Also update "Google" app if available

### 3. Check SHA-1 Certificate Fingerprint

Ensure the correct SHA-1 fingerprint is registered in Firebase console:

1. Generate your SHA-1 fingerprint:

   ```
   cd android
   ./gradlew signingReport
   ```

2. Look for the debug or release certificate fingerprint in the output
3. Go to Firebase Console > Project Settings > Your Apps > Android App
4. Add the SHA-1 fingerprint if it's missing or incorrect

### 4. Check Google Sign-In Configuration

1. Verify that your `google-services.json` file is up-to-date and properly placed in the `android/app` directory
2. Make sure the package name in Firebase console matches your app's package name
3. Ensure OAuth client ID is properly configured in Firebase console

### 5. Clear Google Play Services Cache

1. Go to Settings > Apps > Google Play Services
2. Tap Storage > Clear Cache
3. Do the same for Google Play Store app

### 6. Check Date and Time Settings

1. Ensure your device's date and time are set correctly
2. Enable automatic date and time if possible

### 7. Test on Different Devices

If possible, test Google Sign-In on different devices to determine if the issue is device-specific.

### 8. Verify Web Client ID

If you're using web client ID for Google Sign-In:

1. Make sure the web client ID in your code matches the one in Firebase console
2. Verify that the web client ID is properly configured for OAuth

### 9. Check Logcat for Detailed Errors

Connect your device to a computer and check the Android logs for more detailed error information:

```
adb logcat | grep -E "GoogleSignIn|Auth|ApiException"
```

### 10. Verify Google Sign-In Scopes

Make sure you're requesting the appropriate scopes during initialization:

```dart
// CORRECT: Set scopes during initialization
final googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);

// INCORRECT: Don't try to modify scopes after initialization
// This will cause "Cannot add to an unmodifiable list" error
googleSignIn.scopes.addAll(['email', 'profile']); // Will fail!
```

## Advanced Troubleshooting

### Debugging Network Issues

If the error persists, it might be related to network restrictions:

1. Check if your network has any firewalls blocking Google authentication
2. Try using a different network (e.g., mobile data instead of Wi-Fi)
3. Check if your device has any VPN or proxy settings that might interfere

### Debugging Firebase Configuration

1. Regenerate the `google-services.json` file from Firebase console
2. Make sure you're using the latest version of Firebase and Google Sign-In plugins
3. Check for any conflicting dependencies in your `pubspec.yaml`

### Debugging SHA Certificate Issues

If you're using a different build variant or signing configuration:

1. Generate SHA-1 for debug, release, and any other build variants you use
2. Add all SHA-1 fingerprints to Firebase console
3. If using CI/CD, ensure the build environment has the correct keystore

## Next Steps

If you've tried all these steps and still encounter the error:

1. Check the Flutter and Firebase issue trackers for similar issues
2. Consider implementing an alternative authentication method as a fallback
3. Reach out to Firebase support with detailed logs and reproduction steps
