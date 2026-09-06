import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/network_status_service.dart';
import 'sync_engine.dart';

/// Application-level synchronization coordinator.
///
/// Triggers sync execution under 4 scenarios (per approved MVP Option A):
/// 1. App Startup (after DB init & network readiness)
/// 2. App Foreground Resume (via lifecycle listener)
/// 3. Network Restored (when [NetworkStatusService] emits true)
/// 4. Manual "Sync Now" user action from UI
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final SyncEngine _engine = SyncEngine.instance;
  final NetworkStatusService _network = NetworkStatusService.instance;

  StreamSubscription<bool>? _networkSub;
  bool _initialized = false;

  /// Initializes automatic listeners. Call in [main] after [NetworkStatusService.initialize].
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Trigger on connectivity restoration
    _networkSub = _network.onConnectivityRestored.listen((restored) {
      if (restored) {
        debugPrint('[SyncService] Connectivity restored event received — triggering sync.');
        triggerSync();
      }
    });

    // Run initial sync on startup in background
    triggerSync();
    debugPrint('[SyncService] Initialized.');
  }

  /// Triggers a synchronization cycle. Safe to call concurrently.
  Future<void> triggerSync() async {
    await _engine.runSync();
  }

  void dispose() {
    _networkSub?.cancel();
  }
}
