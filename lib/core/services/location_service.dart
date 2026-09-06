import "dart:async";
import "../../features/appointment/data/api/appointment_api_service.dart";
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationResult {
  final double latitude;
  final double longitude;

  const UserLocationResult({
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Determines whether location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('LocationService: error checking service status: $e');
      return false;
    }
  }

  /// Requests location permission with graceful fallback.
  Future<LocationPermission> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    } catch (e) {
      debugPrint('LocationService: error requesting permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Fetches the device's current GPS location with a strict timeout to avoid blocking.
  Future<UserLocationResult?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      } else if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: timeout,
        ),
      );

      return UserLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('LocationService: error fetching position: $e');
      return null;
    }
  }

  Timer? _enRouteTimer;
  String? _activeEnRouteAppointmentId;

  bool get isTrackingEnRoute => _enRouteTimer != null;
  String? get activeEnRouteAppointmentId => _activeEnRouteAppointmentId;

  /// Starts foreground periodic location streaming to backend during active EN_ROUTE state.
  void startEnRouteTracking(String appointmentId, {Duration interval = const Duration(seconds: 15)}) {
    stopEnRouteTracking();
    _activeEnRouteAppointmentId = appointmentId;
    _pushCurrentLocation(appointmentId);
    _enRouteTimer = Timer.periodic(interval, (_) {
      _pushCurrentLocation(appointmentId);
    });
    debugPrint("[LocationService] Started en-route location tracking for appointment $appointmentId");
  }

  /// Terminates live location streaming when arrival is marked or screen is exited.
  void stopEnRouteTracking() {
    if (_enRouteTimer != null) {
      _enRouteTimer!.cancel();
      _enRouteTimer = null;
    }
    _activeEnRouteAppointmentId = null;
    debugPrint("[LocationService] Stopped en-route location tracking");
  }

  Future<void> _pushCurrentLocation(String appointmentId) async {
    try {
      final loc = await getCurrentLocation(timeout: const Duration(seconds: 5));
      if (loc != null) {
        final api = AppointmentApiService();
        await api.updateLocation(appointmentId, loc.latitude, loc.longitude);
        debugPrint("[LocationService] Successfully streamed en-route GPS ($loc.latitude, $loc.longitude)");
      }
    } catch (e) {
      debugPrint("[LocationService] Could not stream en-route coordinates: $e");
    }
  }
}
