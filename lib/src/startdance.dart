import 'dart:math';

import 'package:cli_animation/animation.dart';

class Rotating3DStarAnimation extends Animation {
  Rotating3DStarAnimation({
    super.speed = const Duration(milliseconds: 40),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.yellow,
    this.width = 50,
  });

  final int width;
  double _angleX = 0;
  double _angleY = 0;
  double _angleZ = 0;

  // 3D coordinates for a 5-pointed star
  late final List<List<double>> _starNodes;

  @override
  int get height => 1;

  @override
  void onStart() {
    _starNodes = _generate3DStarNodes();
  }

  List<List<double>> _generate3DStarNodes() {
    final nodes = <List<double>>[];
    const outerRadius = 1.0;
    const innerRadius = 0.4;
    const thickness = 0.3; // Gives depth in 3D

    for (var i = 0; i < 10; i++) {
      final angle = (i * pi) / 5;
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = r * sin(angle);
      final y = -r * cos(angle);

      // Front vertices and Back vertices for 3D depth
      nodes.add([x, y, thickness]);
      nodes.add([x, y, -thickness]);
    }
    return nodes;
  }

  @override
  void tick() {
    _angleX += 0.06;
    _angleY += 0.08;
    _angleZ += 0.04;

    // Buffer array initialized with spaces
    final lineBuffer = List<String>.filled(width, ' ');
    final zBuffer = List<double>.filled(width, double.negativeInfinity);

    // Rotation parameters
    final cosX = cos(_angleX), sinX = sin(_angleX);
    final cosY = cos(_angleY), sinY = sin(_angleY);
    final cosZ = cos(_angleZ), sinZ = sin(_angleZ);

    for (final node in _starNodes) {
      final x = node[0];
      final y = node[1];
      final z = node[2];

      // 1. 3D Rotation Matrix Transformation
      // Rotate around X
      final y1 = y * cosX - z * sinX;
      final z1 = y * sinX + z * cosX;

      // Rotate around Y
      final x2 = x * cosY + z1 * sinY;
      final z2 = -x * sinY + z1 * cosY;

      // Rotate around Z
      final x3 = x2 * cosZ - y1 * sinZ;
      final y3 = x2 * sinZ + y1 * cosZ;

      // 2. Perspective Projection onto 1D line with Z-depth buffer
      final distance = 3.0;
      final ooz = 1 / (z2 + distance); // One over Z for depth perspective

      // Screen coordinate mapping
      final screenX = ((width / 2) + x3 * ooz * (width / 2)).round();

      if (screenX >= 0 && screenX < width) {
        // Z-Buffer check to handle foreground over background rendering
        if (ooz > zBuffer[screenX]) {
          zBuffer[screenX] = ooz;

          // Luminance / Depth Shading
          if (ooz > 0.40) {
            lineBuffer[screenX] = '★'; // Foreground bright star
          } else if (ooz > 0.30) {
            lineBuffer[screenX] = '✦'; // Medium depth
          } else {
            lineBuffer[screenX] = '•'; // Background dim star
          }
        }
      }
    }

    write(lineBuffer.join());
  }
}
