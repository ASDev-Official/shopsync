import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shopsync/widgets/common/offline_dialog.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isOnline = true;
  bool _isInitialized = false;
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  // Getters
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isInitialized => _isInitialized;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResult);

      // Listen for connectivity changes
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus)
              as StreamSubscription<ConnectivityResult>?;

      _isInitialized = true;
    } catch (e) {
      // If connectivity_plus fails, assume we're online and mark as initialized
      if (kDebugMode) {
        print('ConnectivityService initialization failed: $e');
      }
      _isOnline = true;
      _isInitialized = true;
      _connectionStatusController.add(_isOnline);
    }
  }

  // Update connection status
  void _updateConnectionStatus(dynamic connectivityResult) {
    try {
      final bool wasOnline = _isOnline;

      // Handle both single ConnectivityResult and List<ConnectivityResult>
      if (connectivityResult is List<ConnectivityResult>) {
        _isOnline = connectivityResult.any((result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet);
      } else if (connectivityResult is ConnectivityResult) {
        _isOnline = connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.ethernet;
      }

      if (wasOnline != _isOnline) {
        _connectionStatusController.add(_isOnline);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating connection status: $e');
      }
      // Fallback to assuming online if we can't check
      _isOnline = true;
      _connectionStatusController.add(_isOnline);
    }
  }

  // Check connectivity with fallback
  Future<bool> checkConnectivity() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResult);
      return _isOnline;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      // Fallback: assume online if we can't check
      return true;
    }
  }

  // Show offline dialog if not connected
  Future<bool> checkConnectivityAndShowDialog(BuildContext context,
      {String? feature}) async {
    final bool isConnected = await checkConnectivity();

    if (!isConnected) {
      showOfflineDialog(context, feature: feature);
      return false;
    }
    return true;
  }

  // Show offline dialog
  void showOfflineDialog(BuildContext context, {String? feature}) {
    OfflineDialog.show(context, feature ?? 'this feature');
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
