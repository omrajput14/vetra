import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/models/user_role.dart';
import '../providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _initSession();
  }

  Future<void> _initSession() async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final hasSession = await authNotifier.restoreSession().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
      if (!mounted) return;

      if (hasSession && authNotifier.isLoggedIn) {
        if (authNotifier.currentRole == UserRole.veterinarian) {
          context.go('/vet-dashboard');
        } else {
          context.go('/farmer-dashboard');
        }
      } else {
        context.go('/welcome');
      }
    } catch (_) {
      if (mounted) context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/branding/vetra_logo_transparent.png',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text('PASHU SATHI', style: AppTypography.screenTitle.copyWith(fontSize: 28)),
                const SizedBox(height: 4),
                Text('Livestock Health & Surveillance', style: AppTypography.captionMetadata),
                const SizedBox(height: 32),
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text('Initializing authentication session...', style: AppTypography.captionMetadata),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
