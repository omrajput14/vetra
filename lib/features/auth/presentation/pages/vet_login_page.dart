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
import '../../../../core/models/user_role.dart';

/// Vet sign-in; with [paraVet], the para-vet sign-in (same login endpoint, para-vet accounts only).
class VetLoginPage extends ConsumerStatefulWidget {
  final bool paraVet;
  const VetLoginPage({super.key, this.paraVet = false});

  @override
  ConsumerState<VetLoginPage> createState() => _VetLoginPageState();
}

class _VetLoginPageState extends ConsumerState<VetLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.enterEmailAndPassword ?? 'Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await authNotifier.loginVet(
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Each sign-in screen is for its own role: a para-vet account cannot use the vet one and back.
    final isParaVet = authNotifier.currentRole == UserRole.paraVet;
    if (success && isParaVet != widget.paraVet) {
      await authNotifier.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isParaVet
            ? 'This is a para-vet account. Go back and choose "Continue as Para-vet".'
            : 'This is a vet account. Go back and choose "Continue as Veterinarian".'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (success) {
      context.go(widget.paraVet ? '/paravet-home' : '/vet-dashboard');
    } else {
      final msg = authNotifier.errorMessage ?? (l10n?.error ?? 'Veterinarian login failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Locale activeLocale = const Locale('en');
    try {
      activeLocale = ref.watch(localeProvider);
    } catch (_) {}

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Image.asset('assets/branding/vetra_logo_transparent.png', height: 36, width: 36),
                      const SizedBox(width: 10),
                      Text('PASHU SATHI', style: AppTypography.screenTitle.copyWith(color: AppColors.primary, letterSpacing: 1.2, fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.paraVet ? 'Para-vet Sign In' : (l10n?.vetSignIn ?? 'Veterinarian Sign In'),
                      style: AppTypography.screenTitle),
                  const SizedBox(height: 8),
                  Text(
                    widget.paraVet
                        ? 'Check farmers\' AI scans in your area and record vaccination drives.'
                        : (l10n?.vetSignInSubtitle ?? 'Access clinical diagnostics and regional outbreak triage.'),
                    style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _emailController,
                    labelText: l10n?.email ?? 'Email',
                    hintText: widget.paraVet ? 'name@example.com' : 'dr.smith@clinic.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (!widget.paraVet) ...[
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _licenseController,
                      labelText: l10n?.registrationNumber ?? 'Veterinary Registration Number (Optional)',
                      hintText: 'VET-9941-XX',
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    labelText: l10n?.password ?? 'Password',
                    hintText: 'Enter clinical password',
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
                      child: Text(
                        l10n?.forgotPassword ?? 'Forgot Password?',
                        style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
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
                      Text(widget.paraVet ? 'New para-vet? ' : '${l10n?.newPractitioner ?? "New Practitioner?"} ',
                          style: AppTypography.captionMetadata),
                      GestureDetector(
                        onTap: () => context.push(widget.paraVet ? '/paravet-register' : '/vet-register'),
                        child: Text(
                          l10n?.createAccount ?? 'Register',
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
        ),
      ),
    );
  }
}
