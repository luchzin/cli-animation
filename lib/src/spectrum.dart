import 'dart:math';

import 'package:cli_animation/animation.dart';

class SpectrumAnimation extends Animation {
  SpectrumAnimation({
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

  // Multi-line height: 1 title line + 2 visualization lines
  @override
  int get height => 3;

  final List<int> _levels;
  final List<int> _targets;

  // Unicode block steps for smooth vertical rendering
  static const _subBlocks = ['', ' ', '▂', '▃', '▄', '▅', '▆', '▇', '█'];
  static const int _maxResolution = 16; // 2 rows * 8 block levels

  @override
  void tick() {
    // 1. Smoothly interpolate existing levels toward random targets
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

    // 2. Render top and bottom audio waveform rows
    final topRow = StringBuffer();
    final bottomRow = StringBuffer();

    for (var i = 0; i < barCount; i++) {
      final val = _levels[i];

      if (val > 8) {
        // Bar reaches the upper row
        bottomRow.write(_subBlocks[8]);
        topRow.write(_subBlocks[val - 8]);
      } else {
        // Bar only exists in the lower row
        bottomRow.write(_subBlocks[val]);
        topRow.write(' ');
      }
      // Add a spacer between bars
      bottomRow.write(' ');
      topRow.write(' ');
    }

    // 3. Assemble the 3 distinct lines
    final frame = [
      '♫ $label [LIVE]',
      topRow.toString(),
      bottomRow.toString(),
    ].join('\n');

    write(frame);
  }
}