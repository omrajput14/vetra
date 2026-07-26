import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';

class DiseaseScannerPage extends StatelessWidget {
  const DiseaseScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI Camera Scan', style: AppTypography.screenTitle.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.brandPrimary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('Position lesion inside reticle', style: AppTypography.captionMetadata.copyWith(color: Colors.white70)),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: PrimaryButton(
              label: 'Capture & Analyze',
              onPressed: () => context.push('/analyzing-scan'),
            ),
          ),
        ],
      ),
    );
  }
}
