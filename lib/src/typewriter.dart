import '../animation.dart';

class TypewriterAnimation extends Animation {
  TypewriterAnimation({
    required this.text,
    super.speed = const Duration(milliseconds: 80),
    super.duration,
    super.loop = false,
    super.color,
  });

  final String text;

  int _index = 0;

  @override
  void onStart() {
    _index = 0;
  }

  @override
  void tick() {
    clearLine();

    write(text.substring(0, _index));

    if (_index >= text.length) {
      if (loop) {
        _index = 0;
      } else {
        stop();
        return;
      }
    }

    _index++;
  }
}
