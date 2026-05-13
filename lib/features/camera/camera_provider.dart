// ============================================================
//  features/camera/camera_provider.dart
//  Manages camera init, flash, zoom, front/back switching,
//  photo capture, and face detection pipeline.
// ============================================================
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../filters/face_filters/face_filter_painter.dart';

class CameraProvider extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────
  List<CameraDescription> _cameras = [];
  CameraController?       _controller;
  bool   _isInitialized = false;
  bool   _isCapturing   = false;
  bool   _isFront       = true;
  int    _cameraIndex   = 0;    // Index in _cameras list
  double _currentZoom   = 1.0;
  double _minZoom       = 1.0;
  double _maxZoom       = 5.0;
  FlashMode _flashMode  = FlashMode.off;

  // ML Kit face detection
  late final FaceDetector _faceDetector;
  List<Face>  _faces     = [];
  Size        _imageSize = Size.zero;
  bool _detectionRunning = false;

  // Last captured image path (passed to preview screen)
  String? _lastCapturedPath;

  // ── Getters ──────────────────────────────────────────────
  CameraController? get controller       => _controller;
  bool   get isInitialized  => _isInitialized;
  bool   get isCapturing    => _isCapturing;
  bool   get isFrontCamera  => _isFront;
  double get currentZoom    => _currentZoom;
  double get minZoom        => _minZoom;
  double get maxZoom        => _maxZoom;
  FlashMode get flashMode   => _flashMode;
  List<Face> get faces      => _faces;
  Size   get imageSize      => _imageSize;
  String? get lastCapturedPath => _lastCapturedPath;

  // ── Init ─────────────────────────────────────────────────
  Future<void> initCamera() async {
    // Face detector (fast mode for real-time)
    _faceDetector = FaceDetector(options: FaceDetectorOptions(
      enableLandmarks:     true,
      enableClassification:true,
      performanceMode:     FaceDetectorMode.fast,
      minFaceSize:         0.15,
    ));

    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    // Prefer front camera on launch (Snapchat style)
    _cameraIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
    if (_cameraIndex < 0) _cameraIndex = 0;
    _isFront = _cameras[_cameraIndex].lensDirection == CameraLensDirection.front;

    await _startController(_cameras[_cameraIndex]);
  }

  Future<void> _startController(CameraDescription cam) async {
    final controller = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // required for ML Kit on Android
    );
    _controller = controller;

    try {
      await controller.initialize();
      _minZoom = await controller.getMinZoomLevel();
      _maxZoom = await controller.getMaxZoomLevel();
      _currentZoom = _minZoom;
      _isInitialized = true;
      notifyListeners();

      // Start face detection stream
      controller.startImageStream(_onCameraImage);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  // ── Image stream → ML Kit ────────────────────────────────
  void _onCameraImage(CameraImage image) {
    if (_detectionRunning) return;
    _detectionRunning = true;

    final inputImage = _buildInputImage(image);
    if (inputImage == null) { _detectionRunning = false; return; }

    _faceDetector.processImage(inputImage).then((faces) {
      _faces     = faces;
      _imageSize = Size(image.width.toDouble(), image.height.toDouble());
      _detectionRunning = false;
      notifyListeners();
    }).catchError((_) { _detectionRunning = false; });
  }

  InputImage? _buildInputImage(CameraImage image) {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    final camDesc = _cameras[_cameraIndex];
    final rotation = InputImageRotationValue.fromRawValue(camDesc.sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes:    plane.bytes,
      metadata: InputImageMetadata(
        size:     Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format:   format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // ── Capture photo ────────────────────────────────────────
  Future<String?> capturePhoto() async {
    if (_controller == null || !_isInitialized || _isCapturing) return null;
    _isCapturing = true;
    notifyListeners();
    try {
      // Pause stream so capture doesn't race
      await _controller!.stopImageStream();
      final xFile = await _controller!.takePicture();
      // Save to temp
      final tmp  = await getTemporaryDirectory();
      final dest = p.join(tmp.path, 'snap_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(xFile.path).copy(dest);
      _lastCapturedPath = dest;
      return dest;
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    } finally {
      _isCapturing = false;
      // Resume stream
      _controller?.startImageStream(_onCameraImage);
      notifyListeners();
    }
  }

  // ── Flash ────────────────────────────────────────────────
  Future<void> cycleFlash() async {
    if (_controller == null) return;
    _flashMode = switch (_flashMode) {
      FlashMode.off   => FlashMode.auto,
      FlashMode.auto  => FlashMode.always,
      FlashMode.always => FlashMode.off,
      _ => FlashMode.off,
    };
    await _controller!.setFlashMode(_flashMode);
    notifyListeners();
  }

  IconData get flashIcon => switch (_flashMode) {
    FlashMode.off    => Icons.flash_off,
    FlashMode.auto   => Icons.flash_auto,
    FlashMode.always => Icons.flash_on,
    _ => Icons.flash_off,
  };

  // ── Flip camera ──────────────────────────────────────────
  Future<void> flipCamera() async {
    if (_cameras.length < 2) return;
    _isInitialized = false;
    notifyListeners();
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _faces = [];

    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    _isFront = _cameras[_cameraIndex].lensDirection == CameraLensDirection.front;
    await _startController(_cameras[_cameraIndex]);
  }

  // ── Zoom ─────────────────────────────────────────────────
  Future<void> setZoom(double zoom) async {
    _currentZoom = zoom.clamp(_minZoom, _maxZoom);
    await _controller?.setZoomLevel(_currentZoom);
    notifyListeners();
  }

  // ── Dispose ──────────────────────────────────────────────
  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}
