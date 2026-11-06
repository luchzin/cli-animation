import 'dart:math' as math;

import 'package:cli_animation/animation.dart';

/// A 3D rotating torus (donut) node projected onto a 2D [CanvasContext2D].
class DonutAnimation extends Animation {
  DonutAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    super.speed = const Duration(milliseconds: 30),
    super.duration,
    super.loop = true,
    this.width = 40,
    this.height = 20,
  });

  @override
  final int width;
  @override
  final int height;

  double _a = 0.0;
  double _b = 0.0;

  static const List<AnsiColor> _gradient = [
    AnsiColor.magenta,
    AnsiColor.blue,
    AnsiColor.cyan,
    AnsiColor.green,
    AnsiColor.yellow,
    AnsiColor.red,
  ];

  @override
  void tick() {
    _a += 0.07;
    _b += 0.03;
  }

  @override
  void draw(CanvasContext2D ctx) {
    final zBuffer = List<double>.filled(width * height, 0.0);

    const r1 = 1.0;
    const r2 = 2.0;
    const k2 = 5.0;
    final k1 = width * k2 * 3 / (8 * (r1 + r2));

    final cosA = math.cos(_a);
    final sinA = math.sin(_a);
    final cosB = math.cos(_b);
    final sinB = math.sin(_b);

    for (var theta = 0.0; theta < 2 * math.pi; theta += 0.07) {
      final cosTheta = math.cos(theta);
      final sinTheta = math.sin(theta);

      for (var phi = 0.0; phi < 2 * math.pi; phi += 0.02) {
        final cosPhi = math.cos(phi);
        final sinPhi = math.sin(phi);

        final circleX = r2 + r1 * cosTheta;
        final circleY = r1 * sinTheta;

        final tx =
            circleX * (cosB * cosPhi + sinA * sinB * sinPhi) -
            circleY * cosA * sinB;
        final ty =
            circleX * (sinB * cosPhi - sinA * cosB * sinPhi) +
            circleY * cosA * cosB;
        final tz = k2 + cosA * circleX * sinPhi + circleY * sinA;
        final ooz = 1 / tz;

        final xp = (width / 2 + k1 * ooz * tx).toInt();
        final yp = (height / 2 - k1 * ooz * ty / 2).toInt();

        final l =
            cosPhi * cosTheta * sinB -
            cosA * cosTheta * sinPhi -
            sinA * sinTheta +
            cosB * (cosA * sinTheta - cosTheta * sinA * sinPhi);

        if (l > 0 && xp >= 0 && xp < width && yp >= 0 && yp < height) {
          final idx = xp + yp * width;
          if (ooz > zBuffer[idx]) {
            zBuffer[idx] = ooz;
            final luminanceIdx = (l * 8).toInt();
            const chars = '.,-~:;=!*#\$@';
            final char = chars[luminanceIdx.clamp(0, chars.length - 1)];
            final rowColor = _gradient[yp % _gradient.length];

            ctx.setPixel(
              xp,
              yp,
              char,
              color: rowColor,
              z: zIndex.toDouble() + ooz,
            );
          }
        }
      }
    }
  }
}
