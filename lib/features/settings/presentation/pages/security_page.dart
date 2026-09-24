import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Change password via POST /auth/change-password. The server revokes every
/// session on success, so the user is signed out and asked to sign in again.
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _current.text, next = _next.text;
    final problem = current.isEmpty || next.isEmpty
        ? 'Enter your current and new password.'
        : next.length < 6
            ? 'New password must be at least 6 characters.'
            : next != _confirm.text
                ? 'New passwords do not match.'
                : null;
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await authNotifier.changePassword(current, next);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    await authNotifier.logout();
    messenger.showSnackBar(const SnackBar(
      content: Text('Password changed. Sign in again with your new password.'),
    ));
    router.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Security Settings', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Change Password', style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          Text(
            'You will be signed out on all devices and need to sign in again.',
            style: AppTypography.captionMetadata,
          ),
          const SizedBox(height: 20),
          AppTextField(labelText: 'Current Password', hintText: 'Current password', controller: _current, obscureText: true),
          const SizedBox(height: 16),
          AppTextField(labelText: 'New Password', hintText: 'At least 6 characters', controller: _next, obscureText: true),
          const SizedBox(height: 16),
          AppTextField(labelText: 'Confirm New Password', hintText: 'Repeat new password', controller: _confirm, obscureText: true),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(label: 'Change Password', isLoading: _saving, onPressed: _saving ? null : _submit),
        ],
      ),
    );
  }
}
