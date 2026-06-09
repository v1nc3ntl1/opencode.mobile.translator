import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityMonitor {
  static final ConnectivityMonitor _instance = ConnectivityMonitor._internal();
  factory ConnectivityMonitor() => _instance;
  ConnectivityMonitor._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    _isOnline = results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
    _controller.add(_isOnline);
  }

  Future<void> refresh() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
  }

  void dispose() {
    _controller.close();
  }
}
