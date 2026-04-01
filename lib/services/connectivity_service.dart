import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker();

  // Expose connectivity changes as a stream
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  // Check actual internet access
  Future<bool> get hasInternet async => await _internetChecker.hasConnection;
}
