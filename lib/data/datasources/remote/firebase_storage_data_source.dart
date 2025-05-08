import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Interface for storage data source
abstract class StorageDataSource {
  /// Upload file to storage
  Future<String> uploadFile(String path, Uint8List file);

  /// Delete file from storage
  Future<void> deleteFile(String url);
}

/// Firebase implementation of storage data source
class FirebaseStorageDataSourceImpl implements StorageDataSource {
  /// Constructor
  FirebaseStorageDataSourceImpl({
    required FirebaseStorage storage,
  }) : _storage = storage;
  final FirebaseStorage _storage;

  @override
  Future<String> uploadFile(String path, Uint8List file) async {
    // Create a unique file name
    final fileName = const Uuid().v1();
    final ref = _storage.ref().child(path).child(fileName);

    // Upload file
    final uploadTask = ref.putData(file);
    final snapshot = await uploadTask;

    // Get download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Future<void> deleteFile(String url) async {
    try {
      // Extract file path from URL
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
