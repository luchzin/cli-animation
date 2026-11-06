import 'package:cli_animation/animation.dart';

/// A moving ASCII locomotive train node rendered onto a 2D [CanvasContext2D].
class TrainAnimation extends Animation {
  TrainAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    super.speed = const Duration(milliseconds: 100),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.yellow,
    this.trackWidth = 40,
  });

  final int trackWidth;
  int _position = 0;
  int _direction = 1;

  static const String _sprite = '''
     ____      
____|_  |___  
|  _     _  |==o
'-(_)---(_)-'
''';

  @override
  int get width => trackWidth + 18;

  @override
  int get height => 4;

  @override
  void tick() {
    _position += _direction;

    if (_position >= trackWidth) {
      _direction = -1;
    } else if (_position <= 0) {
      _position = 0;
      _direction = 1;
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawText(
      _position,
      0,
      _sprite.trimRight(),
      color: color,
      z: zIndex.toDouble(),
      transparentSpaces: true,
    );
  }
}
