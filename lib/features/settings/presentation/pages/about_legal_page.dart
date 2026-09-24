import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class AboutLegalPage extends StatelessWidget {
  const AboutLegalPage({super.key});

  // From the Engineering Team section of README.md.
  static const _team = ['Om Rajput', 'Mrunmai Joshi', 'Khushi', 'Soham', 'Prachi', 'Dhiraj'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('About PASHU SATHI', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          final version = info == null ? '' : 'Version ${info.version} (Build ${info.buildNumber})';
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Image.asset('assets/branding/vetra_logo_transparent.png', width: 90, height: 90, fit: BoxFit.contain),
              const SizedBox(height: 16),
              Text('PASHU SATHI', style: AppTypography.screenTitle, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(version, style: AppTypography.captionMetadata, textAlign: TextAlign.center),
              Text('Livestock Surveillance & Tele-Health System',
                  style: AppTypography.captionMetadata, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Text('Team', style: AppTypography.cardTitle),
              const SizedBox(height: 8),
              Text(_team.join(' · '), style: AppTypography.bodyDefault),
              const SizedBox(height: 24),
              Text('Medical disclaimer', style: AppTypography.cardTitle),
              const SizedBox(height: 8),
              Text(
                'AI disease screening in this app is advisory and is not a veterinary diagnosis. '
                'Always confirm with a registered veterinarian before treating an animal.',
                style: AppTypography.bodyDefault,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                title: Text('Privacy', style: AppTypography.bodyDefault),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/privacy-settings'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                title: Text('Open-source licences', style: AppTypography.bodyDefault),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'PASHU SATHI',
                  applicationVersion: version,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
