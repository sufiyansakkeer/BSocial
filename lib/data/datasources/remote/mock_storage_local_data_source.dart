import 'dart:typed_data';
import '../../../core/errors/exceptions.dart';
import '../local/storage_local_data_source.dart';

/// Mock implementation of [StorageLocalDataSource] for offline mode
class MockStorageLocalDataSource implements StorageLocalDataSource {
  @override
  Future<void> deleteImage(String url) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<String> uploadImage(String path, Uint8List file,
      {required bool isPost}) async {
    // Return a mock URL or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }
}
