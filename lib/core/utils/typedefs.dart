import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

// Define common return types for use cases and repositories
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = Future<Either<Failure, void>>;
typedef DataMap = Map<String, dynamic>;
