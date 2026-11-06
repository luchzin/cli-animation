import '../core/ansi_color.dart';
import '../core/context_2d.dart';
import '../core/node.dart';

/// A 2D text node that renders single-line or multi-line strings at `(x, y)`.
class TextNode extends Node {
  TextNode(
    this.text, {
    super.x = 0,
    super.y = 0,
    this.transparentSpaces = false,
    super.zIndex = 0,
    super.visible = true,
    super.color = AnsiColor.white,
    super.id,
    this.onTick,
  });

  String text;
  bool transparentSpaces;

  /// Optional per-frame update callback.
  final void Function(TextNode node, double dt)? onTick;

  @override
  void update(double dt) {
    onTick?.call(this, dt);
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawText(
      0,
      0,
      text,
      color: color,
      z: zIndex.toDouble(),
      transparentSpaces: transparentSpaces,
    );
  }
}

