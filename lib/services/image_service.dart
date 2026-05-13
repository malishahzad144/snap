// ============================================================
//  services/image_service.dart
//  Applies selected filter + enhancements to a captured image,
//  saves to gallery, and prepares a share-able file.
// ============================================================
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageService {
  // ── Save rendered widget as image to gallery ─────────────
  /// Pass the GlobalKey of the RepaintBoundary wrapping the preview
  static Future<String?> saveToGallery(GlobalKey repaintKey) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;

      final tmp  = await getTemporaryDirectory();
      final file = File(p.join(tmp.path, 'snap_${DateTime.now().millisecondsSinceEpoch}.jpg'));
      await file.writeAsBytes(bytes.buffer.asUint8List());

      await Gal.putImage(file.path, album: 'SnapFilter');
      return file.path;
    } catch (e) {
      debugPrint('Save error: $e');
      return null;
    }
  }

  // ── Share via system sheet ────────────────────────────────
  static Future<void> shareImage(GlobalKey repaintKey) async {
    final path = await saveToGallery(repaintKey);
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], text: 'Captured with SnapFilter 📸');
  }

  // ── Share directly to Instagram Stories ──────────────────
  static Future<void> shareToInstagram(GlobalKey repaintKey) async {
    final path = await saveToGallery(repaintKey);
    if (path == null) return;
    // Instagram accepts a direct share via XFile
    await Share.shareXFiles(
      [XFile(path)],
      text: '',
      subject: 'SnapFilter',
    );
  }

  // ── Share to WhatsApp ────────────────────────────────────
  static Future<void> shareToWhatsApp(GlobalKey repaintKey) async {
    final path = await saveToGallery(repaintKey);
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], text: '📸 via SnapFilter');
  }
}
