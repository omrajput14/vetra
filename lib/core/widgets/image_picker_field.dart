import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../../l10n/app_localizations.dart';

/// Reusable farmer-friendly image picker with Camera, Gallery, live preview, retake, and remove actions.
/// Compresses captured/picked images and preserves local filesystem isolation.
class ImagePickerField extends StatefulWidget {
  final String? initialLocalPath;
  final String? initialRemoteUrl;
  final String? label;
  final ValueChanged<String?> onImageChanged;
  final String subDirectory; // 'animal_photos' or 'profile_photos'

  const ImagePickerField({
    super.key,
    this.initialLocalPath,
    this.initialRemoteUrl,
    this.label,
    required this.onImageChanged,
    this.subDirectory = 'animal_photos',
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final ImagePicker _picker = ImagePicker();
  static const _uuid = Uuid();

  String? _localPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _localPath = widget.initialLocalPath;
  }

  @override
  void didUpdateWidget(covariant ImagePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocalPath != oldWidget.initialLocalPath) {
      setState(() {
        _localPath = widget.initialLocalPath;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );

      if (picked == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Store in app documents directory with isolated UUID filename
      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${appDir.path}/${widget.subDirectory}');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final ext = picked.path.split('.').last.toLowerCase();
      final safeExt = (ext == 'png' || ext == 'webp') ? ext : 'jpg';
      final fileName = '${widget.subDirectory}_${_uuid.v4()}.$safeExt';
      final savedFile = await File(picked.path).copy('${targetDir.path}/$fileName');

      setState(() {
        _localPath = savedFile.path;
        _isLoading = false;
      });

      widget.onImageChanged(_localPath);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? (l10n?.permissionCameraDenied ?? 'Could not access camera')
                  : (l10n?.permissionGalleryDenied ?? 'Could not access gallery'),
            ),
            backgroundColor: AppColors.alertCritical,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _localPath = null;
    });
    widget.onImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fieldLabel = widget.label ?? (l10n?.animalPhoto ?? 'Animal Photo (Optional)');

    final hasLocalImage = _localPath != null && File(_localPath!).existsSync();
    final hasRemoteImage = widget.initialRemoteUrl != null && widget.initialRemoteUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldLabel,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
            ),
          )
        else if (hasLocalImage || hasRemoteImage)
          _buildPreviewContainer(l10n, hasLocalImage)
        else
          _buildPickerButtons(l10n),
      ],
    );
  }

  Widget _buildPreviewContainer(AppLocalizations? l10n, bool hasLocal) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 80,
              child: hasLocal
                  ? Image.file(
                      File(_localPath!),
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      widget.initialRemoteUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainer,
                        child: const Icon(Icons.pets, color: AppColors.textMetadata, size: 36),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.photoPreview ?? 'Photo Selected',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(l10n?.retakePhoto ?? 'Retake', style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.alertCritical),
                      label: Text(
                        l10n?.removePhoto ?? 'Remove',
                        style: const TextStyle(fontSize: 12, color: AppColors.alertCritical),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButtons(AppLocalizations? l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: Text(l10n?.takePhotoCamera ?? 'Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(l10n?.chooseFromGallery ?? 'Gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
