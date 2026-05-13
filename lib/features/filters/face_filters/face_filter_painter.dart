// ============================================================
//  features/filters/face_filters/face_filter_painter.dart
//  Draws AR overlays (dog ears, sunglasses, hearts, etc.)
// ============================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/filter_model.dart';

class FaceFilterPainter extends CustomPainter {
  final List<Face> faces;
  final FilterType filterType;
  final Size imageSize;
  final bool isFrontCamera;

  const FaceFilterPainter({
    required this.faces,
    required this.filterType,
    required this.imageSize,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vignette doesn't need face data
    if (filterType == FilterType.vignette) {
      _drawVignette(canvas, size);
      return;
    }
    for (final face in faces) {
      _paintFace(canvas, size, face);
    }
  }

  void _paintFace(Canvas canvas, Size size, Face face) {
    final sx = size.width  / imageSize.width;
    final sy = size.height / imageSize.height;

    Offset toCanvas(Point<int> p) {
      double x = p.x * sx;
      if (isFrontCamera) x = size.width - x;
      return Offset(x, p.y * sy);
    }

    final bb = face.boundingBox;
    final rect = Rect.fromLTRB(
      isFrontCamera ? size.width - bb.right  * sx : bb.left  * sx,
      bb.top    * sy,
      isFrontCamera ? size.width - bb.left   * sx : bb.right * sx,
      bb.bottom * sy,
    );

    switch (filterType) {
      case FilterType.dogEars:
        _dogEars(canvas, rect, face, toCanvas);
      case FilterType.sunglasses:
        _sunglasses(canvas, rect, face, toCanvas);
      case FilterType.rainbow:
        _rainbow(canvas, rect, face, toCanvas);
      case FilterType.heartEyes:
        _heartEyes(canvas, rect, face, toCanvas);
      case FilterType.beautySmooth:
        _beauty(canvas, rect);
      default:
        break;
    }
  }

  // ── Dog Ears & Nose ───────────────────────────────────────
  void _dogEars(Canvas canvas, Rect r, Face f, Offset Function(Point<int>) tc) {
    final p = Paint()..style = PaintingStyle.fill;
    final fw = r.width;
    final fh = r.height;
    final earH = fh * 0.42;
    final earTop = r.top - earH * 0.55;

    void drawEar(bool isLeft) {
      final ex = isLeft ? r.left : r.right;
      final sign = isLeft ? 1.0 : -1.0;
      p.color = const Color(0xFFC4956A);
      final ear = Path()
        ..moveTo(ex + sign * fw * 0.05, earTop + earH)
        ..quadraticBezierTo(ex - sign * fw * 0.1, earTop, ex + sign * fw * 0.18, earTop)
        ..quadraticBezierTo(ex + sign * fw * 0.35, earTop + earH * 0.3, ex + sign * fw * 0.28, earTop + earH)
        ..close();
      canvas.drawPath(ear, p);
      p.color = const Color(0xFFE8B4B8);
      final inner = Path()
        ..moveTo(ex + sign * fw * 0.08, earTop + earH * 0.88)
        ..quadraticBezierTo(ex + sign * fw * 0.02, earTop + earH * 0.4, ex + sign * fw * 0.12, earTop + earH * 0.22)
        ..quadraticBezierTo(ex + sign * fw * 0.28, earTop + earH * 0.3, ex + sign * fw * 0.22, earTop + earH * 0.88)
        ..close();
      canvas.drawPath(inner, p);
    }

    drawEar(true);
    drawEar(false);

    // Nose
    final nx = r.center.dx;
    final ny = r.top + fh * 0.60;
    p.color = const Color(0xFF2D1B00);
    canvas.drawOval(Rect.fromCenter(center: Offset(nx, ny), width: fw * 0.30, height: fh * 0.14), p);
    p.color = Colors.white.withOpacity(0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(nx - fw * 0.05, ny - fh * 0.03), width: fw * 0.08, height: fh * 0.04), p);
  }

  // ── Sunglasses ────────────────────────────────────────────
  void _sunglasses(Canvas canvas, Rect r, Face f, Offset Function(Point<int>) tc) {
    final leLm = f.landmarks[FaceLandmarkType.leftEye];
    final reLm = f.landmarks[FaceLandmarkType.rightEye];
    final eyeY  = leLm != null ? tc(leLm.position).dy : r.top + r.height * 0.38;
    final leX   = leLm != null ? tc(leLm.position).dx : r.left  + r.width * 0.28;
    final reX   = reLm != null ? tc(reLm.position).dx : r.right - r.width * 0.28;

    final lensW = (reX - leX).abs() * 0.72;
    final lensH = lensW * 0.58;

    final frame = Paint()..color = Colors.black..style = PaintingStyle.fill;
    final arm   = Paint()..color = Colors.black..style = PaintingStyle.stroke
        ..strokeWidth = lensH * 0.16..strokeCap = StrokeCap.round;

    void drawLens(double cx) {
      final rect = Rect.fromCenter(center: Offset(cx, eyeY), width: lensW, height: lensH);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(lensH * 0.3));
      canvas.drawRRect(rr, frame);
      final tint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.blue.withOpacity(0.55), Colors.indigo.withOpacity(0.55)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ).createShader(rect)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rr, tint);
    }

    drawLens(leX);
    drawLens(reX);
    // bridge
    canvas.drawLine(Offset(leX + lensW / 2, eyeY), Offset(reX - lensW / 2, eyeY), arm);
    // arms
    canvas.drawLine(Offset(leX - lensW / 2, eyeY), Offset(r.left  - r.width * 0.08, eyeY), arm);
    canvas.drawLine(Offset(reX + lensW / 2, eyeY), Offset(r.right + r.width * 0.08, eyeY), arm);
  }

  // ── Rainbow arc from mouth ────────────────────────────────
  void _rainbow(Canvas canvas, Rect r, Face f, Offset Function(Point<int>) tc) {
    final mLm = f.landmarks[FaceLandmarkType.bottomMouth];
    final mx = r.center.dx;
    final my = mLm != null ? tc(mLm.position).dy : r.top + r.height * 0.76;

    final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.indigo, Colors.purple];
    for (int i = 0; i < colors.length; i++) {
      final p = Paint()
        ..color = colors[i].withOpacity(0.85)
        ..strokeWidth = r.width * 0.038
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final rad = r.width * (0.32 + i * 0.08);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(mx, my + rad * 0.1), width: rad * 2, height: rad * 1.5),
        math.pi, math.pi, false, p,
      );
    }
  }

  // ── Heart Eyes ────────────────────────────────────────────
  void _heartEyes(Canvas canvas, Rect r, Face f, Offset Function(Point<int>) tc) {
    final leLm = f.landmarks[FaceLandmarkType.leftEye];
    final reLm = f.landmarks[FaceLandmarkType.rightEye];
    final lePos = leLm != null ? tc(leLm.position) : Offset(r.left + r.width * 0.3, r.top + r.height * 0.38);
    final rePos = reLm != null ? tc(reLm.position) : Offset(r.right - r.width * 0.3, r.top + r.height * 0.38);
    _heart(canvas, lePos, r.width * 0.16);
    _heart(canvas, rePos, r.width * 0.16);
  }

  void _heart(Canvas canvas, Offset c, double s) {
    final p = Paint()..color = Colors.red..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.35)
      ..cubicTo(c.dx - s, c.dy - s * 0.5, c.dx - s * 1.5, c.dy + s * 0.5, c.dx, c.dy + s * 1.4)
      ..cubicTo(c.dx + s * 1.5, c.dy + s * 0.5, c.dx + s, c.dy - s * 0.5, c.dx, c.dy + s * 0.35)
      ..close();
    canvas.drawPath(path, p);
    // shine
    final shine = Paint()..color = Colors.red.shade200.withOpacity(0.5)..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx - s * 0.22, c.dy + s * 0.08), width: s * 0.38, height: s * 0.28), shine);
  }

  // ── Soft beauty glow ──────────────────────────────────────
  void _beauty(Canvas canvas, Rect r) {
    final p = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..color = Colors.white.withOpacity(0.07);
    canvas.drawOval(Rect.fromCenter(center: r.center, width: r.width * 1.1, height: r.height * 1.05), p);
  }

  // ── Full-screen vignette ──────────────────────────────────
  void _drawVignette(Canvas canvas, Size size) {
    final p = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.72)],
        stops: const [0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), p);
  }

  @override
  bool shouldRepaint(FaceFilterPainter o) =>
      o.faces != faces || o.filterType != filterType || o.imageSize != imageSize;
}
