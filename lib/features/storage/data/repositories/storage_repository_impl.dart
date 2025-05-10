import 'dart:typed_data';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/local/storage_local_data_source.dart';

/// Implementation of [StorageRepository]
class StorageRepositoryImpl implements StorageRepository {
  /// Constructor
  StorageRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  /// Storage data source
  final StorageLocalDataSource dataSource;

  /// Network info
  final NetworkInfo networkInfo;

  @override
  ResultVoid deleteImage(String url) async {
    if (await networkInfo.isConnected) {
      try {
        await dataSource.deleteImage(url);
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

  @override
  ResultFuture<String> uploadImage(
    String path,
    Uint8List file, {
    required bool isPost,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await dataSource.uploadImage(
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
}
