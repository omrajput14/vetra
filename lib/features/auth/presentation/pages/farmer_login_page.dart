import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class FarmerLoginPage extends ConsumerStatefulWidget {
  const FarmerLoginPage({super.key});

  @override
  ConsumerState<FarmerLoginPage> createState() => _FarmerLoginPageState();
}

class _FarmerLoginPageState extends ConsumerState<FarmerLoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = 'voice.farmer.demo@vetra.app';
    _passwordController.text = 'Password@123';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone/email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await authNotifier.loginFarmer(identifier, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Reload locale from user preference saved during login
      await ref.read(localeProvider.notifier).loadSavedLocale();
      if (mounted) context.go('/farmer-dashboard');
    } else {
      final msg = authNotifier.errorMessage ?? 'Farmer login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/language-settings'),
            icon: const Icon(Icons.language, size: 18, color: AppColors.primary),
            label: Text(
              AppLocales.getLanguageNativeName(activeLocale.languageCode),
              style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(l10n?.signIn ?? 'Farmer Sign In', style: AppTypography.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Access herd surveillance and animal health records.',
                style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _phoneController,
                labelText: '${l10n?.phone ?? "Phone"} / ${l10n?.email ?? "Email"}',
                hintText: 'e.g. farmer@vetra.app',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _passwordController,
                labelText: l10n?.password ?? 'Password',
                hintText: 'Enter account password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMetadata),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(l10n?.forgotPassword ?? 'Forgot Password?', style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: _isLoading ? (l10n?.loading ?? 'Authenticating...') : (l10n?.login ?? 'Login'),
                onPressed: _isLoading ? null : () => _handleLogin(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${l10n?.dontHaveAccount ?? "Don't have an account?"} ', style: AppTypography.captionMetadata),
                  GestureDetector(
                    onTap: () => context.push('/farmer-register'),
                    child: Text(
                      l10n?.createAccount ?? 'Create Farmer Account',
                      style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
