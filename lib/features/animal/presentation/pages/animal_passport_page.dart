import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class AnimalPassportPage extends StatelessWidget {
  const AnimalPassportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Digital Passport', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            onPressed: () => context.push('/animal-passport-qr-updated'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Icon(Icons.pets, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text('Bessie', style: AppTypography.screenTitle),
                Text('Tag ID: NL-93842 • Holstein', style: AppTypography.captionMetadata),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetaColumn('Age', '4 Yrs'),
                    _buildMetaColumn('Weight', '580 kg'),
                    _buildMetaColumn('Status', 'Healthy'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Health History', style: AppTypography.sectionHeading),
          const SizedBox(height: 12),
          ListTile(
            tileColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.history, color: AppColors.primary),
            title: Text('Vaccination Timeline', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            subtitle: Text('View full medical history', style: AppTypography.captionMetadata),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/animal-timeline'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTypography.captionMetadata),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
      ],
    );
  }
}
