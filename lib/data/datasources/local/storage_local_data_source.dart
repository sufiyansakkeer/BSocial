import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/datasources/local/storage_local_data_source.dart';

class StorageLocalDataSourceImpl implements StorageLocalDataSource {
  StorageLocalDataSourceImpl({required this.storage});

  final FirebaseStorage storage;

  @override
  Future<String> uploadImage(String path, Uint8List file,
      {required bool isPost}) async {
    try {
      final ref = storage.ref().child(path).child(isPost
          ? 'post_${DateTime.now().millisecondsSinceEpoch}'
          : DateTime.now().millisecondsSinceEpoch.toString());
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = ref.putData(file, metadata);

      // Await the task directly. If it fails, an exception will be thrown.
      await uploadTask;
      return await ref.getDownloadURL();
    } on FirebaseException catch (e, stackTrace) {
      developer.log('Error uploading image: $e',
          name: 'StorageLocalDataSourceImpl', error: e, stackTrace: stackTrace);
      // Re-throw the exception to allow higher-level error handling
      rethrow;
    } on Exception catch (e, stackTrace) {
      developer.log('An unexpected error occurred during image upload: $e',
          name: 'StorageLocalDataSourceImpl', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(String url) async {
    try {
      final ref = storage.refFromURL(url);
      await ref.delete();
    } on FirebaseException catch (e, stackTrace) {
      developer.log('Error deleting image: $e',
          name: 'StorageLocalDataSourceImpl', error: e, stackTrace: stackTrace);
      // Re-throw the exception to allow higher-level error handling
      rethrow;
    } on Exception catch (e, stackTrace) {
      developer.log('An unexpected error occurred during image deletion: $e',
          name: 'StorageLocalDataSourceImpl', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
