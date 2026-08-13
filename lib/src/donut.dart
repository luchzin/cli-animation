import 'dart:math' as math;
import 'package:cli_animation/animation.dart';

class DonutAnimation extends Animation {
  DonutAnimation({
    super.speed = const Duration(milliseconds: 30), // ~30 FPS
    super.duration,
    super.loop = true,
    this.width = 40,
    this.height = 20,
  });

  final int width;
  @override
  final int height;
  // Rotation angles for the 3D donut
  double _a = 0.0;
  double _b = 0.0;

  // Gradient colors to apply across the donut lines
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
    // Increment rotation angles
    _a += 0.07;
    _b += 0.03;

    final frame = _renderDonutFrame();

    // Write frame directly to terminal
    write(frame);
  }

  String _renderDonutFrame() {
    final buffer = List<String>.filled(width * height, ' ');
    final zBuffer = List<double>.filled(width * height, 0.0);

    // Torus math constants
    const r1 = 1.0; // Inner radius
    const r2 = 2.0; // Distance from center
    const k2 = 5.0; // Distance from viewer
    final k1 = width * k2 * 3 / (8 * (r1 + r2));

    // Calculate 3D points
    for (var theta = 0.0; theta < 2 * math.pi; theta += 0.07) {
      final cosTheta = math.cos(theta);
      final sinTheta = math.sin(theta);

      for (var phi = 0.0; phi < 2 * math.pi; phi += 0.02) {
        final cosPhi = math.cos(phi);
        final sinPhi = math.sin(phi);

        final cosA = math.cos(_a);
        final sinA = math.sin(_a);
        final cosB = math.cos(_b);
        final sinB = math.sin(_b);

        final circleX = r2 + r1 * cosTheta;
        final circleY = r1 * sinTheta;

        // 3D coordinates after rotation
        final x =
            circleX * (cosB * cosPhi + sinA * sinB * sinPhi) -
            circleY * cosA * sinB;
        final y =
            circleX * (sinB * cosPhi - sinA * cosB * sinPhi) +
            circleY * cosA * cosB;
        final z = k2 + cosA * circleX * sinPhi + circleY * sinA;
        final ooz = 1 / z;

        // Screen projection coordinates
        final xp = (width / 2 + k1 * ooz * x).toInt();
        final yp = (height / 2 - k1 * ooz * y / 2).toInt();

        // Calculate illumination / shading
        final l =
            cosPhi * cosTheta * sinB -
            cosA * cosTheta * sinPhi -
            sinA * sinTheta +
            cosB * (cosA * sinTheta - cosTheta * sinA * sinPhi);

        if (l > 0) {
          if (xp >= 0 && xp < width && yp >= 0 && yp < height) {
            final idx = xp + yp * width;
            if (ooz > zBuffer[idx]) {
              zBuffer[idx] = ooz;

              // Map luminance to ASCII chars
              final luminanceIdx = (l * 8).toInt();
              const chars = '.,-~:;=!*#\$@';
              final char = chars[luminanceIdx.clamp(0, chars.length - 1)];

              buffer[idx] = char;
            }
          }
        }
      }
    }

    // Assemble the 2D buffer into colorized rows
    final output = StringBuffer();
    for (var y = 0; y < height; y++) {
      final color = _gradient[y % _gradient.length];
      output.write(color);
      for (var x = 0; x < width; x++) {
        output.write(buffer[x + y * width]);
      }
      output.write(AnsiColor.reset);
      if (y < height - 1) output.write('\n');
    }

    return output.toString();
  }
}
