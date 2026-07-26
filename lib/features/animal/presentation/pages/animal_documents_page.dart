import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class AnimalDocumentsPage extends StatelessWidget {
  const AnimalDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Medical Certificates', style: AppTypography.screenTitle),
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
            leading: const Icon(Icons.picture_as_pdf, color: AppColors.alertCritical),
            title: Text('Ownership_Certificate.pdf', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            subtitle: Text('Added 10 Jan 2023', style: AppTypography.captionMetadata),
          ),
        ],
      ),
    );
  }
}
