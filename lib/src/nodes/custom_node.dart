import '../core/ansi_color.dart';
import '../core/context_2d.dart';
import '../core/node.dart';

/// A flexible 2D node that delegates [update] and [draw] to callbacks,
/// making it easy to sketch arbitrary `(x, y)` graphics on a `Canvas`
/// without subclassing [Node].
class CustomNode extends Node {
  CustomNode({
    required this.onDraw,
    this.onTick,
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.color = AnsiColor.white,
    super.id,
  });

  /// Callback invoked every frame to draw onto [CanvasContext2D] in local coordinates.
  final void Function(CanvasContext2D ctx, CustomNode node) onDraw;

  /// Optional per-frame update callback.
  final void Function(CustomNode node, double dt)? onTick;

  @override
  void update(double dt) {
    onTick?.call(this, dt);
  }

  @override
  void draw(CanvasContext2D ctx) {
    onDraw(ctx, this);
  }
}

