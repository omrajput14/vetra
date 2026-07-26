import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Security Settings', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            activeTrackColor: AppColors.primary,
            title: Text('Biometric Authentication', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            subtitle: Text('Require Fingerprint / FaceID to open app', style: AppTypography.captionMetadata),
            value: true,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
