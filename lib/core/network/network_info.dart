import 'package:internet_connection_checker/internet_connection_checker.dart';

// Network information abstraction
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// Network information implementation
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({required this.connectionChecker});
  final InternetConnectionChecker connectionChecker;

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
