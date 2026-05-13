// ============================================================
//  features/filters/color_filters/color_filter_data.dart
//
//  Every 4×5 RGBA color matrix used in ColorFiltered widget.
//  Layout: row-major [R,G,B,A rows] × [R,G,B,A,offset cols]
// ============================================================
import 'package:flutter/material.dart';
import '../models/filter_model.dart';

class ColorFilterData {
  // ── Matrices ─────────────────────────────────────────────
  static const List<double> identity = [
    1,0,0,0,0,  0,1,0,0,0,  0,0,1,0,0,  0,0,0,1,0,
  ];
  static const List<double> vivid = [
    1.4,-0.1,-0.1,0,10,  -0.1,1.4,-0.1,0,10,  -0.1,-0.1,1.4,0,10,  0,0,0,1,0,
  ];
  static const List<double> noir = [
    .33,.33,.33,0,-20,  .33,.33,.33,0,-20,  .33,.33,.33,0,-20,  0,0,0,1,0,
  ];
  static const List<double> vintage = [
    .9,.3,0,0,10,  .2,.8,.1,0,5,  .1,.1,.6,0,0,  0,0,0,1,0,
  ];
  static const List<double> cool = [
    .8,0,.2,0,0,  0,.9,.1,0,5,  .1,.1,1.2,0,15,  0,0,0,1,0,
  ];
  static const List<double> warm = [
    1.2,.1,0,0,20,  .1,1,0,0,10,  0,0,.8,0,0,  0,0,0,1,0,
  ];
  static const List<double> fade = [
    .8,0,0,0,40,  0,.8,0,0,40,  0,0,.8,0,40,  0,0,0,1,0,
  ];
  static const List<double> neon = [
    .5,0,.8,0,30,  0,1.3,0,0,0,  .8,0,.5,0,30,  0,0,0,1,0,
  ];
  static const List<double> rose = [
    1.2,.1,.1,0,20,  .1,.8,.1,0,5,  .1,.1,.8,0,5,  0,0,0,1,0,
  ];
  static const List<double> tealOrange = [
    1.2,.1,-.2,0,10,  0,.9,.1,0,0,  -.2,.2,1.1,0,15,  0,0,0,1,0,
  ];
  static const List<double> sketch = [
    -1,0,0,0,255,  0,-1,0,0,255,  0,0,-1,0,255,  0,0,0,1,0,
  ];
  static const List<double> glitch = [
    1.4,0,0,0,20,  0,1,0,0,0,  0,0,1.4,0,20,  0,0,0,1,0,
  ];
  static const List<double> dreamy = [
    .9,.15,.15,0,30,  .1,.85,.15,0,30,  .1,.15,.95,0,40,  0,0,0,1,0,
  ];
  static const List<double> infrared = [
    -.3,1.3,0,0,0,  .5,.5,0,0,0,  0,0,0,0,200,  0,0,0,1,0,
  ];
  static const List<double> oilPaint = [
    1.1,.1,0,0,5,  0,1.1,.1,0,5,  0,.1,1.1,0,5,  0,0,0,1,0,
  ];
  static const List<double> pixelSort = [
    .8,.4,0,0,0,  0,.8,.4,0,0,  .4,0,.8,0,0,  0,0,0,1,0,
  ];

  // ── Enhancement helpers ──────────────────────────────────
  static List<double> brightnessMatrix(double v) {
    final o = v * 255;
    return [1,0,0,0,o, 0,1,0,0,o, 0,0,1,0,o, 0,0,0,1,0];
  }

  static List<double> contrastMatrix(double v) {
    final s = v + 1.0;
    final t = (-0.5 * s + 0.5) * 255;
    return [s,0,0,0,t, 0,s,0,0,t, 0,0,s,0,t, 0,0,0,1,0];
  }

  static List<double> saturationMatrix(double v) {
    final lum = 1.0 - (v + 1.0);
    final r = lum * 0.2126, g = lum * 0.7152, b = lum * 0.0722;
    final s = v + 1;
    return [
      r+s, g,   b,   0, 0,
      r,   g+s, b,   0, 0,
      r,   g,   b+s, 0, 0,
      0,   0,   0,   1, 0,
    ];
  }

  /// Multiply two 4×5 color matrices
  static List<double> multiply(List<double> a, List<double> b) {
    final out = List<double>.filled(20, 0);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        double sum = 0;
        for (int k = 0; k < 4; k++) sum += a[row*5+k] * b[k*5+col];
        if (col == 4) sum += a[row*5+4];
        out[row*5+col] = sum;
      }
    }
    return out;
  }

  // ── Full filter registry ─────────────────────────────────
  static List<FilterModel> get allFilters => [
    const FilterModel(type:FilterType.none,  name:'Original', category:FilterCategory.color,
        emoji:'✨', gradientColors:[Color(0xFF2C3E50),Color(0xFF4CA1AF)]),
    FilterModel(type:FilterType.vivid, name:'Vivid', category:FilterCategory.color,
        emoji:'🌈', gradientColors:const[Color(0xFFf093fb),Color(0xFFf5576c)], colorMatrix:vivid),
    FilterModel(type:FilterType.noir,  name:'Noir',  category:FilterCategory.color,
        emoji:'🎬', gradientColors:const[Color(0xFF434343),Color(0xFF000000)], colorMatrix:noir),
    FilterModel(type:FilterType.vintage,name:'Vintage',category:FilterCategory.color,
        emoji:'📷', gradientColors:const[Color(0xFFD4A574),Color(0xFF8B6914)], colorMatrix:vintage),
    FilterModel(type:FilterType.cool,  name:'Cool',  category:FilterCategory.color,
        emoji:'❄️', gradientColors:const[Color(0xFF74b9ff),Color(0xFF0984e3)], colorMatrix:cool),
    FilterModel(type:FilterType.warm,  name:'Warm',  category:FilterCategory.color,
        emoji:'🌅', gradientColors:const[Color(0xFFf7971e),Color(0xFFffd200)], colorMatrix:warm),
    FilterModel(type:FilterType.fade,  name:'Fade',  category:FilterCategory.color,
        emoji:'🌫️', gradientColors:const[Color(0xFFB2BEC3),Color(0xFF636E72)], colorMatrix:fade),
    FilterModel(type:FilterType.neon,  name:'Neon',  category:FilterCategory.color,
        emoji:'⚡', gradientColors:const[Color(0xFF00F260),Color(0xFF0575E6)], colorMatrix:neon),
    FilterModel(type:FilterType.rose,  name:'Rose',  category:FilterCategory.color,
        emoji:'🌸', gradientColors:const[Color(0xFFFF758C),Color(0xFFFF7EB3)], colorMatrix:rose),
    FilterModel(type:FilterType.teal,  name:'Cinema',category:FilterCategory.color,
        emoji:'🎥', gradientColors:const[Color(0xFF2D6A4F),Color(0xFFD4A017)], colorMatrix:tealOrange),

    FilterModel(type:FilterType.sketch, name:'Sketch', category:FilterCategory.artistic,
        emoji:'✏️', gradientColors:const[Color(0xFFEEEEEE),Color(0xFF9E9E9E)], colorMatrix:sketch),
    FilterModel(type:FilterType.glitch, name:'Glitch', category:FilterCategory.artistic,
        emoji:'🔌', gradientColors:const[Color(0xFF8E2DE2),Color(0xFF4A00E0)], colorMatrix:glitch),
    const FilterModel(type:FilterType.vignette,name:'Vignette',category:FilterCategory.artistic,
        emoji:'🌑', gradientColors:[Color(0xFF1A1A1A),Color(0xFF444444)]),

    const FilterModel(type:FilterType.beautySmooth,name:'Beauty',category:FilterCategory.faceAR,
        emoji:'💄', gradientColors:[Color(0xFFFFB6C1),Color(0xFFFF69B4)]),
    const FilterModel(type:FilterType.dogEars,    name:'Dog',   category:FilterCategory.faceAR,
        emoji:'🐶', gradientColors:[Color(0xFFD2691E),Color(0xFFFFD700)]),
    const FilterModel(type:FilterType.sunglasses, name:'Shades',category:FilterCategory.faceAR,
        emoji:'😎', gradientColors:[Color(0xFF2C3E50),Color(0xFF3498DB)]),
    const FilterModel(type:FilterType.rainbow,    name:'Rainbow',category:FilterCategory.faceAR,
        emoji:'🌈', gradientColors:[Color(0xFFFF0000),Color(0xFF8B00FF)]),
    const FilterModel(type:FilterType.heartEyes,  name:'Love',  category:FilterCategory.faceAR,
        emoji:'😍', gradientColors:[Color(0xFFFF416C),Color(0xFFFF4B2B)]),

    FilterModel(type:FilterType.dreamy,   name:'Dreamy ✨',category:FilterCategory.mood,
        emoji:'💭', gradientColors:const[Color(0xFFA8EDEA),Color(0xFFFED6E3)], colorMatrix:dreamy),
    FilterModel(type:FilterType.infrared, name:'Infrared',  category:FilterCategory.mood,
        emoji:'🔴', gradientColors:const[Color(0xFF200122),Color(0xFF6f0000)], colorMatrix:infrared),
    FilterModel(type:FilterType.oilPaint, name:'OilPaint',  category:FilterCategory.mood,
        emoji:'🎨', gradientColors:const[Color(0xFF834d9b),Color(0xFFd04ed6)], colorMatrix:oilPaint),
    FilterModel(type:FilterType.pixelSort,name:'PixelSort', category:FilterCategory.mood,
        emoji:'🔷', gradientColors:const[Color(0xFF1FA2FF),Color(0xFF12D8FA)], colorMatrix:pixelSort),
  ];
}
