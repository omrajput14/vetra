import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../storage/secure_storage_service.dart';

/// When App lock is on (Security settings), asks for fingerprint or phone PIN as the app
/// opens and when it returns after [relockAfter] in the background. The app stays mounted
/// under the lock so the open screen is kept.
class AppLock extends StatefulWidget {
  final Widget child;
  const AppLock({super.key, required this.child});

  // Long enough that taking a photo for an AI scan does not lock the app.
  static const relockAfter = Duration(seconds: 30);
  static final _auth = LocalAuthentication();

  static Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// System fingerprint / PIN prompt. False when cancelled or unavailable.
  static Future<bool> confirm(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } catch (_) {
      return false;
    }
  }

  @override
  State<AppLock> createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> {
  // The setting is read when the app starts and each time it goes to the background, so
  // returning can lock at once without waiting on storage. Until the first read the app
  // shows as normal: that is the splash screen.
  bool _enabled = false;
  bool _locked = false;
  bool _prompting = false;
  DateTime? _hiddenAt;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () {
        if (_prompting) return;
        _hiddenAt = DateTime.now();
        _readSetting();
      },
      onShow: () {
        final hiddenAt = _hiddenAt;
        _hiddenAt = null;
        if (_enabled && hiddenAt != null && DateTime.now().difference(hiddenAt) >= AppLock.relockAfter) {
          _lockAndPrompt();
        }
      },
    );
    _readSetting().then((_) {
      if (_enabled && mounted) _lockAndPrompt();
    });
  }

  Future<void> _readSetting() async => _enabled = await SecureStorageService.instance.isAppLockEnabled();

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _lockAndPrompt() async {
    setState(() => _locked = true);
    if (_prompting) return;
    _prompting = true;
    final ok = await AppLock.confirm('Unlock PASHU SATHI');
    _prompting = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ExcludeSemantics(excluding: _locked, child: TickerMode(enabled: !_locked, child: widget.child)),
        if (_locked)
          Positioned.fill(
            child: Material(
              color: AppColors.surfaceBackground,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/branding/vetra_logo_transparent.png', width: 80, height: 80),
                      const SizedBox(height: 16),
                      Text('PASHU SATHI is locked', style: AppTypography.screenTitle),
                      const SizedBox(height: 8),
                      Text('Use your fingerprint or phone PIN to continue.', style: AppTypography.captionMetadata),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _lockAndPrompt,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Unlock'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
