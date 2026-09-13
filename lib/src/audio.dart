import 'dart:math';

import 'package:cli_animation/animation.dart';

class AudioVisualizerAnimation extends Animation {
  AudioVisualizerAnimation({
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

  // Partial block characters for sub-row rendering
  static const _blocks = [' ', ' ', '▂', '▃', '▄', '▅', '▆', '▇', '█'];

  @override
  int get height => maxHeight;

  @override
  void tick() {
    _phase += 0.2;

    // Simulate audio frequencies with harmonic waves + randomized noise pulses
    for (var i = 0; i < bars; i++) {
      final wave = sin(_phase + (i * 0.45)) * 0.5 + 0.5;
      final noise = _rnd.nextDouble() * 0.4;
      final target = ((wave * 0.7 + noise) * maxHeight).clamp(
        0.0,
        maxHeight.toDouble(),
      );

      // Spring-damper physics for natural bounce
      _velocities[i] = (_velocities[i] + (target - _levels[i]) * 0.4) * 0.65;
      _levels[i] = (_levels[i] + _velocities[i]).clamp(
        0.0,
        maxHeight.toDouble(),
      );

      // Peak-meter drop logic
      if (_levels[i] >= _peaks[i]) {
        _peaks[i] = _levels[i];
      } else {
        _peaks[i] = max(0.0, _peaks[i] - 0.15); // Peak falls slower
      }
    }

    // Render from top row (maxHeight - 1) down to bottom row (0)
    final lines = <String>[];

    for (var r = maxHeight - 1; r >= 0; r--) {
      final buffer = StringBuffer();

      for (var b = 0; b < bars; b++) {
        final level = _levels[b];
        final peakRow = _peaks[b].floor();

        if (r < level.floor()) {
          // Completely filled block
          buffer.write('█ ');
        } else if (r == level.floor()) {
          // Fractional block for smooth height transitions
          final fraction = ((level - level.floor()) * 8).round().clamp(0, 8);
          buffer.write('${_blocks[fraction]} ');
        } else if (r == peakRow && _peaks[b] > 0.5) {
          // Floating peak cap (rendered in yellow/dim highlight)
          buffer.write('${AnsiColor.yellow}▔${color} ');
        } else {
          // Empty space
          buffer.write('  ');
        }
      }
      lines.add(buffer.toString());
    }

    write(lines.join('\n'));
  }
}
