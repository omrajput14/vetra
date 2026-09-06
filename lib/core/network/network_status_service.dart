import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Network status service that combines [connectivity_plus] change detection
/// with a real HTTP health check against the Spring Boot backend.
///
/// Design decisions (per architecture spec):
/// • [connectivity_plus] is used ONLY as a trigger — not as the source of truth.
/// • Before declaring the backend reachable, a lightweight GET /actuator/health
///   request is performed. Only HTTP 200 counts as "reachable".
/// • Sync MUST NOT start until [isBackendReachable] is confirmed true.
///
/// Reachability endpoint: GET /actuator/health
/// This endpoint is in [PUBLIC_ENDPOINTS] in Spring SecurityConfig — no JWT needed.
class NetworkStatusService {
  NetworkStatusService._();

  static final NetworkStatusService instance = NetworkStatusService._();

  // ─── State ─────────────────────────────────────────────────────────────────

  bool _isBackendReachable = false;
  bool get isBackendReachable => _isBackendReachable;

  // ─── Stream: backend connectivity restored ─────────────────────────────────

  final _controller = StreamController<bool>.broadcast();

  /// Emits `true` each time the backend transitions from unreachable → reachable.
  /// Used by [SyncService] to trigger a sync run.
  Stream<bool> get onConnectivityRestored => _controller.stream;

  // ─── Internal ──────────────────────────────────────────────────────────────

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _initialized = false;

  // Dedicated lightweight Dio instance — not the main ApiClient.
  // No auth headers, no retry interceptors — just a raw health ping.
  final _pingDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
  ));

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  /// Must be called once during app startup (in [main]).
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (e) => debugPrint('[NetworkStatusService] Connectivity stream error: $e'),
    );

    debugPrint('[NetworkStatusService] Initialized.');
  }

  void dispose() {
    _connectivitySub?.cancel();
    _controller.close();
  }

  // ─── Connectivity change handler ───────────────────────────────────────────

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final hasConnectivity = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);

    if (!hasConnectivity) {
      debugPrint('[NetworkStatusService] No network connectivity detected.');
      _isBackendReachable = false;
      return;
    }

    // Connectivity layer is up — now verify the actual backend is reachable.
    debugPrint('[NetworkStatusService] Connectivity restored — pinging backend...');
    final reachable = await _verifyBackendReachability();

    if (reachable && !_isBackendReachable) {
      // Transition: unreachable → reachable
      _isBackendReachable = true;
      _controller.add(true);
      debugPrint('[NetworkStatusService] Backend reachable — notifying listeners.');
    } else if (!reachable) {
      _isBackendReachable = false;
      debugPrint('[NetworkStatusService] Backend not reachable despite connectivity.');
    }
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Performs an immediate backend reachability check.
  ///
  /// Returns `true` if the Spring Boot /actuator/health endpoint responds HTTP 200.
  /// This is the ONLY method that should gate sync engine activation.
  Future<bool> checkNow() async {
    final reachable = await _verifyBackendReachability();
    _isBackendReachable = reachable;
    return reachable;
  }

  // ─── Internal: real health check ───────────────────────────────────────────

  Future<bool> _verifyBackendReachability() async {
    try {
      final url = '${AppConfig.baseUrl}/actuator/health';
      final response = await _pingDio.get<Map<String, dynamic>>(url);
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('[NetworkStatusService] Health ping failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[NetworkStatusService] Health ping unexpected error: $e');
      return false;
    }
  }
}
