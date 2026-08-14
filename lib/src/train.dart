import 'package:cli_animation/animation.dart';

class TrainAnimation extends Animation {
  TrainAnimation({
    super.speed = const Duration(milliseconds: 100),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.yellow,
  });

  int _position = 0;
  int _direction = 1;

  final int _width = 40;

  @override
  int get height => 3;

  @override
  void tick() {
    const train = '''
      ____      
 ____|_  |___  
|  _     _  |==o
'-(_)---(_)-'
''';

    final lines = train.trim().split('\n');
    final padded = lines.map((line) => (' ' * _position) + line).join('\n');

    write(padded);

    _position += _direction;

    if (_position >= _width) {
      _direction = -1;
    } else if (_position <= 0) {
      _position = 0;
      _direction = 1;
    }
  }
}
