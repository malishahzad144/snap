// ============================================================
//  features/camera/camera_screen.dart
//  Main screen: camera preview + filter bar + controls
// ============================================================
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../filters/face_filters/face_filter_painter.dart';
import '../filters/filter_provider.dart';
import '../filters/widgets/filter_bar.dart';
import '../filters/widgets/enhancement_panel.dart';
import '../preview/preview_screen.dart';
import 'camera_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool _permissionsGranted = false;
  bool _shutterAnim = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionsAndInit();
  }

  Future<void> _requestPermissionsAndInit() async {
    final statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();

    final granted = statuses.values.every((s) =>
        s == PermissionStatus.granted || s == PermissionStatus.limited);

    if (!mounted) return;
    setState(() => _permissionsGranted = granted);

    if (granted) {
      await context.read<CameraProvider>().initCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = context.read<CameraProvider>();
    if (!cam.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      cam.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      cam.initCamera();
    }
  }

  Future<void> _onCapture() async {
    setState(() => _shutterAnim = true);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _shutterAnim = false);

    final cam    = context.read<CameraProvider>();
    final filter = context.read<FilterProvider>();
    final path   = await cam.capturePhoto();
    if (path == null || !mounted) return;

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PreviewScreen(
        imagePath:    path,
        filterModel:  filter.selectedFilter,
        colorMatrix:  filter.activeMatrix,
        blur:         filter.blur,
        isFrontCamera:cam.isFrontCamera,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) return _permissionGate();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<CameraProvider, FilterProvider>(
        builder: (_, cam, filter, __) {
          if (!cam.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }
          return Stack(children: [
            // ── Camera preview ──────────────────────────────
            Positioned.fill(child: _CameraPreviewWidget(cam: cam)),

            // ── Color matrix overlay ────────────────────────
            if (filter.selectedFilter.colorMatrix != null || filter.brightness != 0 ||
                filter.contrast != 0 || filter.saturation != 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(filter.activeMatrix),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

            // ── Face AR / Vignette overlay ──────────────────
            if (filter.needsPainter && cam.imageSize != Size.zero)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: FaceFilterPainter(
                      faces:         cam.faces,
                      filterType:    filter.selectedFilter.type,
                      imageSize:     cam.imageSize,
                      isFrontCamera: cam.isFrontCamera,
                    ),
                  ),
                ),
              ),

            // ── Shutter flash animation ─────────────────────
            if (_shutterAnim)
              Positioned.fill(child: Container(color: Colors.white.withOpacity(0.5))),

            // ── Top controls ───────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0, right: 0,
              child: _TopBar(cam: cam, filter: filter),
            ),

            // ── Enhancement panel (shown when toggled) ─────
            if (filter.showEnhancements)
              Positioned(
                bottom: AppConstants.filterBarHeight + 80 + MediaQuery.of(context).padding.bottom,
                left: 0, right: 0,
                child: const EnhancementPanel(),
              ),

            // ── Bottom controls & filter bar ───────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _BottomControls(onCapture: _onCapture),
            ),
          ]);
        },
      ),
    );
  }

  Widget _permissionGate() => Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.camera_alt, color: AppTheme.primary, size: 72),
        const SizedBox(height: 20),
        const Text('Camera permission required',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _requestPermissionsAndInit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text('Grant Permission'),
        ),
        TextButton(
          onPressed: openAppSettings,
          child: const Text('Open Settings', style: TextStyle(color: Colors.white54)),
        ),
      ]),
    ),
  );
}

// ── Camera preview widget (handles aspect ratio) ─────────────
class _CameraPreviewWidget extends StatelessWidget {
  final CameraProvider cam;
  const _CameraPreviewWidget({required this.cam});

  @override
  Widget build(BuildContext context) {
    final ctrl = cam.controller!;
    return GestureDetector(
      onScaleUpdate: (d) {
        final zoom = (cam.currentZoom * d.scale).clamp(cam.minZoom, cam.maxZoom);
        cam.setZoom(zoom);
      },
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width:  ctrl.value.previewSize!.height,
            height: ctrl.value.previewSize!.width,
            child:  CameraPreview(ctrl),
          ),
        ),
      ),
    );
  }
}

// ── Top bar: flip / flash / enhance ─────────────────────────
class _TopBar extends StatelessWidget {
  final CameraProvider cam;
  final FilterProvider filter;
  const _TopBar({required this.cam, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconBtn(icon: cam.flashIcon, onTap: cam.cycleFlash),
          // App title
          const Text('SnapFilter',
              style: TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          _IconBtn(
            icon: Icons.tune,
            onTap: filter.toggleEnhancements,
            active: filter.showEnhancements,
          ),
        ],
      ),
    );
  }
}

// ── Bottom: gallery thumb + shutter + flip ───────────────────
class _BottomControls extends StatelessWidget {
  final VoidCallback onCapture;
  const _BottomControls({required this.onCapture});

  @override
  Widget build(BuildContext context) {
    final cam    = context.watch<CameraProvider>();
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Filter bar
        const FilterBar(),
        // Shutter row
        Padding(
          padding: EdgeInsets.fromLTRB(28, 12, 28, bottom + 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Gallery preview (last captured)
              GestureDetector(
                onTap: cam.lastCapturedPath != null
                    ? () {
                        final fp = context.read<FilterProvider>();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => PreviewScreen(
                            imagePath:    cam.lastCapturedPath!,
                            filterModel:  fp.selectedFilter,
                            colorMatrix:  fp.activeMatrix,
                            blur:         fp.blur,
                            isFrontCamera:cam.isFrontCamera,
                          ),
                        ));
                      }
                    : null,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white38, width: 1.5),
                  ),
                  child: cam.lastCapturedPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(cam.lastCapturedPath!), fit: BoxFit.cover),
                        )
                      : const Icon(Icons.photo, color: Colors.white38, size: 26),
                ),
              ),

              // Shutter
              GestureDetector(
                onTap: onCapture,
                child: Container(
                  width:  AppConstants.shutterButtonSize,
                  height: AppConstants.shutterButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, Color(0xFFFF8E53)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ),
              ),

              // Flip
              _IconBtn(icon: Icons.flip_camera_ios, onTap: cam.flipCamera),
            ],
          ),
        ),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _IconBtn({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppTheme.primary.withOpacity(0.25) : Colors.black45,
          border: active ? Border.all(color: AppTheme.primary, width: 1.5) : null,
        ),
        child: Icon(icon, color: active ? AppTheme.primary : Colors.white, size: 22),
      ),
    );
  }
}
