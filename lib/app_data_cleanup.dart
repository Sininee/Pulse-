import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataCleanup {
  static Future<void> clearAllLocalAppData() async {
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear Flutter image cache in memory
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // Clear disk cache used by cached_network_image / flutter_cache_manager
    await DefaultCacheManager().emptyCache();

    // Clear app temp/cache directory
    try {
      final tempDir = await getTemporaryDirectory();
      await _deleteDirectoryContents(tempDir);
    } catch (_) {}

    // Clear app support directory
    try {
      final supportDir = await getApplicationSupportDirectory();
      await _deleteDirectoryContents(supportDir);
    } catch (_) {}

    // Clear app documents directory
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      await _deleteDirectoryContents(docsDir);
    } catch (_) {}
  }

  static Future<void> _deleteDirectoryContents(Directory dir) async {
    if (!await dir.exists()) return;

    final entities = dir.listSync(recursive: false);
    for (final entity in entities) {
      try {
        await entity.delete(recursive: true);
      } catch (_) {
        // Ignore individual failures
      }
    }
  }
}