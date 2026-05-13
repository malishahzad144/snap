// ============================================================
//  features/filters/filter_provider.dart
//  Manages active filter + brightness/contrast/saturation sliders
// ============================================================
import 'package:flutter/material.dart';
import 'models/filter_model.dart';
import 'color_filters/color_filter_data.dart';

class FilterProvider extends ChangeNotifier {
  // ── Filter list & selection ──────────────────────────────
  final List<FilterModel> filters = ColorFilterData.allFilters;
  int _selectedIndex = 0;
  FilterModel get selectedFilter => filters[_selectedIndex];
  int get selectedIndex => _selectedIndex;

  // ── Enhancement values (-1.0 … 1.0) ────────────────────
  double _brightness  = 0.0;
  double _contrast    = 0.0;
  double _saturation  = 0.0;
  double _blur        = 0.0;  // 0..20 (used on still images only)

  double get brightness  => _brightness;
  double get contrast    => _contrast;
  double get saturation  => _saturation;
  double get blur        => _blur;

  bool _showEnhancements = false;
  bool get showEnhancements => _showEnhancements;

  // ── Active color matrix (filter + enhancements combined) ─
  List<double> get activeMatrix {
    final base = selectedFilter.colorMatrix ?? ColorFilterData.identity;
    var m = base;
    if (_brightness != 0) m = ColorFilterData.multiply(ColorFilterData.brightnessMatrix(_brightness), m);
    if (_contrast   != 0) m = ColorFilterData.multiply(ColorFilterData.contrastMatrix(_contrast), m);
    if (_saturation != 0) m = ColorFilterData.multiply(ColorFilterData.saturationMatrix(_saturation), m);
    return m;
  }

  // Whether a face-AR filter is active
  bool get isFaceFilter {
    final t = selectedFilter.type;
    return t == FilterType.beautySmooth ||
        t == FilterType.dogEars ||
        t == FilterType.sunglasses ||
        t == FilterType.rainbow ||
        t == FilterType.heartEyes;
  }

  // Whether a custom painter is needed (face-AR or vignette)
  bool get needsPainter =>
      isFaceFilter || selectedFilter.type == FilterType.vignette;

  // ── Actions ──────────────────────────────────────────────
  void selectFilter(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void setBrightness(double v)  { _brightness  = v; notifyListeners(); }
  void setContrast(double v)    { _contrast    = v; notifyListeners(); }
  void setSaturation(double v)  { _saturation  = v; notifyListeners(); }
  void setBlur(double v)        { _blur        = v; notifyListeners(); }

  void toggleEnhancements() {
    _showEnhancements = !_showEnhancements;
    notifyListeners();
  }

  void resetEnhancements() {
    _brightness = _contrast = _saturation = _blur = 0;
    notifyListeners();
  }
}
