import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../app_colors.dart';

class VetBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const VetBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n?.vetDashboard ?? 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: l10n?.pendingRequests ?? 'Requests',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medical_services),
            label: l10n?.recentCases ?? 'Cases',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: l10n?.vetOutbreakMap ?? 'Map',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle),
            label: l10n?.profile ?? 'Profile',
          ),
        ],
      ),
    );
  }
}
