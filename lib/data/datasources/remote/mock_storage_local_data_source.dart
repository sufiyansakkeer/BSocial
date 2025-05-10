import 'dart:typed_data';

import '../../../core/datasources/local/storage_local_data_source.dart';
import '../../../core/errors/exceptions.dart';

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

  @override
  Future<String> uploadFile(
      Uint8List file, String path, String name, String contentType) async {
    // Return a mock URL or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }
}
