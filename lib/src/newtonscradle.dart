import 'dart:math' as math;

import 'package:cli_animation/animation.dart';

/// A sleek, physics-based Newton's Cradle 2D scene node & terminal animation.
///
/// Features conservation of momentum physics:
/// - The left sphere swings out and strikes the group.
/// - Momentum travels through the stationary center spheres.
/// - The right sphere launches out in response, then swings back.
/// - Crisp, minimalist ASCII geometry with impact flashes rendered via [CanvasContext2D].
class NewtonsCradleAnimation extends Animation {
  NewtonsCradleAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
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

  @override
  int get width => 31;

  // Frame height: 1 top bar + string lines + 1 sphere line
  @override
  int get height => stringLength + 2;

  @override
  void tick() {
    _phase += 0.16;
  }

  @override
  void draw(CanvasContext2D ctx) {
    final sinVal = math.sin(_phase);
    final cosVal = math.cos(_phase);

    final leftSwing = sinVal < 0 ? -sinVal : 0.0;
    final rightSwing = sinVal > 0 ? sinVal : 0.0;
    final isImpact = sinVal.abs() < 0.18 && cosVal.abs() > 0.8;

    // 1. Top mounting bar
    final bar = '═' * (width - 4);
    ctx.drawText(2, 0, bar, color: color, z: zIndex.toDouble());

    // Pivot X positions centered across width
    const spacing = 4.0;
    const centerPivot = 15.0;
    final startPivot = centerPivot - ((balls - 1) / 2.0) * spacing;
    final pivots = List.generate(balls, (i) => startPivot + i * spacing);

    const maxSwingOffset = 6.0;

    // 2. Suspension strings (rows 1 to stringLength)
    for (var r = 1; r <= stringLength; r++) {
      final fraction = r / stringLength;

      for (var b = 0; b < balls; b++) {
        var bx = pivots[b];
        if (b == 0) {
          bx -= leftSwing * maxSwingOffset * fraction;
        } else if (b == balls - 1) {
          bx += rightSwing * maxSwingOffset * fraction;
        }

        final col = bx.round().clamp(0, width - 1);
        String char;
        if (b == 0 && leftSwing > 0.1) {
          char = '\\';
        } else if (b == balls - 1 && rightSwing > 0.1) {
          char = '/';
        } else {
          char = '|';
        }
        ctx.setPixel(col, r, char, color: color, z: zIndex.toDouble());
      }
    }

    // 3. Spheres row at the bottom
    final sphereRow = stringLength + 1;
    for (var b = 0; b < balls; b++) {
      var bx = pivots[b];
      if (b == 0) {
        bx -= leftSwing * maxSwingOffset;
      } else if (b == balls - 1) {
        bx += rightSwing * maxSwingOffset;
      }

      final col = bx.round();
      if (col >= 1 && col + 1 < width) {
        AnsiColor centerColor = color;
        if ((b == 0 && leftSwing > 0.1) ||
            (b == balls - 1 && rightSwing > 0.1)) {
          centerColor = AnsiColor.white;
        } else if (isImpact) {
          centerColor = AnsiColor.yellow;
        }

        ctx.setPixel(col - 1, sphereRow, '(', color: color, z: zIndex.toDouble());
        ctx.setPixel(col, sphereRow, '●', color: centerColor, z: zIndex.toDouble());
        ctx.setPixel(col + 1, sphereRow, ')', color: color, z: zIndex.toDouble());
      }
    }
  }
}
