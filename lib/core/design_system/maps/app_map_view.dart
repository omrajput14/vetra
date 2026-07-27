import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';

enum MapLayer {
  nearbyVets,
  diseaseHotspots,
  riskRadius,
  appointmentLocation,
  emergencyNavigation,
}

class AppMapView extends StatefulWidget {
  final MapLayer initialLayer;
  final String title;
  final VoidCallback? onMarkerTap;

  const AppMapView({
    super.key,
    this.initialLayer = MapLayer.diseaseHotspots,
    required this.title,
    this.onMarkerTap,
  });

  @override
  State<AppMapView> createState() => _AppMapViewState();
}

class _AppMapViewState extends State<AppMapView> {
  late MapLayer _activeLayer;

  @override
  void initState() {
    super.initState();
    _activeLayer = widget.initialLayer;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getLayerIcon(_activeLayer),
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(widget.title, style: AppTypography.cardTitle),
                Text('Layer: ${_getLayerName(_activeLayer)} (PostGIS spatial ready)', style: AppTypography.captionMetadata),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: DropdownButton<MapLayer>(
                value: _activeLayer,
                isDense: true,
                underline: const SizedBox(),
                items: MapLayer.values.map((layer) {
                  return DropdownMenuItem(
                    value: layer,
                    child: Text(_getLayerName(layer), style: AppTypography.captionMetadata),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _activeLayer = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLayerIcon(MapLayer layer) {
    switch (layer) {
      case MapLayer.nearbyVets: return Icons.medical_services;
      case MapLayer.diseaseHotspots: return Icons.warning_amber;
      case MapLayer.riskRadius: return Icons.radar;
      case MapLayer.appointmentLocation: return Icons.location_on;
      case MapLayer.emergencyNavigation: return Icons.navigation;
    }
  }

  String _getLayerName(MapLayer layer) {
    switch (layer) {
      case MapLayer.nearbyVets: return 'Nearby Vets';
      case MapLayer.diseaseHotspots: return 'Outbreak Hotspots';
      case MapLayer.riskRadius: return 'Risk Radius';
      case MapLayer.appointmentLocation: return 'Appt Location';
      case MapLayer.emergencyNavigation: return 'Emergency Route';
    }
  }
}
