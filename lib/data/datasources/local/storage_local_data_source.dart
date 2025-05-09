import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/exceptions.dart';

abstract class StorageLocalDataSource {
  Future<String> uploadImage(String path, Uint8List file,
      {required bool isPost});
  Future<void> deleteImage(String url);
}

class StorageLocalDataSourceImpl implements StorageLocalDataSource {
  StorageLocalDataSourceImpl({
    required FirebaseStorage storage,
  }) : _storage = storage;
  final FirebaseStorage _storage;

  @override
  Future<void> deleteImage(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      log('Error deleting image: $e');
      throw ServerException(message: 'Failed to delete image: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadImage(String path, Uint8List file,
      {required bool isPost}) async {
    try {
      // Create a unique file name
      final fileName = isPost ? 'post_${const Uuid().v1()}' : const Uuid().v1();

      // Create a reference to the file location
      final ref = _storage.ref().child(path).child(fileName);

      // Upload the file
      final uploadTask = ref.putData(file);

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      throw ServerException(message: 'Failed to upload image: ${e.toString()}');
    }
  }
}
