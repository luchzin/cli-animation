import 'dart:math' as math;

import 'package:cli_animation/animation.dart';

/// A rotating double-helix DNA strand node rendered onto a 2D [CanvasContext2D].
class DnaHelixAnimation extends Animation {
  DnaHelixAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    this.rows = 8,
    this.width = 24,
    super.speed = const Duration(milliseconds: 60),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.cyan,
  });

  final int rows;
  @override
  final int width;
  double _phase = 0.0;

  @override
  int get height => rows;

  @override
  void tick() {
    _phase += 0.15;
  }

  @override
  void draw(CanvasContext2D ctx) {
    final mid = width ~/ 2;
    final amplitude = (width - 4) ~/ 2;

    for (var r = 0; r < rows; r++) {
      final angle = _phase + (r * 0.45);
      final sinVal = math.sin(angle);
      final cosVal = math.cos(angle);

      final p1 = (mid + sinVal * amplitude).round();
      final p2 = (mid - sinVal * amplitude).round();

      final left = math.min(p1, p2);
      final right = math.max(p1, p2);

      if (right - left > 2) {
        final rungChar = cosVal.abs() > 0.5 ? '=' : '-';
        for (var c = left + 1; c < right; c++) {
          ctx.setPixel(c, r, rungChar, color: color, z: zIndex.toDouble());
        }
      }

      final node1 = cosVal >= 0 ? '●' : '·';
      final node2 = cosVal < 0 ? '●' : '·';

      ctx.setPixel(p1, r, node1, color: color, z: zIndex.toDouble());
      ctx.setPixel(p2, r, node2, color: color, z: zIndex.toDouble());
    }
  }
}
