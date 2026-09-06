import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../disease/data/models/disease_report_dto.dart';
import '../../../disease/data/models/outbreak_dto.dart';
import '../../../disease/presentation/providers/outbreak_provider.dart';

class VetOutbreakMapPage extends ConsumerStatefulWidget {
  const VetOutbreakMapPage({super.key});

  @override
  ConsumerState<VetOutbreakMapPage> createState() => _VetOutbreakMapPageState();
}

class _VetOutbreakMapPageState extends ConsumerState<VetOutbreakMapPage> {
  final MapController _mapController = MapController();
  bool _showCasesLayer = true;

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
    final outbreaks = outbreakNotifier.filteredOutbreaks;
    if (outbreaks.isNotEmpty) {
      if (outbreaks.length == 1) {
        _mapController.move(
          LatLng(outbreaks.first.centerLatitude, outbreaks.first.centerLongitude),
          11.5,
        );
      } else {
        final points = outbreaks
            .map((o) => LatLng(o.centerLatitude, o.centerLongitude))
            .toList();
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50),
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

  Color _getRiskFillColor(String riskScore) {
    return _getRiskColor(riskScore).withValues(alpha: 0.15);
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
                  ? 'रोग प्रादुर्भाव सर्वेक्षण नकाशा'
                  : (lang == 'hi' ? 'रोग प्रकोप निगरानी मानचित्र' : 'Outbreak Surveillance Map'),
              style: AppTypography.screenTitle.copyWith(fontSize: 18),
            ),
            Text(
              lang == 'mr'
                  ? 'रिअल-टाइम साथरोग नियंत्रण व विश्लेषण'
                  : (lang == 'hi' ? 'वास्तविक समय रोग प्रकोप नियंत्रण' : 'Real-time Epidemiological GIS Intelligence'),
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
            tooltip: 'Refresh Surveillance Data',
            onPressed: () => outbreakNotifier.loadOutbreaks(refresh: true),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: outbreakNotifier,
        builder: (context, _) {
          final isLoading = outbreakNotifier.isLoading;
          final errorMessage = outbreakNotifier.errorMessage;
          final outbreaks = outbreakNotifier.filteredOutbreaks;
          final stats = outbreakNotifier.statistics;

          if (isLoading && outbreaks.isEmpty) {
            return _buildLoadingState(lang);
          }

          if (errorMessage != null && outbreaks.isEmpty) {
            return _buildErrorState(errorMessage, lang);
          }

          return Stack(
            children: [
              // 1. OpenStreetMap Canvas Layer
              _buildMap(outbreaks),

              // 2. Top Metric & Filter Bar
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Column(
                  children: [
                    if (stats != null) _buildMetricsSummaryBar(stats, lang),
                    const SizedBox(height: 8),
                    _buildFilterChipsRow(lang),
                  ],
                ),
              ),

              // 3. Floating Map Controls (Right Side)
              Positioned(
                bottom: 24,
                right: 14,
                child: _buildMapControls(outbreaks),
              ),

              // 4. Empty State Indicator (when filters return 0)
              if (outbreaks.isEmpty)
                Positioned(
                  top: 120,
                  left: 20,
                  right: 20,
                  child: _buildEmptyBanner(lang),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: VetBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) context.go('/vet-dashboard');
          if (index == 1) context.go('/vet-requests');
          if (index == 2) context.go('/consultation-history');
          if (index == 3) context.go('/vet-outbreak-map');
          if (index == 4) context.go('/vet-profile');
        },
      ),
    );
  }

  Widget _buildMap(List<OutbreakModel> outbreaks) {
    final initialCenter = outbreaks.isNotEmpty
        ? LatLng(outbreaks.first.centerLatitude, outbreaks.first.centerLongitude)
        : (outbreakNotifier.userLocation != null
            ? LatLng(
                outbreakNotifier.userLocation!.latitude,
                outbreakNotifier.userLocation!.longitude,
              )
            : const LatLng(18.5204, 73.8567)); // Maharashtra default

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 10.0,
        minZoom: 4.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // OpenStreetMap Base Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'app.vetra.livestock',
        ),

        // Outbreak Containment Radius Circles
        CircleLayer(
          circles: outbreaks.map((o) {
            final color = _getRiskColor(o.riskScore);
            return CircleMarker(
              point: LatLng(o.centerLatitude, o.centerLongitude),
              radius: o.radiusKm * 1000, // converted to meters
              useRadiusInMeter: true,
              color: _getRiskFillColor(o.riskScore),
              borderColor: color,
              borderStrokeWidth: 2.0,
            );
          }).toList(),
        ),

        // Case Reports Layer (Suspected & Confirmed field reports)
        if (_showCasesLayer)
          MarkerLayer(
            markers: outbreakNotifier.nearbyReports.map((nr) {
              final isConfirmed = nr.report.diagnosisStatus == 'CONFIRMED';
              return Marker(
                point: LatLng(nr.report.latitude, nr.report.longitude),
                width: 30,
                height: 30,
                child: GestureDetector(
                  onTap: () => _showCaseReportModal(nr.report),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isConfirmed ? AppColors.alertCritical : AppColors.cautionAmber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isConfirmed ? Icons.pets : Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

        // Active Outbreak Cluster Center Pins
        MarkerLayer(
          markers: outbreaks.map((o) {
            final riskColor = _getRiskColor(o.riskScore);
            return Marker(
              point: LatLng(o.centerLatitude, o.centerLongitude),
              width: 70,
              height: 70,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => _showClusterDetailsModal(o),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: riskColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${o.diseaseName.split(" ").first} (${o.affectedReportsCount})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: riskColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.crisis_alert_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // User Location Pin
        if (outbreakNotifier.userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  outbreakNotifier.userLocation!.latitude,
                  outbreakNotifier.userLocation!.longitude,
                ),
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.vetAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vetAccent.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMetricsSummaryBar(OutbreakStatisticsModel stats, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricStat(
            label: lang == 'mr' ? 'सक्रिय केंद्रे' : (lang == 'hi' ? 'सक्रिय प्रकोप' : 'Active Clusters'),
            value: stats.activeOutbreaks.toString(),
            color: AppColors.primary,
          ),
          _buildMetricDivider(),
          _buildMetricStat(
            label: lang == 'mr' ? 'अतिधोकादायक' : (lang == 'hi' ? 'अति गंभीर' : 'Critical'),
            value: stats.criticalOutbreaks.toString(),
            color: AppColors.alertCritical,
          ),
          _buildMetricDivider(),
          _buildMetricStat(
            label: lang == 'mr' ? 'बाधित प्राणी' : (lang == 'hi' ? 'प्रभावित पशु' : 'Affected Cases'),
            value: stats.totalAnimalsAffected.toString(),
            color: AppColors.cautionAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricStat({required String label, required String value, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: AppTypography.captionMetadata.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      height: 22,
      width: 1,
      color: AppColors.borderHairline.withValues(alpha: 0.4),
    );
  }

  Widget _buildFilterChipsRow(String lang) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: outbreakNotifier.selectedDiseaseFilter,
            icon: Icons.coronavirus_outlined,
            onTap: () => _showDiseaseFilterPicker(lang),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: outbreakNotifier.selectedRiskFilter,
            icon: Icons.shield_outlined,
            onTap: () => _showRiskFilterPicker(lang),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: outbreakNotifier.selectedStatusFilter,
            icon: Icons.filter_alt_outlined,
            onTap: () => _showStatusFilterPicker(lang),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.captionMetadata.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls(List<OutbreakModel> outbreaks) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircleButton(
          icon: _showCasesLayer ? Icons.visibility : Icons.visibility_off,
          tooltip: 'Toggle Field Case Markers',
          onTap: () => setState(() => _showCasesLayer = !_showCasesLayer),
        ),
        const SizedBox(height: 8),
        _buildCircleButton(
          icon: Icons.my_location_rounded,
          tooltip: 'My Location',
          onTap: () async {
            final loc = await outbreakNotifier.fetchUserLocation();
            if (loc != null) {
              _mapController.move(LatLng(loc.latitude, loc.longitude), 12.0);
            }
          },
        ),
        const SizedBox(height: 8),
        _buildCircleButton(
          icon: Icons.zoom_out_map_rounded,
          tooltip: 'Fit All Outbreaks',
          onTap: _fitMapToOutbreaks,
        ),
        const SizedBox(height: 8),
        _buildCircleButton(
          icon: Icons.add,
          tooltip: 'Zoom In',
          onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
        ),
        const SizedBox(height: 8),
        _buildCircleButton(
          icon: Icons.remove,
          tooltip: 'Zoom Out',
          onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildLoadingState(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            lang == 'mr'
                ? 'रोग सर्वेक्षण डेटा लोड होत आहे...'
                : (lang == 'hi' ? 'रोग निगरानी डेटा लोड हो रहा है...' : 'Loading live surveillance GIS data...'),
            style: AppTypography.cardTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, String lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.alertCritical),
            const SizedBox(height: 12),
            Text(
              lang == 'mr'
                  ? 'डेटा लोड करण्यात अडचण आली'
                  : (lang == 'hi' ? 'डेटा लोड करने में विफल' : 'Unable to load surveillance data'),
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: 6),
            Text(error, style: AppTypography.captionMetadata, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PrimaryButton(
              label: lang == 'mr' ? 'पुन्हा प्रयत्न करा' : (lang == 'hi' ? 'पुनः प्रयास करें' : 'Retry'),
              onPressed: () => outbreakNotifier.loadOutbreaks(refresh: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBanner(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'mr'
                      ? 'कोणतेही सक्रिय केंद्र आढळले नाही'
                      : (lang == 'hi' ? 'कोई सक्रिय प्रकोप क्लस्टर नहीं मिला' : 'No Active Outbreak Clusters'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  lang == 'mr'
                      ? 'निवडलेल्या निकषांनुसार परिसर सध्या सुरक्षित आहे.'
                      : (lang == 'hi' ? 'चयनित फिल्टर अनुसार क्षेत्र सुरक्षित है।' : 'No matching clusters for the active filter selection.'),
                  style: AppTypography.captionMetadata.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDiseaseFilterPicker(String lang) {
    final diseases = outbreakNotifier.availableDiseases;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'mr' ? 'रोगानुसार फिल्टर करा' : (lang == 'hi' ? 'रोग अनुसार फ़िल्टर' : 'Filter by Disease'),
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 12),
              ...diseases.map((d) => ListTile(
                    title: Text(d, style: AppTypography.bodyDefault),
                    trailing: outbreakNotifier.selectedDiseaseFilter == d
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      outbreakNotifier.setDiseaseFilter(d);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showRiskFilterPicker(String lang) {
    const risks = ['All Risks', 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'mr' ? 'धोका पातळीनुसार फिल्टर' : (lang == 'hi' ? 'जोखिम स्तर फ़िल्टर' : 'Filter by Risk Level'),
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 12),
              ...risks.map((r) => ListTile(
                    title: Text(r, style: AppTypography.bodyDefault),
                    trailing: outbreakNotifier.selectedRiskFilter == r
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      outbreakNotifier.setRiskFilter(r);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showStatusFilterPicker(String lang) {
    const statuses = ['All Statuses', 'ACTIVE', 'MONITORING', 'RESOLVED'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'mr' ? 'स्थितीनुसार फिल्टर' : (lang == 'hi' ? 'स्थिति फ़िल्टर' : 'Filter by Status'),
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 12),
              ...statuses.map((s) => ListTile(
                    title: Text(s, style: AppTypography.bodyDefault),
                    trailing: outbreakNotifier.selectedStatusFilter == s
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      outbreakNotifier.setStatusFilter(s);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showClusterDetailsModal(OutbreakModel cluster) {
    outbreakNotifier.selectCluster(cluster);
    final riskColor = _getRiskColor(cluster.riskScore);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final bd = cluster.riskBreakdown;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.40,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return AnimatedBuilder(
              animation: outbreakNotifier,
              builder: (context, _) {
                final reports = outbreakNotifier.clusterReports;
                final isLoadingReports = outbreakNotifier.isLoadingClusterReports;

                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderHairline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cluster.diseaseName,
                                style: AppTypography.cardTitle.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${cluster.status} • Radius: ${cluster.radiusKm.toStringAsFixed(1)} km',
                                style: AppTypography.captionMetadata,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: riskColor, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${cluster.compositeRiskScore}',
                                style: TextStyle(
                                  color: riskColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${cluster.riskScore} RISK',
                                style: TextStyle(
                                  color: riskColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Multi-Signal Risk Intelligence Section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.analytics_outlined, size: 16, color: riskColor),
                              const SizedBox(width: 6),
                              const Text(
                                'MULTI-SIGNAL RISK BREAKDOWN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSignalBar(
                            label: 'Spatial Cluster Density (40%)',
                            score: bd?.clusterScore ?? 50.0,
                            points: (bd?.clusterScore ?? 50.0) * 0.40,
                            maxPoints: 40.0,
                            color: AppColors.primary,
                            icon: Icons.hub_outlined,
                          ),
                          const SizedBox(height: 8),
                          _buildSignalBar(
                            label: 'Environmental / Weather (20%)',
                            score: bd?.weatherScore ?? 40.0,
                            points: (bd?.weatherScore ?? 40.0) * 0.20,
                            maxPoints: 20.0,
                            color: Colors.blueAccent,
                            icon: Icons.cloud_outlined,
                          ),
                          const SizedBox(height: 8),
                          _buildSignalBar(
                            label: 'Historical Pattern Recurrence (20%)',
                            score: bd?.historyScore ?? 30.0,
                            points: (bd?.historyScore ?? 30.0) * 0.20,
                            maxPoints: 20.0,
                            color: Colors.purpleAccent,
                            icon: Icons.history_edu_outlined,
                          ),
                          const SizedBox(height: 8),
                          _buildSignalBar(
                            label: 'Herd Vaccination Immunity Gap (20%)',
                            score: bd?.vaccinationGapScore ?? 55.0,
                            points: (bd?.vaccinationGapScore ?? 55.0) * 0.20,
                            maxPoints: 20.0,
                            color: Colors.teal,
                            icon: Icons.vaccines_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Contextual Environmental & Immunity Badges
                    if (bd != null) ...[
                      Row(
                        children: [
                          if (bd.weatherTemperature != null && bd.weatherHumidity != null)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.25)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.thermostat, size: 14, color: Colors.blueAccent),
                                        SizedBox(width: 4),
                                        Text('Weather Factors', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${bd.weatherTemperature!.toStringAsFixed(1)}°C • ${bd.weatherHumidity!.toStringAsFixed(0)}% Hum',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                    if (bd.weatherPrecipitation != null && bd.weatherPrecipitation! > 0)
                                      Text('${bd.weatherPrecipitation!.toStringAsFixed(1)} mm rain', style: AppTypography.captionMetadata.copyWith(fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                          if (bd.weatherTemperature != null && bd.vaccinationCoveragePct != null)
                            const SizedBox(width: 8),
                          if (bd.vaccinationCoveragePct != null)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.shield_outlined, size: 14, color: Colors.teal),
                                        SizedBox(width: 4),
                                        Text('Herd Immunity', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${bd.vaccinationCoveragePct!.toStringAsFixed(0)}% Vaccinated',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${(100.0 - bd.vaccinationCoveragePct!).toStringAsFixed(0)}% Immunity Gap',
                                      style: AppTypography.captionMetadata.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Actionable Biosecurity Recommendation Banner
                    if (bd != null && bd.recommendedAction.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: riskColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.health_and_safety_outlined, size: 20, color: riskColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RECOMMENDED BIOSECURITY DIRECTIVE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: riskColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bd.recommendedAction,
                                    style: const TextStyle(fontSize: 12, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    _buildDetailRow('Quarantine Radius', '${cluster.radiusKm.toStringAsFixed(1)} km Bio-containment'),
                    const SizedBox(height: 6),
                    _buildDetailRow('Affected Reports', '${cluster.affectedReportsCount} Cases Registered'),
                    const SizedBox(height: 6),
                    _buildDetailRow('Center GPS', '${cluster.centerLatitude.toStringAsFixed(4)}° N, ${cluster.centerLongitude.toStringAsFixed(4)}° E'),
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      'Last Case Reported',
                      cluster.lastCaseReportedAt != null
                          ? dateFormat.format(cluster.lastCaseReportedAt!.toLocal())
                          : 'N/A',
                    ),
                    const Divider(height: 24),
                    Text('Contributing Field Reports', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                    const SizedBox(height: 8),
                    if (isLoadingReports)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      )
                    else if (reports.isEmpty)
                      Text(
                        'No individual reports retrieved for this cluster.',
                        style: AppTypography.captionMetadata,
                      )
                    else
                      ...reports.map((r) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.pets, size: 18, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${r.animalName ?? "Animal"} (${r.tagNumber ?? "TAG"})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      if (r.notes != null && r.notes!.isNotEmpty)
                                        Text(
                                          r.notes!,
                                          style: AppTypography.captionMetadata.copyWith(fontSize: 11),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: r.diagnosisStatus == 'CONFIRMED'
                                        ? AppColors.alertCritical.withValues(alpha: 0.15)
                                        : AppColors.cautionAmber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    r.diagnosisStatus,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: r.diagnosisStatus == 'CONFIRMED'
                                          ? AppColors.alertCritical
                                          : AppColors.cautionAmber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Close Details',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSignalBar({
    required String label,
    required double score,
    required double points,
    required double maxPoints,
    required Color color,
    required IconData icon,
  }) {
    final pct = (score / 100.0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Text(
              '${points.toStringAsFixed(1)} / ${maxPoints.toStringAsFixed(0)} pts',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  void _showCaseReportModal(DiseaseReportModel report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Field Disease Case Report', style: AppTypography.cardTitle),
              const SizedBox(height: 12),
              _buildDetailRow('Animal', '${report.animalName ?? "Animal"} (${report.tagNumber ?? "TAG"})'),
              const SizedBox(height: 6),
              _buildDetailRow('Condition', report.diseaseName),
              const SizedBox(height: 6),
              _buildDetailRow('Diagnosis Status', report.diagnosisStatus),
              const SizedBox(height: 6),
              _buildDetailRow('GPS Coordinates', '${report.latitude.toStringAsFixed(4)}° N, ${report.longitude.toStringAsFixed(4)}° E'),
              if (report.notes != null) ...[
                const SizedBox(height: 6),
                _buildDetailRow('Clinical Notes', report.notes!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
