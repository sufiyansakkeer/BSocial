import 'dart:typed_data';

import '../../../../core/utils/typedefs.dart';

/// Interface for storage repository
abstract class StorageRepository {
  /// Upload an image to storage
  ResultFuture<String> uploadImage(String path, Uint8List file,
      {required bool isPost});

  /// Delete an image from storage
  ResultVoid deleteImage(String url);
}
