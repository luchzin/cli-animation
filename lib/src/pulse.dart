import '../animation.dart';

class PulseAnimation extends Animation {
  PulseAnimation({
    required this.text,
    super.speed = const Duration(milliseconds: 150),
    super.duration,
    super.loop = true,
    super.color,
  });

  final String text;

  int _index = 0;

  final List<String> _frames = ['░', '▒', '▓', '█', '▓', '▒'];

  @override
  void tick() {
    clearLine();

    final frame = _frames[_index];

    write('$frame $text');

    _index++;

    if (_index >= _frames.length) {
      if (loop) {
        _index = 0;
      } else {
        stop();
      }
    }
  }
}
