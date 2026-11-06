import '../animation.dart';

/// A typewriter text effect node that reveals characters progressively.
class TypewriterAnimation extends Animation {
  TypewriterAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    required this.text,
    super.speed = const Duration(milliseconds: 80),
    super.duration,
    super.loop = false,
    super.color,
  });

  final String text;

  int _index = 0;

  @override
  int get width => text.length;

  @override
  void onStart() {
    _index = 0;
  }

  @override
  void tick() {
    if (_index >= text.length) {
      if (loop) {
        _index = 0;
      } else {
        stop();
        return;
      }
    } else {
      _index++;
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    final count = _index.clamp(0, text.length);
    if (count > 0) {
      ctx.drawText(
        0,
        0,
        text.substring(0, count),
        color: color,
        z: zIndex.toDouble(),
      );
    }
  }
}
