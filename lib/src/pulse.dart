import '../animation.dart';

/// A pulsing block-shade indicator node with label text.
class PulseAnimation extends Animation {
  PulseAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    required this.text,
    super.speed = const Duration(milliseconds: 150),
    super.duration,
    super.loop = true,
    super.color,
  });

  final String text;

  int _index = 0;

  static const List<String> _frames = ['░', '▒', '▓', '█', '▓', '▒'];

  @override
  int get width => text.length + 2;

  @override
  void tick() {
    _index++;
    if (_index >= _frames.length) {
      if (loop) {
        _index = 0;
      } else {
        _index = _frames.length - 1;
        stop();
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    final frame = _frames[_index.clamp(0, _frames.length - 1)];
    ctx.drawText(0, 0, '$frame $text', color: color, z: zIndex.toDouble());
  }
}
