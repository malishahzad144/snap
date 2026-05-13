// ============================================================
//  features/preview/preview_screen.dart
//  Full-screen photo review — apply filter, save, share
// ============================================================
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/image_service.dart';
import '../filters/face_filters/face_filter_painter.dart';
import '../filters/models/filter_model.dart';

class PreviewScreen extends StatefulWidget {
  final String      imagePath;
  final FilterModel filterModel;
  final List<double>colorMatrix;
  final double      blur;
  final bool        isFrontCamera;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    required this.filterModel,
    required this.colorMatrix,
    required this.blur,
    required this.isFrontCamera,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool    _isSaving = false;
  String? _toast;

  Future<void> _save() async {
    setState(() { _isSaving = true; _toast = null; });
    final path = await ImageService.saveToGallery(_repaintKey);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _toast = path != null ? '✅ Saved to SnapFilter album!' : '❌ Save failed';
    });
    if (path != null) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _toast = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(
          child: RepaintBoundary(
            key: _repaintKey,
            child: _buildFilteredImage(),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16, right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleBtn(icon: Icons.arrow_back_ios_new, onTap: () => Navigator.pop(context)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFFF8E53)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(widget.filterModel.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(widget.filterModel.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
              ),
            ],
          ),
        ),
        if (_toast != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 32, right: 32,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24)),
                child: Text(_toast!, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _BottomBar(
            isSaving: _isSaving,
            onSave:      _save,
            onShare:     () => ImageService.shareImage(_repaintKey),
            onInstagram: () => ImageService.shareToInstagram(_repaintKey),
            onWhatsApp:  () => ImageService.shareToWhatsApp(_repaintKey),
          ),
        ),
      ]),
    );
  }

  Widget _buildFilteredImage() {
    Widget img = Image.file(
      File(widget.imagePath),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
    img = ColorFiltered(
      colorFilter: ColorFilter.matrix(widget.colorMatrix),
      child: img,
    );
    if (widget.blur > 0) {
      img = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: img,
      );
    }
    if (widget.filterModel.type == FilterType.vignette) {
      img = Stack(children: [
        img,
        Positioned.fill(
          child: CustomPaint(
            painter: FaceFilterPainter(
              faces: const [],
              filterType: FilterType.vignette,
              imageSize: const Size(1, 1),
              isFrontCamera: widget.isFrontCamera,
            ),
          ),
        ),
      ]);
    }
    return img;
  }
}

class _BottomBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave, onShare, onInstagram, onWhatsApp;
  const _BottomBar({required this.isSaving, required this.onSave,
      required this.onShare, required this.onInstagram, required this.onWhatsApp});

  @override
  Widget build(BuildContext context) {
    final pb = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, pb + 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent, Colors.black87],
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Btn(icon: isSaving ? Icons.hourglass_top : Icons.save_alt,
              label: 'Save', color: AppTheme.secondary, onTap: isSaving ? null : onSave),
          _Btn(icon: Icons.ios_share, label: 'Share', color: Colors.white, onTap: onShare),
          _Btn(emoji: '📸', label: 'Instagram', color: const Color(0xFFE1306C), onTap: onInstagram),
          _Btn(emoji: '💬', label: 'WhatsApp', color: const Color(0xFF25D366), onTap: onWhatsApp),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _Btn({this.icon, this.emoji, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: color, size: 24)
                : Text(emoji!, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10.5)),
      ]),
    ),
  );
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}
