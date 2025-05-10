import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/datasources/local/storage_local_data_source.dart';

class StorageLocalDataSourceImpl implements StorageLocalDataSource {
  StorageLocalDataSourceImpl({required this.storage});

  final FirebaseStorage storage;

  @override
  Future<String> uploadImage(String path, Uint8List file,
      {required bool isPost}) async {
    final ref = storage.ref().child(path).child(isPost
        ? 'post_${DateTime.now().millisecondsSinceEpoch}'
        : DateTime.now().millisecondsSinceEpoch.toString());
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final uploadTask = ref.putData(file, metadata);

    await uploadTask.whenComplete(() => null);
    return ref.getDownloadURL();
  }

  @override
  Future<void> deleteImage(String url) async {
    try {
      final ref = storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Handle error appropriately, e.g., log it or throw a custom exception
    }
  }
}
