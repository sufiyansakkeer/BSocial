import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Interface for storage local data source
abstract class StorageLocalDataSource {
  /// Upload a file to storage
  Future<String> uploadFile(
    Uint8List file,
    String path,
    String name,
    String contentType,
  );

  /// Upload an image to storage
  Future<String> uploadImage(
    String path,
    Uint8List file, {
    required bool isPost,
  });

  /// Delete an image from storage
  Future<void> deleteImage(String url);
}

/// Implementation of [StorageLocalDataSource]
class StorageLocalDataSourceImpl implements StorageLocalDataSource {
  /// Constructor
  StorageLocalDataSourceImpl({required this.storage});

  /// Firebase storage
  final FirebaseStorage storage;

  @override
  Future<String> uploadFile(
      Uint8List file, String path, String name, String contentType) async {
    final ref = storage.ref().child(path).child(name);
    final metadata = SettableMetadata(contentType: contentType);
    final uploadTask =
        ref.putData(file, metadata); // Use the provided file data

    await uploadTask.whenComplete(() => null);
    return ref.getDownloadURL();
  }

  @override
  Future<String> uploadImage(
    String path,
    Uint8List file, {
    required bool isPost,
  }) async {
    // Generate a unique file name
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Upload the file
    return uploadFile(
      file,
      path,
      fileName,
      'image/jpeg',
    );
  }

  @override
  Future<void> deleteImage(String url) async {
    try {
      final ref = storage.refFromURL(url);
      await ref.delete();
    } on Exception catch (e) {
      log('Error deleting image: $e');
      // Handle error appropriately, e.g., log it or throw a custom exception
    }
  }
}
