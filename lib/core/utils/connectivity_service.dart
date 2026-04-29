import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks the connectivity state of the device.
///
/// Exposed as a [ChangeNotifier] so the UI layer can rebuild the
/// "no internet" banner without subscribing directly to streams.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    final initial = await _connectivity.checkConnectivity();
    _setStatus(initial);

    _subscription = _connectivity.onConnectivityChanged.listen(_setStatus);
  }

  void _setStatus(List<ConnectivityResult> results) {
    final online = results.any(
      (r) =>
          r != ConnectivityResult.none &&
          r != ConnectivityResult.bluetooth, // bluetooth-only is "no internet"
    );
    if (online == _isOnline) return;
    _isOnline = online;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
