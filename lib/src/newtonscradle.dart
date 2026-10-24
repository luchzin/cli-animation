import 'dart:math' as math;

import 'package:cli_animation/animation.dart';

/// A sleek, physics-based Newton's Cradle terminal animation.
///
/// Features conservation of momentum physics:
/// - The left sphere swings out and strikes the group.
/// - Momentum travels through the stationary center spheres.
/// - The right sphere launches out in response, then swings back.
/// - Crisp, minimalist ASCII geometry with impact flashes.
class NewtonsCradleAnimation extends Animation {
  NewtonsCradleAnimation({
    this.balls = 5,
    this.stringLength = 4,
    super.speed = const Duration(milliseconds: 45),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.cyan,
  });

  final int balls;
  final int stringLength;

  double _phase = 0.0;

  // Frame height: 1 top bar + string lines + 1 sphere line
  @override
  int get height => stringLength + 2;

  @override
  void tick() {
    _phase += 0.16;

    // Harmonic pendulum swing
    final sinVal = math.sin(_phase);
    final cosVal = math.cos(_phase);

    // Left ball swings when sinVal < 0; right ball swings when sinVal > 0
    final leftSwing = sinVal < 0 ? -sinVal : 0.0;
    final rightSwing = sinVal > 0 ? sinVal : 0.0;

    // Impact occurs when passing through center at high velocity
    final isImpact = sinVal.abs() < 0.18 && cosVal.abs() > 0.8;

    const width = 31;
    final buffer = StringBuffer();

    // 1. Top mounting bar
    final bar = '═' * (width - 4);
    buffer.writeln('  $bar  ');

    // Pivot X positions for 5 balls (centered at 7, 11, 15, 19, 23)
    const spacing = 4.0;
    const centerPivot = 15.0;
    final startPivot = centerPivot - ((balls - 1) / 2.0) * spacing;
    final pivots = List.generate(balls, (i) => startPivot + i * spacing);

    const maxSwingOffset = 6.0;

    // 2. Suspension strings (rows 1 to stringLength)
    for (var r = 1; r <= stringLength; r++) {
      final line = List.filled(width, ' ');
      final fraction = r / stringLength;

      for (var b = 0; b < balls; b++) {
        var x = pivots[b];
        if (b == 0) {
          x -= leftSwing * maxSwingOffset * fraction;
        } else if (b == balls - 1) {
          x += rightSwing * maxSwingOffset * fraction;
        }

        final col = x.round().clamp(0, width - 1);
        String char;
        if (b == 0 && leftSwing > 0.1) {
          char = '\\';
        } else if (b == balls - 1 && rightSwing > 0.1) {
          char = '/';
        } else {
          char = '|';
        }
        line[col] = char;
      }
      buffer.writeln(line.join());
    }

    // 3. Spheres row at the bottom
    final sphereLine = List.filled(width, ' ');
    final colorMap = List.filled(width, '');

    for (var b = 0; b < balls; b++) {
      var x = pivots[b];
      if (b == 0) {
        x -= leftSwing * maxSwingOffset;
      } else if (b == balls - 1) {
        x += rightSwing * maxSwingOffset;
      }

      final col = x.round();
      if (col >= 1 && col + 1 < width) {
        sphereLine[col - 1] = '(';
        sphereLine[col] = '●';
        sphereLine[col + 1] = ')';

        // Highlight swinging balls with bright white/yellow
        if ((b == 0 && leftSwing > 0.1) ||
            (b == balls - 1 && rightSwing > 0.1)) {
          colorMap[col] = AnsiColor.white.code;
        } else if (isImpact) {
          // Moment of impact flash
          colorMap[col] = AnsiColor.yellow.code;
        }
      }
    }

    // Assemble colored sphere row
    final sphereBuffer = StringBuffer();
    for (var c = 0; c < width; c++) {
      final clr = colorMap[c];
      if (clr.isNotEmpty) {
        sphereBuffer.write('$clr${sphereLine[c]}${AnsiColor.reset}$color');
      } else {
        sphereBuffer.write(sphereLine[c]);
      }
    }
    buffer.write(sphereBuffer.toString());

    write(buffer.toString());
  }
}
