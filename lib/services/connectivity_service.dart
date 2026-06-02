// lib/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  static ConnectivityService get instance => _instance;

  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}

// Riverpod provider for connectivity
final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService.instance.onConnectivityChanged;
});

// Simple check provider
final isConnectedProvider = FutureProvider<bool>((ref) {
  return ConnectivityService.instance.isConnected;
});
