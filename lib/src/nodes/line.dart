import '../core/ansi_color.dart';
import '../core/context_2d.dart';
import '../core/node.dart';

/// A 2D line segment node drawn from `(x, y)` to `(x2, y2)` on a `Canvas`.
class Line extends Node {
  Line({
    required super.x,
    required super.y,
    required this.x2,
    required this.y2,
    this.char = '█',
    super.zIndex = 0,
    super.visible = true,
    super.color = AnsiColor.white,
    super.id,
    this.onTick,
  });

  double x2;
  double y2;
  String char;

  /// Optional per-frame update callback.
  final void Function(Line node, double dt)? onTick;

  @override
  void update(double dt) {
    onTick?.call(this, dt);
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawLine(
      0,
      0,
      x2 - x,
      y2 - y,
      char: char,
      color: color,
      z: zIndex.toDouble(),
    );
  }
}

/// Alias for [Line].
typedef LineNode = Line;

