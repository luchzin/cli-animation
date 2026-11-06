import '../core/ansi_color.dart';
import '../core/context_2d.dart';
import '../core/node.dart';

/// A 2D rectangle node that can be positioned at `(x, y)` on a `Canvas`.
class RectNode extends Node {
  RectNode({
    super.x = 0,
    super.y = 0,
    this.width = 6,
    this.height = 4,
    this.borderChar = '█',
    this.fillChar,
    this.fillColor,
    this.asciiBorder = true,
    super.zIndex = 0,
    super.visible = true,
    super.color = AnsiColor.cyan,
    super.id,
    this.onTick,
  });

  int width;
  int height;
  String borderChar;
  String? fillChar;
  AnsiColor? fillColor;
  bool asciiBorder;

  /// Optional per-frame update callback for custom motion/animation.
  final void Function(RectNode node, double dt)? onTick;

  @override
  void update(double dt) {
    onTick?.call(this, dt);
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawRect(
      0,
      0,
      width,
      height,
      borderChar: borderChar,
      fillChar: fillChar,
      color: color,
      fillColor: fillColor,
      asciiBorder: asciiBorder,
      z: zIndex.toDouble(),
    );
  }
}

/// A 2D square node that can be positioned at `(x, y)` on a `Canvas`.
///
/// By default, [aspectRatio] = 2 scales horizontal width by 2x so the square
/// appears geometrically square in standard terminal fonts.
class Square extends RectNode {
  Square({
    super.x = 0,
    super.y = 0,
    int size = 4,
    int aspectRatio = 2,
    super.borderChar = '█',
    super.fillChar,
    super.fillColor,
    super.asciiBorder = true,
    super.zIndex = 0,
    super.visible = true,
    super.color = AnsiColor.cyan,
    super.id,
    super.onTick,
  }) : _size = size,
       _aspectRatio = aspectRatio,
       super(width: size * aspectRatio, height: size);

  int _size;
  final int _aspectRatio;

  int get size => _size;
  set size(int value) {
    _size = value;
    width = value * _aspectRatio;
    height = value;
  }
}

