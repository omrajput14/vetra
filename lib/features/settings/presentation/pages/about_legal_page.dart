import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class AboutLegalPage extends StatelessWidget {
  const AboutLegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('About Vetra', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('VETRA v1.0.0', style: AppTypography.screenTitle),
            Text('Livestock Surveillance & Tele-Health System', style: AppTypography.captionMetadata),
          ],
        ),
      ),
    );
  }
}
