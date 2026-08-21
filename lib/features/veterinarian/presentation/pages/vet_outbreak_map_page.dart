import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import '../../../../l10n/app_localizations.dart';

class VetOutbreakMapPage extends StatefulWidget {
  const VetOutbreakMapPage({super.key});

  @override
  State<VetOutbreakMapPage> createState() => _VetOutbreakMapPageState();
}

class _VetOutbreakMapPageState extends State<VetOutbreakMapPage> {
  String _selectedDisease = 'All Diseases';
  String _selectedRadius = '15 km';
  String _selectedStatus = 'All Statuses';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text(l10n?.vetOutbreakMap ?? 'Vet Outbreak Map', style: AppTypography.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('${l10n?.filterDisease ?? "Disease"}: $_selectedDisease', () => _showFilterDialog(l10n?.filterDisease ?? 'Disease')),
                const SizedBox(width: 8),
                _buildFilterChip('${l10n?.filterRadius ?? "Radius"}: $_selectedRadius', () => _showFilterDialog(l10n?.filterRadius ?? 'Radius')),
                const SizedBox(width: 8),
                _buildFilterChip('${l10n?.filterStatus ?? "Status"}: $_selectedStatus', () => _showFilterDialog(l10n?.filterStatus ?? 'Status')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
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
                      const Icon(Icons.map, size: 64, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(l10n?.gisMapTitle ?? 'Interactive Clinical GIS Map', style: AppTypography.cardTitle),
                      Text(l10n?.gisMapSubtitle ?? 'GPS Radius Overlay around practice area', style: AppTypography.captionMetadata),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(AppColors.alertCritical, '${l10n?.statusConfirmed ?? "Confirmed"} (2)'),
                        _buildLegendItem(AppColors.cautionAmber, '${l10n?.statusPending ?? "Pending"} (4)'),
                        _buildLegendItem(AppColors.primary, 'Clear Zone'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n?.outbreakAlerts ?? 'Confirmed Outbreaks (Vet Verified)', style: AppTypography.sectionHeading),
          const SizedBox(height: 8),
          _buildOutbreakCard(
            disease: 'Foot and Mouth Disease (FMD)',
            location: 'Oak Valley Farm (3.2 km away)',
            confirmedBy: 'Dr. Sarah Jenkins',
            date: 'Yesterday, 04:15 PM',
            statusColor: AppColors.alertCritical,
            statusLabel: l10n?.criticalStatus ?? 'CONFIRMED OUTBREAK',
            radiusText: '5 km Quarantine Active',
          ),
          const SizedBox(height: 12),
          Text(l10n?.assistiveClinicalScreening ?? 'Pending AI Verification Reports', style: AppTypography.sectionHeading),
          const SizedBox(height: 8),
          _buildOutbreakCard(
            disease: 'Lumpy Skin Disease (LSD)',
            location: 'Highland Dairy Farm (8.7 km away)',
            confirmedBy: 'Farmer AI Report (92% Confidence)',
            date: 'Today, 08:30 AM',
            statusColor: AppColors.cautionAmber,
            statusLabel: l10n?.statusPending ?? 'NEEDS VET CONFIRMATION',
            radiusText: 'Pending Clinical Review',
          ),
          const SizedBox(height: 12),
          Text(l10n?.recentCases ?? 'Nearby Registered Cases', style: AppTypography.sectionHeading),
          const SizedBox(height: 8),
          _buildCaseItem('Cow #481', 'Bovine Respiratory', 'Green Pastures Dairy (4.1 km)', l10n?.underTreatment ?? 'Under Treatment'),
          const SizedBox(height: 8),
          _buildCaseItem('Bull #109', 'Mastitis Flare-up', 'Sunnyvale Ranch (6.5 km)', l10n?.followUpDate ?? 'Follow-up Scheduled'),
        ],
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

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return ActionChip(
      backgroundColor: AppColors.surfaceCard,
      label: Text(label, style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
      onPressed: onTap,
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.captionMetadata.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildOutbreakCard({
    required String disease,
    required String location,
    required String confirmedBy,
    required String date,
    required Color statusColor,
    required String statusLabel,
    required String radiusText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(disease, style: AppTypography.cardTitle.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.captionMetadata.copyWith(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(location, style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Reported: $confirmedBy • $date', style: AppTypography.captionMetadata),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.radar, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(radiusText, style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaseItem(String animal, String diagnosis, String farm, String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$animal - $diagnosis', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                Text('$farm • $status', style: AppTypography.captionMetadata),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(String type) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by $type', style: AppTypography.cardTitle),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('All Options'),
                onTap: () {
                  setState(() {
                    if (type == 'Disease' || type == 'रोग') _selectedDisease = 'All Diseases';
                    if (type == 'Radius' || type == 'दायरा' || type == 'त्रिज्या') _selectedRadius = '50 km';
                    if (type == 'Status' || type == 'स्थिति' || type == 'स्थिती') _selectedStatus = 'All Statuses';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
