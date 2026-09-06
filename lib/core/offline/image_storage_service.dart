import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service for persisting captured images to the local application storage.
/// Images stored in temporary cache paths (e.g. image_picker/camera) may be
/// cleared by the OS before the offline SyncEngine can upload them.
class ImageStorageService {
  ImageStorageService._();

  static final ImageStorageService instance = ImageStorageService._();

  /// Copies an image from a temporary [sourcePath] into permanent app storage.
  /// Format: `<appDocumentsDir>/vetra/scans/<identifier>.<extension>`
  Future<String> copyToPermanentStorage(String sourcePath, String identifier) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source image file not found at $sourcePath');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${appDir.path}/vetra/scans');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final extension = sourcePath.split('.').last;
      final targetPath = '${targetDir.path}/$identifier.$extension';
      final targetFile = await sourceFile.copy(targetPath);

      debugPrint('[ImageStorageService] Saved scan image to permanent path: $targetPath');
      return targetFile.path;
    } catch (e) {
      debugPrint('[ImageStorageService] Error copying image: $e');
      // If copying fails, return original path as fallback
      return sourcePath;
    }
  }
}
