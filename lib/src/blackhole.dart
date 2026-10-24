import 'dart:math' as math;

import 'package:cli_animation/animation.dart';

class _MatterParticle {
  _MatterParticle(this.radius, this.phi, this.angularSpeed, this.brightness);

  final double radius;
  final double phi;
  final double angularSpeed;
  final double brightness;
}

class _JetParticle {
  _JetParticle(this.xOffset, this.yDistance, this.speed, this.direction);

  final double xOffset;
  double yDistance;
  final double speed;
  final double direction; // -1 for North jet, +1 for South jet
}

/// A general-relativistic Black Hole animation featuring:
/// - A central Event Horizon (singularity shadow)
/// - A photon sphere boundary ring
/// - A swirling accretion disk with Keplerian differential rotation
/// - Relativistic Doppler beaming (bright approaching side, dim redshifted side)
/// - Gravitational lensing (rear disk warped above & below the horizon)
/// - Relativistic astrophysical plasma jets erupting from the poles
class BlackHoleAnimation extends Animation {
  BlackHoleAnimation({
    this.rows = 11,
    this.cols = 45,
    this.showJets = true,
    super.speed = const Duration(milliseconds: 50),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.cyan,
  }) {
    _initSimulation();
  }

  final int rows;
  final int cols;
  final bool showJets;

  double _phase = 0.0;
  final math.Random _rng = math.Random(42);
  final List<_MatterParticle> _particles = [];
  final List<_JetParticle> _jets = [];

  static const double _charAspect = 2.0; // Terminal char height/width ratio

  @override
  int get height => rows;

  void _initSimulation() {
    _particles.clear();
    _jets.clear();

    // 1. Accretion disk matter packets
    const particleCount = 280;
    for (var i = 0; i < particleCount; i++) {
      final u = _rng.nextDouble();
      // Density falls off with radius, higher concentration near ISCO
      final r = 3.3 + math.pow(u, 1.5) * 12.0;
      final phi = _rng.nextDouble() * 2 * math.pi;
      // Keplerian angular velocity: v ~ r^-0.75
      final angularSpeed = 1.85 / math.pow(r, 0.75);
      final brightness = 0.8 + _rng.nextDouble() * 0.4;
      _particles.add(_MatterParticle(r, phi, angularSpeed, brightness));
    }

    // 2. Polar plasma jets
    if (showJets) {
      const jetCount = 24;
      for (var i = 0; i < jetCount; i++) {
        final isNorth = (i % 2 == 0);
        final dir = isNorth ? -1.0 : 1.0;
        final yDist = 3.2 + _rng.nextDouble() * 7.5;
        final speed = 0.4 + _rng.nextDouble() * 0.35;
        final xOffset = (_rng.nextDouble() - 0.5) * 0.7;
        _jets.add(_JetParticle(xOffset, yDist * dir, speed * dir, dir));
      }
    }
  }

  @override
  void tick() {
    _phase += 0.08;

    final cx = cols / 2.0;
    final cy = rows / 2.0;

    final grid = List.generate(rows, (_) => List.filled(cols, ' '));
    final colorGrid = List.generate(rows, (_) => List.filled(cols, ''));
    final depthGrid = List.generate(rows, (_) => List.filled(cols, -999.0));

    // Tilt angle of the accretion disk relative to observer
    const tilt = 0.36; // ~20 degrees
    final cosTilt = math.cos(tilt);
    final sinTilt = math.sin(tilt);

    // 1. Render Swirling Accretion Disk Matter
    for (final p in _particles) {
      final currentPhi = p.phi + p.angularSpeed * _phase;
      final x3d = p.radius * math.cos(currentPhi);
      final y3d = p.radius * math.sin(currentPhi);

      // Rotate disk into observer coordinate frame
      final yTilted = y3d * cosTilt;
      final zTilted = y3d * sinTilt;

      // Relativistic Doppler beaming:
      // Approaching side (moving toward viewer) is intensely boosted;
      // Receding side (moving away from viewer) is redshifted and dimmer.
      final vLos = -math.sin(currentPhi) * cosTilt;
      final dopplerFactor = (1.0 + vLos * 0.95).clamp(0.12, 2.2);

      // Gravitational lensing:
      // Light from the rear disk (zTilted < -0.4) is bent by spacetime curvature
      // over the top (if yTilted >= 0) and under the bottom (if yTilted < 0)
      var screenY = yTilted;
      final isBehind = zTilted < -0.4;
      if (isBehind) {
        final r2d = math.sqrt(x3d * x3d + yTilted * yTilted);
        if (r2d > 0.1) {
          final lensedDeflection = 4.3 / (r2d * 0.45 + 0.6);
          screenY += (yTilted >= 0 ? lensedDeflection : -lensedDeflection);
        }
      }

      final px = (cx + x3d).round();
      final py = (cy + screenY / _charAspect).round();

      if (px >= 0 && px < cols && py >= 0 && py < rows) {
        final distToHole = math.sqrt(x3d * x3d + screenY * screenY);
        // Event Horizon occlusion: front shadow swallows foreground matter
        if (distToHole < 2.4 && !isBehind) {
          continue;
        }

        final luminance =
            dopplerFactor * (1.25 - (p.radius / 16.0) * 0.45) * p.brightness;

        String char;
        String clr;

        if (luminance > 1.45) {
          char = '█';
          clr = AnsiColor.white.code;
        } else if (luminance > 1.1) {
          char = '#';
          clr = AnsiColor.cyan.code;
        } else if (luminance > 0.75) {
          char = '*';
          clr = color.code;
        } else if (luminance > 0.5) {
          char = '•';
          clr = color.code;
        } else if (luminance > 0.28) {
          char = '·';
          clr = AnsiColor.magenta.code;
        } else {
          char = '.';
          clr = AnsiColor.red.code;
        }

        if (zTilted > depthGrid[py][px]) {
          depthGrid[py][px] = zTilted;
          grid[py][px] = char;
          colorGrid[py][px] = clr;
        }
      }
    }

    // 2. Render Relativistic Polar Jets
    if (showJets) {
      for (final j in _jets) {
        j.yDistance += j.speed;
        if (j.direction < 0 && j.yDistance < -8.5) {
          j.yDistance = -3.2;
        } else if (j.direction > 0 && j.yDistance > 8.5) {
          j.yDistance = 3.2;
        }

        final px = (cx + j.xOffset).round();
        final py = (cy + j.yDistance / _charAspect).round();

        if (px >= 0 && px < cols && py >= 0 && py < rows) {
          if (depthGrid[py][px] < 0.2) {
            grid[py][px] = (j.direction < 0) ? '▲' : '▼';
            colorGrid[py][px] = AnsiColor.blue.code;
          }
        }
      }
    }

    // 3. Render Event Horizon (Shadow) & Photon Sphere Ring
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final dx = (c - cx);
        final dy = (r - cy) * _charAspect;
        final d = math.sqrt(dx * dx + dy * dy);

        if (d <= 2.2) {
          // Singularity shadow
          grid[r][c] = ' ';
          colorGrid[r][c] = '';
        }
      }
    }

    // Draw silhouette boundary and photon sphere marker at horizon edge
    final rowCenter = cy.round();
    final leftHorizon = (cx - 3).round();
    final rightHorizon = (cx + 3).round();

    if (leftHorizon >= 0 && leftHorizon < cols && rowCenter < rows) {
      grid[rowCenter][leftHorizon] = '(';
      colorGrid[rowCenter][leftHorizon] = AnsiColor.yellow.code;
    }
    if (rightHorizon >= 0 && rightHorizon < cols && rowCenter < rows) {
      grid[rowCenter][rightHorizon] = ')';
      colorGrid[rowCenter][rightHorizon] = AnsiColor.yellow.code;
    }

    // Assemble frame buffer
    final buffer = StringBuffer();
    for (var r = 0; r < rows; r++) {
      final lineBuffer = StringBuffer();
      for (var c = 0; c < cols; c++) {
        final clr = colorGrid[r][c];
        if (clr.isNotEmpty) {
          lineBuffer.write('$clr${grid[r][c]}${AnsiColor.reset}');
        } else {
          lineBuffer.write(grid[r][c]);
        }
      }
      buffer.write(lineBuffer.toString());
      if (r < rows - 1) buffer.write('\n');
    }

    write(buffer.toString());
  }
}
