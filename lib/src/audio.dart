import 'dart:math';

import 'package:cli_animation/animation.dart';

/// A 2D Audio Visualizer node with spring-damper bar physics and floating peak caps.
class AudioVisualizerAnimation extends Animation {
  AudioVisualizerAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    this.bars = 16,
    this.maxHeight = 6,
    super.speed = const Duration(milliseconds: 60),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.cyan,
  }) : _levels = List.filled(bars, 0.0),
       _velocities = List.filled(bars, 0.0),
       _peaks = List.filled(bars, 0.0);

  final int bars;
  final int maxHeight;
  final List<double> _levels;
  final List<double> _velocities;
  final List<double> _peaks;
  final Random _rnd = Random();
  double _phase = 0.0;

  static const _blocks = [' ', ' ', '▂', '▃', '▄', '▅', '▆', '▇', '█'];

  @override
  int get width => bars * 2;

  @override
  int get height => maxHeight;

  @override
  void tick() {
    _phase += 0.2;

    for (var i = 0; i < bars; i++) {
      final wave = sin(_phase + (i * 0.45)) * 0.5 + 0.5;
      final noise = _rnd.nextDouble() * 0.4;
      final target = ((wave * 0.7 + noise) * maxHeight).clamp(
        0.0,
        maxHeight.toDouble(),
      );

      _velocities[i] = (_velocities[i] + (target - _levels[i]) * 0.4) * 0.65;
      _levels[i] = (_levels[i] + _velocities[i]).clamp(
        0.0,
        maxHeight.toDouble(),
      );

      if (_levels[i] >= _peaks[i]) {
        _peaks[i] = _levels[i];
      } else {
        _peaks[i] = max(0.0, _peaks[i] - 0.15);
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    for (var r = maxHeight - 1; r >= 0; r--) {
      final screenY = (maxHeight - 1) - r;

      for (var b = 0; b < bars; b++) {
        final screenX = b * 2;
        final level = _levels[b];
        final peakRow = _peaks[b].floor();

        if (r < level.floor()) {
          ctx.setPixel(screenX, screenY, '█', color: color, z: zIndex.toDouble());
        } else if (r == level.floor()) {
          final fraction = ((level - level.floor()) * 8).round().clamp(0, 8);
          final ch = _blocks[fraction];
          if (ch != ' ') {
            ctx.setPixel(screenX, screenY, ch, color: color, z: zIndex.toDouble());
          }
        } else if (r == peakRow && _peaks[b] > 0.5) {
          ctx.setPixel(
            screenX,
            screenY,
            '▔',
            color: AnsiColor.yellow,
            z: zIndex.toDouble(),
          );
        }
      }
    }
  }
}
