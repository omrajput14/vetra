import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../providers/ai_scan_provider.dart';
// BUG 4 FIX: AnimalApiService import removed — we no longer auto-create fake animals

class DiseaseScannerPage extends StatefulWidget {
  const DiseaseScannerPage({super.key});

  @override
  State<DiseaseScannerPage> createState() => _DiseaseScannerPageState();
}

class _DiseaseScannerPageState extends State<DiseaseScannerPage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  String _cameraErrorMessage = '';
  String? _selectedImagePath;
  bool _isCapturing = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _loadFarmerAnimals();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  /// BUG 2 + 4 FIX: Only fetch real animals from the server.
  /// Never auto-create a hardcoded fake animal ("Gauri").
  /// The UI will show a clear prompt if the farmer has no registered animals.
  Future<void> _loadFarmerAnimals() async {
    await aiScanNotifier.fetchFarmerAnimals();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isCameraError = false;
      _cameraErrorMessage = '';
    });
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isCameraError = true;
          _cameraErrorMessage = 'No camera available on this device.';
        });
        return;
      }
      final selectedCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      final controller = CameraController(selectedCamera, ResolutionPreset.high, enableAudio: false);
      _cameraController = controller;
      await controller.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCameraError = true;
        _cameraErrorMessage = 'Camera permission denied or camera unavailable.\nDetails: ${e.toString()}';
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera is not ready yet.')),
      );
      return;
    }
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _selectedImagePath = photo.path;
        _isCapturing = false;
      });
      aiScanNotifier.setSelectedImage(photo.path);
    } catch (e) {
      setState(() => _isCapturing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 82,
      );
      if (image != null) {
        setState(() => _selectedImagePath = image.path);
        aiScanNotifier.setSelectedImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo from gallery: ${e.toString()}')),
        );
      }
    }
  }

  void _proceedToAnalysis() {
    if (_selectedImagePath == null || _selectedImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or select an image first.')),
      );
      return;
    }

    final animalId = aiScanNotifier.selectedAnimalId;

    // BUG 2 FIX: If no real animal is registered — show a clear user-facing
    // message with an action to add one. Do NOT proceed with a null animal
    // (previously caused false "offline" scan submission errors).
    if (animalId == null || animalId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please register an animal first before scanning.'),
          action: SnackBarAction(
            label: 'Add Animal',
            onPressed: () => context.push('/add-animal'),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    context.push('/analyzing-scan', extra: {
      'imagePath': _selectedImagePath,
      'animalId': animalId,
    });
  }

  Widget _buildPreviewContent() {
    if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
      return Image.file(File(_selectedImagePath!), fit: BoxFit.cover, width: 280, height: 280);
    }
    if (_isCameraError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(_cameraErrorMessage,
              style: AppTypography.captionMetadata.copyWith(color: Colors.white70),
              textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initCamera,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPrimary, foregroundColor: Colors.black),
              child: const Text('Retry Camera'),
            ),
          ],
        ),
      );
    }
    if (_isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: SizedOverflowBox(
          size: const Size(280, 280),
          alignment: Alignment.center,
          child: CameraPreview(_cameraController!),
        ),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.brandPrimary, strokeWidth: 3),
        SizedBox(height: 16),
        Text('Initializing Camera...', style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI Camera Scan', style: AppTypography.screenTitle.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Scan history',
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/scan-history'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.brandPrimary, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: _buildPreviewContent(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedImagePath != null ? 'Image ready for AI analysis' : 'Position lesion inside reticle',
                  style: AppTypography.captionMetadata.copyWith(color: Colors.white70),
                ),
                // BUG 2 FIX: Show a real warning if no animal is registered
                // (instead of silently creating a fake one and failing later)
                if (aiScanNotifier.selectedAnimalId == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => context.push('/add-animal'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                            SizedBox(width: 6),
                            Text('No animal registered — tap to add one',
                              style: TextStyle(color: Colors.orange, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImagePath != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _selectedImagePath = null),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Retake Photo', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(label: 'Analyze Photo', onPressed: _proceedToAnalysis),
                      ),
                    ],
                  ),
                ] else ...[
                  PrimaryButton(
                    label: _isCapturing ? 'Capturing...' : 'Capture & Analyze',
                    onPressed: _isCapturing
                        ? () {}
                        : () async {
                            await _capturePhoto();
                            if (_selectedImagePath != null) _proceedToAnalysis();
                          },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library, color: AppColors.brandPrimary),
                    label: const Text('Upload from Gallery',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.brandPrimary),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
