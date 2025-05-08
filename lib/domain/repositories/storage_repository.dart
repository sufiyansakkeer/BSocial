import 'dart:typed_data';
import '../../core/utils/typedefs.dart';

// Storage repository interface
abstract class StorageRepository {
  // Upload an image to storage
  ResultFuture<String> uploadImage(String path, Uint8List file, bool isPost);

  // Delete an image from storage
  ResultVoid deleteImage(String url);
}
