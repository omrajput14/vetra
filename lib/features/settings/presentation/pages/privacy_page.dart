import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Privacy Policy', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Data Privacy & Animal Surveillance Policy',
            style: AppTypography.cardTitle,
          ),
          const SizedBox(height: 12),
          Text(
            'Animal health data, farm locations, and disease reports submitted '
            'through this app are stored on government-certified cloud '
            'infrastructure and are accessible only to authorised veterinary '
            'officers and government health officials. Your data is used solely '
            'for livestock disease surveillance and animal welfare purposes '
            'under the Pashu Sathi programme.',
            style: AppTypography.bodyDefault,
          ),
          const SizedBox(height: 16),
          Text(
            'Data Retention',
            style: AppTypography.cardTitle.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Records are retained for a minimum of 7 years in accordance with '
            'national livestock health regulations. You may request access to '
            'or deletion of your personal data by contacting your district '
            'veterinary officer.',
            style: AppTypography.bodyDefault,
          ),
          const SizedBox(height: 16),
          Text(
            'Third-Party Sharing',
            style: AppTypography.cardTitle.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Anonymised and aggregated outbreak data may be shared with state '
            'and national disease surveillance networks (NADRS/OIE) for '
            'epidemiological analysis. Individual farmer or animal identities '
            'are never shared with commercial third parties.',
            style: AppTypography.bodyDefault,
          ),
        ],
      ),
    );
  }
}
