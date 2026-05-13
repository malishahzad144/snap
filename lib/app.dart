// ============================================================
//  app.dart — Root widget
// ============================================================
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/camera/camera_screen.dart';

class SnapFilterApp extends StatelessWidget {
  const SnapFilterApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapFilter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CameraScreen(),
    );
  }
}
