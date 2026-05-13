// ============================================================
//  features/filters/widgets/enhancement_panel.dart
//  Brightness / Contrast / Saturation / Blur sliders
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../filter_provider.dart';

class EnhancementPanel extends StatelessWidget {
  const EnhancementPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (_, fp, __) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Slider(
                label: '☀️ Brightness',
                value: fp.brightness,
                onChanged: fp.setBrightness,
                activeColor: Colors.yellow,
              ),
              _Slider(
                label: '◑ Contrast',
                value: fp.contrast,
                onChanged: fp.setContrast,
                activeColor: Colors.white,
              ),
              _Slider(
                label: '🌈 Saturation',
                value: fp.saturation,
                onChanged: fp.setSaturation,
                activeColor: Colors.pink,
              ),
              _Slider(
                label: '💧 Blur',
                value: fp.blur / 20,
                onChanged: (v) => fp.setBlur(v * 20),
                activeColor: Colors.lightBlue,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: fp.resetEnhancements,
                child: const Text('Reset', style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Slider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  const _Slider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(
          width: 105,
          child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: activeColor,
              inactiveTrackColor: Colors.white24,
              thumbColor: activeColor,
              overlayColor: activeColor.withOpacity(0.25),
            ),
            child: Slider(
              value: value,
              min: -1.0, max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 34,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ]),
    );
  }
}
