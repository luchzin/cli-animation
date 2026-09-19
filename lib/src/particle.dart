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

class ParticleFountainAnimation extends Animation {
  ParticleFountainAnimation({
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
  int get height => rows;

  @override
  void tick() {
    // 1. Emit 2-4 new particles per frame from bottom center
    final spawnCount = 2 + _rng.nextInt(3);
    for (var i = 0; i < spawnCount; i++) {
      _particles.add(
        _Particle(
          cols / 2 + (_rng.nextDouble() - 0.5) * 2, // slight horizontal nozzle spread
          rows.toDouble() - 1,                      // nozzle at ground
          (_rng.nextDouble() - 0.5) * 1.8,          // lateral velocity
          -(1.4 + _rng.nextDouble() * 0.9),         // upward initial thrust
          12 + _rng.nextInt(8),                     // lifespan in frames
          _sparks[_rng.nextInt(_sparks.length)],
        ),
      );
    }

    // 2. Physics step: update position, gravity, air drag, and age
    const gravity = 0.16;
    const airResistance = 0.96;

    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy += gravity;
      p.vx *= airResistance;
      p.life--;

      // Remove particles if dead or out of bounds
      if (p.life <= 0 || p.y >= rows || p.x < 0 || p.x >= cols) {
        _particles.removeAt(i);
      }
    }

    // 3. Render to grid
    final grid = List.generate(rows, (_) => List.filled(cols, ' '));

    // Draw particle trail / density
    for (final p in _particles) {
      final px = p.x.round();
      final py = p.y.round();

      if (py >= 0 && py < rows && px >= 0 && px < cols) {
        // Particles near the apex show lighter symbols
        if (p.vy.abs() < 0.3) {
          grid[py][px] = '✧';
        } else {
          grid[py][px] = p.char;
        }
      }
    }

    // Draw base nozzle platform
    final mid = cols ~/ 2;
    if (grid[rows - 1][mid - 1] == ' ') grid[rows - 1][mid - 1] = '[';
    if (grid[rows - 1][mid] == ' ') grid[rows - 1][mid] = '┴';
    if (grid[rows - 1][mid + 1] == ' ') grid[rows - 1][mid + 1] = ']';

    write(grid.map((r) => r.join()).join('\n'));
  }
}