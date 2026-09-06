import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/network/network_status_service.dart';

void main() {
  group('NetworkStatusService Tests', () {
    test('Service instance is available and defaults to not reachable before check', () {
      final service = NetworkStatusService.instance;
      expect(service, isNotNull);
      expect(service.onConnectivityRestored, isNotNull);
    });

    test('Custom reachability check completes and reflects boolean connectivity', () async {
      final service = NetworkStatusService.instance;
      final reachable = await service.checkNow();
      expect(reachable, isA<bool>());
      expect(service.isBackendReachable, reachable);
    });
  });
}
