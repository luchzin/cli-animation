import '../animation.dart';

/// A blinking text node that toggles visibility on each tick.
class BlinkAnimation extends Animation {
  BlinkAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    required this.text,
    super.speed = const Duration(milliseconds: 500),
    super.duration,
    super.loop = true,
    super.color,
  });

  final String text;
  bool _showText = true;

  @override
  int get width => text.length;

  @override
  void tick() {
    _showText = !_showText;
  }

  @override
  void draw(CanvasContext2D ctx) {
    if (_showText) {
      ctx.drawText(0, 0, text, color: color, z: zIndex.toDouble());
    }
  }
}
