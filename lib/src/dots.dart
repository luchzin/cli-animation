import '../animation.dart';

class DotsAnimation extends Animation {
  DotsAnimation({
    this.text = 'Loading',
    super.speed = const Duration(milliseconds: 300),
    super.duration,
    super.loop = true,
    super.color,
  });

  final String text;

  int _dots = 0;

  @override
  void tick() {
    clearLine();

    write('$text${'.' * _dots}');

    _dots++;

    if (_dots > 3) {
      if (loop) {
        _dots = 0;
      } else {
        stop();
      }
    }
  }
}
