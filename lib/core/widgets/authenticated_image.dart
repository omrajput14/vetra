import 'dart:io';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../design_system/app_colors.dart';
import '../storage/secure_storage_service.dart';

/// Renders animal and user photos with offline-first support and Bearer token authentication.
/// Priority:
/// 1. Local filesystem path ([localPhotoPath]) if file exists.
/// 2. Authenticated remote URL ([photoUrl]).
/// 3. Neutral placeholder widget or icon ([placeholder] / [placeholderIcon]).
class AuthenticatedImage extends StatefulWidget {
  final String? localPhotoPath;
  final String? photoUrl;
  final IconData placeholderIcon;
  final Widget? placeholder;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const AuthenticatedImage({
    super.key,
    this.localPhotoPath,
    this.photoUrl,
    this.placeholderIcon = Icons.pets,
    this.placeholder,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
  });

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final t = await SecureStorageService.instance.getAccessToken();
    if (mounted && t != _token) {
      setState(() {
        _token = t;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Check local file on disk
    if (widget.localPhotoPath != null && widget.localPhotoPath!.isNotEmpty) {
      final file = File(widget.localPhotoPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.file(
            file,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        );
      }
    }

    // 2. Check remote photo URL / endpoint
    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      // Do NOT load if it looks like a local android/ios path that leaked
      if (!widget.photoUrl!.startsWith('/data/') &&
          !widget.photoUrl!.startsWith('/storage/') &&
          !widget.photoUrl!.startsWith('file://')) {
        String fullUrl = widget.photoUrl!;
        if (widget.photoUrl!.startsWith('/')) {
          fullUrl = '${AppConfig.baseUrl}${widget.photoUrl}';
        }

        final headers = (_token != null && _token!.isNotEmpty)
            ? {'Authorization': 'Bearer $_token'}
            : <String, String>{};

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.network(
            fullUrl,
            headers: headers,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: widget.width,
                height: widget.height,
                color: AppColors.surfaceContainer,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        );
      }
    }

    // 3. Fallback placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Center(
        child: Icon(
          widget.placeholderIcon,
          color: AppColors.textMetadata.withValues(alpha: 0.6),
          size: (widget.width != null && widget.height != null)
              ? (widget.width! * 0.45).clamp(16, 40)
              : 24,
        ),
      ),
    );
  }
}
