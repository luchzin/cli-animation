import 'package:cli_animation/animation.dart';

/// A Braille spinner loading node with message text.
class SpinnerAnimation extends Animation {
  SpinnerAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    this.message = 'Loading',
    super.speed,
    super.duration,
    super.loop,
    super.color = AnsiColor.cyan,
  });

  final String message;

  final List<String> frames = const [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  ];

  int _index = 0;

  @override
  int get width => message.length + 2;

  @override
  void onStart() {
    _index = 0;
  }

  @override
  void tick() {
    _index++;
    if (_index >= frames.length) {
      if (loop) {
        _index = 0;
      } else {
        _index = frames.length - 1;
        stop();
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    final frame = frames[_index.clamp(0, frames.length - 1)];
    ctx.drawText(0, 0, '$frame $message', color: color, z: zIndex.toDouble());
  }
}
