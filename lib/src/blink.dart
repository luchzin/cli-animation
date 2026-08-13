import '../animation.dart';

class BlinkAnimation extends Animation {
  BlinkAnimation({
    required this.text,
    super.speed = const Duration(milliseconds: 500),
    super.duration,
    super.loop = true,
    super.color,
  });

  final String text;
  bool _visible = true;

  @override
  void tick() {
    clearLine();

    if (_visible) {
      write(text);
    }

    _visible = !_visible;
  }
}