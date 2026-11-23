import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/services/analytics_service.dart';

/// Service for rendering widgets into high-resolution images and launching
/// the native OS share sheet (WhatsApp, Instagram, Telegram, etc.).
class ShareCardService {
  /// Captures a widget rendered inside a RepaintBoundary into a PNG file and shares it.
  static Future<bool> captureAndShare({
    required GlobalKey boundaryKey,
    required String messageText,
    required AnalyticsService analytics,
    required String exercise,
    required int reps,
    String? rank,
  }) async {
    try {
      // 1. Locate RepaintBoundary
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        // Fallback: share text only if widget boundary not available
        await SharePlus.instance.share(ShareParams(text: messageText));
        await analytics.trackShareTapped(
          platform: 'text_fallback',
          exercise: exercise,
          reps: reps,
          rank: rank,
        );
        return true;
      }

      // 2. Rasterize to PNG at high DPI (pixelRatio: 3.0 for crisp 1080p output)
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        await SharePlus.instance.share(ShareParams(text: messageText));
        return true;
      }

      final pngBytes = byteData.buffer.asUint8List();

      // 3. Platform-specific sharing
      if (kIsWeb) {
        // Web: trigger share with text or file
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                pngBytes,
                mimeType: 'image/png',
                name: 'aura_max_rep_challenge.png',
              ),
            ],
            text: messageText,
          ),
        );
      } else {
        // Native mobile (Android/iOS): write to temp directory and invoke OS share sheet
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${tempDir.path}/aura_challenge_$timestamp.png');
        await file.writeAsBytes(pngBytes);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'image/png')],
            text: messageText,
          ),
        );
      }

      // 4. Record telemetry
      await analytics.trackShareTapped(
        platform: 'native_sheet',
        exercise: exercise,
        reps: reps,
        rank: rank,
      );

      return true;
    } catch (e) {
      debugPrint('[ShareCardService] Failed to capture and share image: $e');
      // Graceful degradation: share plain text invitation
      try {
        await SharePlus.instance.share(ShareParams(text: messageText));
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  /// Shares a text-only invite or challenge link directly via native share sheet.
  static Future<void> shareText({
    required String text,
    required AnalyticsService analytics,
    String platform = 'native_text',
  }) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text));
      await analytics.trackEvent('share_tapped', {'platform': platform});
    } catch (e) {
      debugPrint('[ShareCardService] Text share failed: $e');
    }
  }
}
