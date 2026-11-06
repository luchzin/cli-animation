import 'dart:math' as math;

import 'package:cli_animation/animation.dart';

class _Particle {
  _Particle(this.x, this.y, this.vx, this.vy, this.life, this.char);
  double x;
  double y;
  double vx;
  double vy;
  int life;
  final String char;
}

/// A 2D physics particle fountain node with gravity, drag, and spark emission.
class ParticleFountainAnimation extends Animation {
  ParticleFountainAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    this.rows = 8,
    this.cols = 35,
    super.speed = const Duration(milliseconds: 50),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.yellow,
  });

  final int rows;
  final int cols;
  final math.Random _rng = math.Random();
  final List<_Particle> _particles = [];

  static const _sparks = ['*', '·', '°', '•', '+', 'x'];

  @override
  int get width => cols;

  @override
  int get height => rows;

  @override
  void tick() {
    final spawnCount = 2 + _rng.nextInt(3);
    for (var i = 0; i < spawnCount; i++) {
      _particles.add(
        _Particle(
          cols / 2 + (_rng.nextDouble() - 0.5) * 2,
          rows.toDouble() - 1,
          (_rng.nextDouble() - 0.5) * 1.8,
          -(1.4 + _rng.nextDouble() * 0.9),
          12 + _rng.nextInt(8),
          _sparks[_rng.nextInt(_sparks.length)],
        ),
      );
    }

    const gravity = 0.16;
    const airResistance = 0.96;

    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy += gravity;
      p.vx *= airResistance;
      p.life--;

      if (p.life <= 0 || p.y >= rows || p.x < 0 || p.x >= cols) {
        _particles.removeAt(i);
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    // Draw base nozzle platform
    final mid = cols ~/ 2;
    ctx.setPixel(mid - 1, rows - 1, '[', color: color, z: zIndex.toDouble());
    ctx.setPixel(mid, rows - 1, '┴', color: color, z: zIndex.toDouble());
    ctx.setPixel(mid + 1, rows - 1, ']', color: color, z: zIndex.toDouble());

    // Draw particles
    for (final p in _particles) {
      final px = p.x.round();
      final py = p.y.round();

      if (py >= 0 && py < rows && px >= 0 && px < cols) {
        final char = p.vy.abs() < 0.3 ? '✧' : p.char;
        ctx.setPixel(px, py, char, color: color, z: zIndex.toDouble());
      }
    }
  }
}
