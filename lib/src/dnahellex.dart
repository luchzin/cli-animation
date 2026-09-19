import 'dart:math' as math;

import 'package:cli_animation/animation.dart';

class DnaHelixAnimation extends Animation {
  DnaHelixAnimation({
    this.rows = 8,
    this.width = 24,
    super.speed = const Duration(milliseconds: 60),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.cyan,
  });

  final int rows;
  final int width;
  double _phase = 0.0;

  @override
  int get height => rows;

  @override
  void tick() {
    final buffer = StringBuffer();
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

      final rowChars = List<String>.filled(width, ' ');

      // Base pair rungs: only draw if strands aren't occluding
      if (right - left > 2) {
        final rungChar = cosVal.abs() > 0.5 ? '=' : '-';
        for (var c = left + 1; c < right; c++) {
          rowChars[c] = rungChar;
        }
      }

      // Nodes with pseudo-depth: bold/large when in front, dim when behind
      final node1 = cosVal >= 0 ? '●' : '·';
      final node2 = cosVal < 0 ? '●' : '·';

      rowChars[p1] = node1;
      rowChars[p2] = node2;

      buffer.write(rowChars.join());
      if (r < rows - 1) buffer.write('\n');
    }

    write(buffer.toString());
    _phase += 0.15;
  }
}