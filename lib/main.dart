import 'core/initialization/app_initializer.dart';
import 'core/services/logger_service.dart';

/// Global logger instance
final logger = LoggerService();

/// Application entry point
Future<void> main() async {
  // Create app initializer and start the app
  final appInitializer = AppInitializer(logger: logger);
  await appInitializer.initialize();

  // Note: The AppInitializer now handles creating and running the App
  // with all necessary providers including AuthBloc
}
