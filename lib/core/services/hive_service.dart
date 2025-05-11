import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
// Import models from their current locations
// We're using the old models since the refactoring is not complete
import '../../data/models/hive/chat_room_hive_model.dart'; // This might need to be updated if ChatRoomHiveModel was also duplicated
import '../../data/models/hive/comment_hive_model.dart'; // This might need to be updated if CommentHiveModel was also duplicated
import '../../features/chat/data/models/hive/message_hive_model.dart'; // Corrected import
import '../../data/models/hive/post_hive_model.dart'; // This might need to be updated if PostHiveModel was also duplicated
import '../../data/models/hive/user_hive_model.dart'; // This might need to be updated if UserHiveModel was also duplicated

/// Utility for Hive database operations
class HiveService {
  HiveService._(); // Private constructor to prevent instantiation

  static bool _isInitialized = false;

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    try {
      // Close Hive if it's already initialized
      if (_isInitialized) {
        log('Hive is already initialized, closing it first', name: 'init');
        await Hive.close();
        _isInitialized = false;
      }

      // Initialize Hive
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);

      // Register adapters
      try {
        // Register adapters in a specific order
        Hive
          ..registerAdapter(UserHiveModelAdapter())
          ..registerAdapter(PostHiveModelAdapter())
          ..registerAdapter(ChatRoomHiveModelAdapter())
          ..registerAdapter(MessageHiveModelAdapter())
          ..registerAdapter(CommentHiveModelAdapter());
      } on Exception catch (e) {
        log('Error registering adapters: $e', name: 'init');
        // Continue even if adapter registration fails
      }

      _isInitialized = true;
      log('Hive initialized successfully', name: 'init');
    } catch (e) {
      log('Error initializing Hive: $e', name: 'init');
      rethrow;
    }
  }

  /// Delete all Hive boxes
  static Future<void> _deleteAllBoxes() async {
    try {
      final boxNames = ['users', 'posts', 'comments', 'chatRooms', 'messages'];

      for (final boxName in boxNames) {
        try {
          if (await Hive.boxExists(boxName)) {
            await Hive.deleteBoxFromDisk(boxName);
            log('Deleted box: $boxName', name: '_deleteAllBoxes');
          }
        } on Exception catch (e) {
          log('Error deleting box $boxName: $e', name: '_deleteAllBoxes');
          // Continue with other boxes
        }
      }
    } on Exception catch (e) {
      log('Error deleting boxes: $e', name: '_deleteAllBoxes');
    }
  }

  /// Close all Hive boxes
  static Future<void> close() async {
    try {
      await Hive.close();
      _isInitialized = false;
      log('Hive closed successfully', name: 'close');
    } catch (e) {
      log('Error closing Hive: $e', name: 'close');
      rethrow;
    }
  }

  /// Reset Hive by deleting all boxes and reinitializing
  static Future<void> reset() async {
    try {
      // Close all boxes first
      await Hive.close();
      _isInitialized = false;

      // Reinitialize Hive (this will register adapters)
      await init();

      // Now that Hive is initialized, we can safely delete boxes
      try {
        await _deleteAllBoxes();
      } on Exception catch (e) {
        log('Error deleting boxes during reset: $e', name: 'reset');
        // Continue even if box deletion fails
      }

      log('Hive reset successfully', name: 'reset');
    } on Exception catch (e) {
      log('Error resetting Hive: $e', name: 'reset');
      rethrow;
    }
  }

  /// Check if Hive is initialized
  static bool get isInitialized => _isInitialized;
}
