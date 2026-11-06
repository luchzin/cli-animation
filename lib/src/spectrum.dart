import 'dart:math';

import 'package:cli_animation/animation.dart';

/// A live audio spectrum analyzer node with title banner and dual-row sub-block bars.
class SpectrumAnimation extends Animation {
  SpectrumAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    this.label = 'Audio Stream',
    this.barCount = 20,
    super.speed = const Duration(milliseconds: 60),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.cyan,
  }) : _levels = List.filled(barCount, 0),
       _targets = List.filled(barCount, 0);

  final String label;
  final int barCount;
  final Random _rng = Random();

  @override
  int get width => max(barCount * 2, label.length + 10);

  @override
  int get height => 3;

  final List<int> _levels;
  final List<int> _targets;

  static const _subBlocks = [' ', ' ', '▂', '▃', '▄', '▅', '▆', '▇', '█'];
  static const int _maxResolution = 16;

  @override
  void tick() {
    for (var i = 0; i < barCount; i++) {
      if (_levels[i] == _targets[i] || _rng.nextDouble() < 0.15) {
        _targets[i] = _rng.nextInt(_maxResolution + 1);
      }

      if (_levels[i] < _targets[i]) {
        _levels[i]++;
      } else if (_levels[i] > _targets[i]) {
        _levels[i]--;
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawText(0, 0, '♫ $label [LIVE]', color: color, z: zIndex.toDouble());

    for (var i = 0; i < barCount; i++) {
      final val = _levels[i];
      final col = i * 2;

      if (val > 8) {
        ctx.setPixel(col, 2, _subBlocks[8], color: color, z: zIndex.toDouble());
        final topChar = _subBlocks[val - 8];
        if (topChar != ' ') {
          ctx.setPixel(col, 1, topChar, color: color, z: zIndex.toDouble());
        }
      } else {
        final bottomChar = _subBlocks[val];
        if (bottomChar != ' ') {
          ctx.setPixel(col, 2, bottomChar, color: color, z: zIndex.toDouble());
        }
      }
    }
  }
}
