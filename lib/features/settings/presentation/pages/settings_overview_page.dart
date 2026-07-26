import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class SettingsOverviewPage extends StatelessWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Settings', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildItem(context, 'Notifications', Icons.notifications, '/notification-preferences'),
          _buildItem(context, 'Language Settings', Icons.language, '/language-settings'),
          _buildItem(context, 'Security & Passwords', Icons.lock, '/security-settings'),
          _buildItem(context, 'Privacy', Icons.privacy_tip, '/privacy-settings'),
          _buildItem(context, 'Help & Support', Icons.help_outline, '/help-support'),
          _buildItem(context, 'About & Legal', Icons.info_outline, '/about-legal'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      tileColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}
