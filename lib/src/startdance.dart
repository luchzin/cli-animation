import 'dart:math';

import 'package:cli_animation/animation.dart';

/// A 3D rotating star node projected onto a 2D canvas line with depth shading.
class Rotating3DStarAnimation extends Animation {
  Rotating3DStarAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    super.speed = const Duration(milliseconds: 40),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.yellow,
    this.width = 50,
  }) : _starNodes = _generate3DStarNodes();

  @override
  final int width;
  double _angleX = 0;
  double _angleY = 0;
  double _angleZ = 0;

  final List<List<double>> _starNodes;

  @override
  int get height => 1;

  static List<List<double>> _generate3DStarNodes() {
    final nodes = <List<double>>[];
    const outerRadius = 1.0;
    const innerRadius = 0.4;
    const thickness = 0.3;

    for (var i = 0; i < 10; i++) {
      final angle = (i * pi) / 5;
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final vx = r * sin(angle);
      final vy = -r * cos(angle);

      nodes.add([vx, vy, thickness]);
      nodes.add([vx, vy, -thickness]);
    }
    return nodes;
  }

  @override
  void tick() {
    _angleX += 0.06;
    _angleY += 0.08;
    _angleZ += 0.04;
  }

  @override
  void draw(CanvasContext2D ctx) {
    final zBuffer = List<double>.filled(width, double.negativeInfinity);
    final cosX = cos(_angleX), sinX = sin(_angleX);
    final cosY = cos(_angleY), sinY = sin(_angleY);
    final cosZ = cos(_angleZ), sinZ = sin(_angleZ);

    for (final node in _starNodes) {
      final nx = node[0];
      final ny = node[1];
      final nz = node[2];

      final y1 = ny * cosX - nz * sinX;
      final z1 = ny * sinX + nz * cosX;

      final x2 = nx * cosY + z1 * sinY;
      final z2 = -nx * sinY + z1 * cosY;

      final x3 = x2 * cosZ - y1 * sinZ;

      const distance = 3.0;
      final ooz = 1 / (z2 + distance);
      final screenX = ((width / 2) + x3 * ooz * (width / 2)).round();

      if (screenX >= 0 && screenX < width) {
        if (ooz > zBuffer[screenX]) {
          zBuffer[screenX] = ooz;

          String char;
          if (ooz > 0.40) {
            char = '★';
          } else if (ooz > 0.30) {
            char = '✦';
          } else {
            char = '•';
          }
          ctx.setPixel(screenX, 0, char, color: color, z: zIndex + ooz);
        }
      }
    }
  }
}
