import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class AnalyzingScanPage extends StatefulWidget {
  const AnalyzingScanPage({super.key});

  @override
  State<AnalyzingScanPage> createState() => _AnalyzingScanPageState();
}

class _AnalyzingScanPageState extends State<AnalyzingScanPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/scan-results');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 24),
            Text('Analyzing Photo...', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text('Running neural network model locally on edge device', style: AppTypography.captionMetadata),
          ],
        ),
      ),
    );
  }
}
