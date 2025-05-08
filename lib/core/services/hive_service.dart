import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/hive/chat_room_hive_model.dart';
import '../../data/models/hive/comment_hive_model.dart';
import '../../data/models/hive/message_hive_model.dart';
import '../../data/models/hive/post_hive_model.dart';
import '../../data/models/hive/user_hive_model.dart';

class HiveService {
  static bool _isInitialized = false;

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    if (_isInitialized) {
      log('Hive is already initialized');
      return;
    }

    try {
      // Initialize Hive
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);

      // Register adapters
      Hive.registerAdapter(UserHiveModelAdapter());
      Hive.registerAdapter(PostHiveModelAdapter());
      Hive.registerAdapter(CommentHiveModelAdapter());
      Hive.registerAdapter(ChatRoomHiveModelAdapter());
      Hive.registerAdapter(MessageHiveModelAdapter());

      _isInitialized = true;
      log('Hive initialized successfully');
    } catch (e) {
      log('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Close all Hive boxes
  static Future<void> close() async {
    try {
      await Hive.close();
      _isInitialized = false;
      log('Hive closed successfully');
    } catch (e) {
      log('Error closing Hive: $e');
      rethrow;
    }
  }

  /// Check if Hive is initialized
  static bool get isInitialized => _isInitialized;
}
