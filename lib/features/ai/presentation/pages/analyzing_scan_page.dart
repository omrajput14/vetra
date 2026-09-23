import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../providers/ai_scan_provider.dart';

class AnalyzingScanPage extends StatefulWidget {
  final Map<String, dynamic>? extraArgs;

  const AnalyzingScanPage({super.key, this.extraArgs});

  @override
  State<AnalyzingScanPage> createState() => _AnalyzingScanPageState();
}

class _AnalyzingScanPageState extends State<AnalyzingScanPage> {
  bool _isSubmitting = true;
  bool _isOfflineSaved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isSubmitting = true;
      _isOfflineSaved = false;
      _error = null;
    });

    final extra = widget.extraArgs ?? (GoRouterState.of(context).extra as Map<String, dynamic>?);
    final String? imagePath = extra?['imagePath']?.toString() ?? aiScanNotifier.selectedImagePath;
    final String? animalId = extra?['animalId']?.toString() ?? aiScanNotifier.selectedAnimalId;

    if (imagePath == null || imagePath.isEmpty || animalId == null || animalId.isEmpty) {
      setState(() {
        _isSubmitting = false;
        _error = 'Missing image or animal details. Please retake the photo.';
      });
      return;
    }

    final success = await aiScanNotifier.submitScan(
      animalId: animalId,
      imagePath: imagePath,
    );

    if (!mounted) return;

    if (success) {
      final scan = aiScanNotifier.lastScanResult;
      if (scan != null && scan.status == 'PENDING_UPLOAD') {
        // Saved offline in local queue
        setState(() {
          _isSubmitting = false;
          _isOfflineSaved = true;
        });
      } else if (scan == null || scan.isAnalysisFailure) {
        // The server stored the photo but its AI produced no diagnosis.
        setState(() {
          _isSubmitting = false;
          _error = 'Scan failed, please retry. The AI could not analyse this photo, '
              'so no diagnosis was produced (scan status: ${scan?.status ?? 'unknown'}).';
        });
      } else {
        // Online analysis complete
        context.go('/scan-results', extra: {'imagePath': imagePath, 'animalId': animalId});
      }
    } else {
      setState(() {
        _isSubmitting = false;
        _error = aiScanNotifier.errorMessage ?? 'AI scan submission failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSubmitting) ...[
                const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                const SizedBox(height: 24),
                Text('Processing Scan...', style: AppTypography.screenTitle),
                const SizedBox(height: 8),
                Text(
                  'Processing livestock image for VETRA AI Diagnostic Platform...',
                  style: AppTypography.captionMetadata,
                  textAlign: TextAlign.center,
                ),
              ] else if (_isOfflineSaved) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.cautionAmber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.cautionAmber),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan Saved Locally (Offline)',
                  style: AppTypography.screenTitle.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your photo and animal scan are saved securely on this device.\n\nWhen internet connection is restored, VETRA will automatically upload this scan to the cloud AI platform for complete diagnosis.',
                  style: AppTypography.captionMetadata.copyWith(fontSize: 13, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Return to Dashboard',
                  onPressed: () => context.go('/farmer-dashboard'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Scan Another Animal'),
                ),
              ] else ...[
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Analysis Failed',
                  style: AppTypography.screenTitle.copyWith(color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ?? 'An unexpected error occurred.',
                  style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Retry Analysis',
                  onPressed: _startAnalysis,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Back to Camera'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
