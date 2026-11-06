import '../core/ansi_color.dart';
import '../core/context_2d.dart';
import '../core/node.dart';

/// A 2D circle node centered at `(x, y)` on a `Canvas`.
class Circle extends Node {
  Circle({
    super.x = 0,
    super.y = 0,
    this.radius = 3,
    this.borderChar = '●',
    this.fillChar,
    this.fillColor,
    this.aspect = 2.0,
    super.zIndex = 0,
    super.visible = true,
    super.color = AnsiColor.magenta,
    super.id,
    this.onTick,
  });

  num radius;
  String borderChar;
  String? fillChar;
  AnsiColor? fillColor;
  double aspect;

  /// Optional per-frame update callback for custom motion/animation.
  final void Function(Circle node, double dt)? onTick;

  @override
  void update(double dt) {
    onTick?.call(this, dt);
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawCircle(
      0,
      0,
      radius,
      borderChar: borderChar,
      fillChar: fillChar,
      color: color,
      fillColor: fillColor,
      aspect: aspect,
      z: zIndex.toDouble(),
    );
  }
}

/// Alias for [Circle].
typedef CircleNode = Circle;

