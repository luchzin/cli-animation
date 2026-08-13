
import 'package:cli_animation/animation.dart';

class SpinnerAnimation extends Animation {
  SpinnerAnimation({
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
  void onStart() {
    _index = 0;
  }

  @override
  void tick() {
    clearLine();

    write('${frames[_index]} $message');

    _index++;

    if (_index >= frames.length) {
      if (loop) {
        _index = 0;
      } else {
        stop();
      }
    }
  }
}