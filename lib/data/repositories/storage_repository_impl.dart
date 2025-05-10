import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../core/datasources/local/storage_local_data_source.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/typedefs.dart';
import '../../domain/repositories/storage_repository.dart';

/// Implementation of [StorageRepository] that uses Firebase Storage
class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl({
    required this.storageDataSource,
    required this.networkInfo,
  });
  final StorageLocalDataSource storageDataSource;
  final NetworkInfo networkInfo;

  @override
  ResultFuture<String> uploadImage(String path, Uint8List file,
      {required bool isPost}) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await storageDataSource.uploadImage(
          path,
          file,
          isPost: isPost,
        );
        return Right(imageUrl);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultVoid deleteImage(String url) async {
    if (await networkInfo.isConnected) {
      try {
        await storageDataSource.deleteImage(url);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
