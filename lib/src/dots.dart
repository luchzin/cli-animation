import '../animation.dart';

/// An animated ellipsis (`Loading...`) node.
class DotsAnimation extends Animation {
  DotsAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    this.text = 'Loading',
    super.speed = const Duration(milliseconds: 300),
    super.duration,
    super.loop = true,
    super.color,
  });

  final String text;

  int _dots = 0;

  @override
  int get width => text.length + 3;

  @override
  void tick() {
    _dots++;
    if (_dots > 3) {
      if (loop) {
        _dots = 0;
      } else {
        _dots = 3;
        stop();
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawText(
      0,
      0,
      '$text${'.' * _dots}',
      color: color,
      z: zIndex.toDouble(),
    );
  }
}
