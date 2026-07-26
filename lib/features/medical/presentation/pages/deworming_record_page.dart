import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class DewormingRecordPage extends StatelessWidget {
  const DewormingRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Deworming History', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.medication, color: AppColors.primary),
            title: Text('Albendazole Oral Drench', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            subtitle: Text('Administered 15 Aug 2023 • Next due Nov 2023', style: AppTypography.captionMetadata),
          ),
        ],
      ),
    );
  }
}
