import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class QrScannerVetPage extends StatelessWidget {
  const QrScannerVetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Scan Animal Tag QR', style: AppTypography.screenTitle.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.brandPrimary, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text('Align QR code in frame', style: AppTypography.captionMetadata.copyWith(color: Colors.white70)),
          ),
        ),
      ),
    );
  }
}
