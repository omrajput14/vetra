import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';

import '../../../../core/localization/locale_provider.dart';
import '../../../disease/data/models/outbreak_dto.dart';
import '../../../disease/presentation/providers/outbreak_provider.dart';

class OutbreakMapPage extends ConsumerStatefulWidget {
  const OutbreakMapPage({super.key});

  @override
  ConsumerState<OutbreakMapPage> createState() => _OutbreakMapPageState();
}

class _OutbreakMapPageState extends ConsumerState<OutbreakMapPage> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await outbreakNotifier.fetchUserLocation();
      await outbreakNotifier.loadOutbreaks();
      _fitMapToOutbreaks();
    });
  }

  void _fitMapToOutbreaks() {
    final outbreaks = outbreakNotifier.outbreaks;
    if (outbreaks.isNotEmpty) {
      final points = outbreaks
          .map((o) => LatLng(o.centerLatitude, o.centerLongitude))
          .toList();
      if (outbreakNotifier.userLocation != null) {
        points.add(LatLng(
          outbreakNotifier.userLocation!.latitude,
          outbreakNotifier.userLocation!.longitude,
        ));
      }
      if (points.length == 1) {
        _mapController.move(points.first, 11.0);
      } else {
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(40),
          ),
        );
      }
    } else if (outbreakNotifier.userLocation != null) {
      _mapController.move(
        LatLng(
          outbreakNotifier.userLocation!.latitude,
          outbreakNotifier.userLocation!.longitude,
        ),
        12.0,
      );
    }
  }

  Color _getRiskColor(String riskScore) {
    switch (riskScore.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.alertCritical;
      case 'HIGH':
        return const Color(0xFFE65100);
      case 'MEDIUM':
        return AppColors.cautionAmber;
      case 'LOW':
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = ref.watch(localeProvider);
    final lang = activeLocale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang == 'mr'
                  ? 'परिसरातील रोग प्रादुर्भाव'
                  : (lang == 'hi' ? 'क्षेत्रीय रोग प्रकोप' : 'Nearby Outbreak Alerts'),
              style: AppTypography.screenTitle.copyWith(fontSize: 18),
            ),
            Text(
              lang == 'mr'
                  ? 'पशुधन आरोग्य सुरक्षा व प्रतिबंध'
                  : (lang == 'hi' ? 'पशु स्वास्थ्य सुरक्षा एवं रोकथाम' : 'Livestock Health Protection & Early Warning'),
              style: AppTypography.captionMetadata.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
            onPressed: () => outbreakNotifier.loadOutbreaks(refresh: true),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: outbreakNotifier,
        builder: (context, _) {
          final outbreaks = outbreakNotifier.outbreaks;
          final userLoc = outbreakNotifier.userLocation;
          final isLoading = outbreakNotifier.isLoading;

          final initialCenter = userLoc != null
              ? LatLng(userLoc.latitude, userLoc.longitude)
              : (outbreaks.isNotEmpty
                  ? LatLng(outbreaks.first.centerLatitude, outbreaks.first.centerLongitude)
                  : const LatLng(18.5204, 73.8567));

          return Stack(
            children: [
              // 1. OpenStreetMap Canvas
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 10.5,
                  minZoom: 4.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'app.vetra.livestock',
                  ),

                  // Outbreak Containment Circles
                  CircleLayer(
                    circles: outbreaks.map((o) {
                      final color = _getRiskColor(o.riskScore);
                      return CircleMarker(
                        point: LatLng(o.centerLatitude, o.centerLongitude),
                        radius: o.radiusKm * 1000,
                        useRadiusInMeter: true,
                        color: color.withValues(alpha: 0.15),
                        borderColor: color,
                        borderStrokeWidth: 2.0,
                      );
                    }).toList(),
                  ),

                  // Cluster Center Markers
                  MarkerLayer(
                    markers: outbreaks.map((o) {
                      final color = _getRiskColor(o.riskScore);
                      return Marker(
                        point: LatLng(o.centerLatitude, o.centerLongitude),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _showFarmerOutbreakModal(o, lang),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.warning_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Farmer My Farm GPS Location
                  if (userLoc != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(userLoc.latitude, userLoc.longitude),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.home, size: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // 2. Top Alert Banner
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: _buildFarmerAlertBanner(outbreaks, lang),
              ),

              // 3. Floating Map Controls
              Positioned(
                bottom: 80,
                right: 14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location_rounded, color: AppColors.primary),
                        tooltip: 'My Farm Location',
                        onPressed: () {
                          if (userLoc != null) {
                            _mapController.move(LatLng(userLoc.latitude, userLoc.longitude), 12.0);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.zoom_out_map_rounded, color: AppColors.primary),
                        tooltip: 'Fit Zones',
                        onPressed: _fitMapToOutbreaks,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Bottom Action Card
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_alert_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              lang == 'mr'
                                  ? 'लक्षणे दिसून आल्यास कळवा'
                                  : (lang == 'hi' ? 'लक्षण दिखने पर सूचित करें' : 'Notice any symptoms?'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              lang == 'mr'
                                  ? 'प्रादुर्भाव रोखण्यासाठी त्वरित नोंद करा'
                                  : (lang == 'hi' ? 'प्रकोप रोकने हेतु तुरंत रिपोर्ट करें' : 'File a quick health report'),
                              style: AppTypography.captionMetadata.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () => context.push('/report-disease'),
                        child: Text(
                          lang == 'mr' ? 'नोंदवा' : (lang == 'hi' ? 'रिपोर्ट' : 'Report'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isLoading && outbreaks.isEmpty)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: FarmerBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) context.go('/farmer-dashboard');
          if (index == 1) context.go('/my-animals');
          if (index == 2) context.go('/alerts');
          if (index == 3) context.go('/outbreak-map');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }

  Widget _buildFarmerAlertBanner(List<OutbreakModel> outbreaks, String lang) {
    final hasOutbreak = outbreaks.isNotEmpty;
    final primaryOutbreak = hasOutbreak ? outbreaks.first : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasOutbreak
            ? AppColors.alertCritical.withValues(alpha: 0.95)
            : AppColors.primary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Icon(
            hasOutbreak ? Icons.crisis_alert_rounded : Icons.verified_user_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasOutbreak
                      ? (lang == 'mr'
                          ? 'सावधान: ${primaryOutbreak?.diseaseName} प्रादुर्भाव'
                          : (lang == 'hi'
                              ? 'सावधान: ${primaryOutbreak?.diseaseName} प्रकोप'
                              : 'Alert: Active ${primaryOutbreak?.diseaseName} Zone'))
                      : (lang == 'mr'
                          ? 'परिसर सुरक्षित आहे'
                          : (lang == 'hi' ? 'क्षेत्र सुरक्षित है' : 'Surveillance Active: Sector Safe')),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  hasOutbreak
                      ? (lang == 'mr'
                          ? '${primaryOutbreak?.radiusKm.toStringAsFixed(1)} किमी जैविक नियंत्रण क्षेत्र सक्रिय'
                          : (lang == 'hi'
                              ? '${primaryOutbreak?.radiusKm.toStringAsFixed(1)} किमी बायो-कंटेनमेंट ज़ोन सक्रिय'
                              : '${primaryOutbreak?.radiusKm.toStringAsFixed(1)} km Bio-containment Zone Active'))
                      : (lang == 'mr'
                          ? 'सध्या तुमच्या क्षेत्रात कोणताही गंभीर प्रादुर्भाव नाही.'
                          : (lang == 'hi'
                              ? 'वर्तमान में आपके क्षेत्र में कोई प्रकोप नहीं है।'
                              : 'No immediate outbreaks reported in your herd sector.')),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFarmerOutbreakModal(OutbreakModel outbreak, String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.alertCritical, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      outbreak.diseaseName,
                      style: AppTypography.cardTitle.copyWith(fontSize: 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                lang == 'mr'
                    ? 'या क्षेत्रात ${outbreak.affectedReportsCount} बाधित नोंदी आढळल्या आहेत. सावधगिरी बाळगा.'
                    : (lang == 'hi'
                        ? 'इस क्षेत्र में ${outbreak.affectedReportsCount} प्रभावित मामले दर्ज हैं। सावधानी बरतें।'
                        : '${outbreak.affectedReportsCount} affected cases registered in this ${outbreak.radiusKm.toStringAsFixed(1)} km quarantine perimeter.'),
                style: AppTypography.captionMetadata,
              ),
              const Divider(height: 24),
              Text(
                lang == 'mr' ? 'शेतकऱ्यांसाठी आवश्यक सूचना:' : (lang == 'hi' ? 'पशुपालकों हेतु निर्देश:' : 'Farmer Safety Precautions:'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              _buildFarmerTip(
                lang == 'mr'
                    ? 'बाधित प्राण्यांना तात्काळ निरोगी जनावरांपासून वेगळे ठेवा.'
                    : (lang == 'hi' ? 'बीमार पशुओं को तुरंत स्वस्थ पशुओं से अलग रखें।' : 'Isolate suspected animals immediately.'),
              ),
              _buildFarmerTip(
                lang == 'mr'
                    ? 'परिसरातील जनावरांचा बाजार किंवा सार्वजनिक चरण्यावर बंदी ठेवा.'
                    : (lang == 'hi' ? 'साझा चराई और पशु हाट से बचें।' : 'Avoid shared grazing pastures and local animal fairs.'),
              ),
              _buildFarmerTip(
                lang == 'mr'
                    ? 'पशुवैद्यकीय अधिकाऱ्यांशी संपर्क साधून लसीकरण पूर्ण करा.'
                    : (lang == 'hi' ? 'पशु चिकित्सक से परामर्श कर टीकाकरण करवाएं।' : 'Consult local veterinarian for emergency vaccination.'),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: lang == 'mr' ? 'समजले / बंद करा' : (lang == 'hi' ? 'समझ गया' : 'Dismiss'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFarmerTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTypography.bodyDefault.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
