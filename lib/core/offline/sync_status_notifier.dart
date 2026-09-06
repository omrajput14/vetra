import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/network_status_service.dart';
import 'operation_queue.dart';
import 'sync_engine.dart';
import 'sync_service.dart';

/// Reactive notifier exposing real-time synchronization state to the UI.
class SyncStatusNotifier extends ChangeNotifier {
  SyncStatusNotifier._() {
    _init();
  }

  static final SyncStatusNotifier instance = SyncStatusNotifier._();

  final OperationQueue _queue = OperationQueue.instance;
  final NetworkStatusService _network = NetworkStatusService.instance;
  final SyncEngine _engine = SyncEngine.instance;

  int _pendingCount = 0;
  bool _isSyncing = false;
  bool _isOnline = false;

  int get pendingCount => _pendingCount;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  bool get hasPendingItems => _pendingCount > 0;

  StreamSubscription<int>? _queueSub;
  StreamSubscription<bool>? _networkSub;

  void _init() {
    _isOnline = _network.isBackendReachable;
    _isSyncing = _engine.isSyncing;

    // Listen to queue count changes
    _queueSub = _queue.watchPendingCount().listen((count) {
      _pendingCount = count;
      notifyListeners();
    });

    // Listen to network status changes
    _networkSub = _network.onConnectivityRestored.listen((reachable) {
      _isOnline = reachable;
      notifyListeners();
    });

    // Listen to sync engine state
    _engine.syncingNotifier.addListener(() {
      _isSyncing = _engine.syncingNotifier.value;
      notifyListeners();
    });

    // Initial check
    _refreshState();
  }

  Future<void> _refreshState() async {
    _isOnline = await _network.checkNow();
    notifyListeners();
  }

  /// Triggers a manual sync on demand (e.g. user taps "Sync Now").
  Future<void> syncNow() async {
    await SyncService.instance.triggerSync();
    await _refreshState();
  }

  @override
  void dispose() {
    _queueSub?.cancel();
    _networkSub?.cancel();
    super.dispose();
  }
}

final syncStatusNotifier = SyncStatusNotifier.instance;
