import '../core/ansi_color.dart';
import '../core/context_2d.dart';
import '../core/node.dart';

/// A multi-frame ASCII sprite node that cycles through [frames] at `(x, y)`.
class SpriteNode extends Node {
  SpriteNode({
    required this.frames,
    this.frameDuration = const Duration(milliseconds: 100),
    this.loop = true,
    this.transparentSpaces = true,
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.color = AnsiColor.cyan,
    super.id,
    this.onTick,
  }) : assert(frames.isNotEmpty, 'SpriteNode requires at least one frame');

  final List<String> frames;
  final Duration frameDuration;
  final bool loop;
  final bool transparentSpaces;

  int _frameIndex = 0;
  double _elapsed = 0.0;

  /// Optional per-frame update callback.
  final void Function(SpriteNode node, double dt)? onTick;

  int get frameIndex => _frameIndex;

  @override
  void update(double dt) {
    onTick?.call(this, dt);
    final step = frameDuration.inMicroseconds / 1000000.0;
    if (step <= 0) return;

    _elapsed += dt;
    if (_elapsed >= step) {
      _elapsed %= step;
      if (_frameIndex + 1 < frames.length) {
        _frameIndex++;
      } else if (loop) {
        _frameIndex = 0;
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawText(
      0,
      0,
      frames[_frameIndex],
      color: color,
      z: zIndex.toDouble(),
      transparentSpaces: transparentSpaces,
    );
  }
}

