import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authNotifier,
      builder: (context, _) {
        final user = authNotifier.currentUser;
        final name = user?.name ?? 'Farmer';
        final contact = user?.emailOrPhone ?? 'No contact information';

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text('Farmer Profile', style: AppTypography.screenTitle),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Icon(Icons.person, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: AppTypography.screenTitle),
                    Text(contact, style: AppTypography.captionMetadata),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/edit-profile'),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                tileColor: AppColors.surfaceCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: const Icon(Icons.settings, color: AppColors.primary),
                title: Text('Account Settings', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings-overview'),
              ),
              const SizedBox(height: 12),
              ListTile(
                tileColor: AppColors.surfaceCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: const Icon(Icons.logout, color: AppColors.alertCritical),
                title: Text('Log Out', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.alertCritical)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.alertCritical),
                onTap: () async {
                  await authNotifier.logout();
                  if (context.mounted) context.go('/welcome');
                },
              ),
            ],
          ),
          bottomNavigationBar: FarmerBottomNavigation(
            currentIndex: 4,
            onTap: (index) {
              if (index == 0) context.go('/farmer-dashboard');
              if (index == 1) context.go('/my-animals');
              if (index == 2) context.go('/alerts');
              if (index == 3) context.go('/nearby-vets');
            },
          ),
        );
      },
    );
  }
}
