import '../animation.dart';

/// A pedaling ASCII bicycle node rendered onto a 2D [CanvasContext2D].
class BicycleAnimation extends Animation {
  BicycleAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    super.speed = const Duration(milliseconds: 100),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.cyan,
  });

  int _frame = 0;

  static const List<String> _frames = [
    '   __o\n _ \\<_\n(_)/(_)',
    '    __o\n  _ \\<_\n (_)/(_)',
    '     __o\n   _ \\<_\n  (_)/(_)',
    '      __o\n    _ \\<_\n   (_)/(_)',
    '       __o\n     _ \\<_\n    (_)/(_)',
    '        __o\n      _ \\<_\n     (_)/(_)',
  ];

  @override
  int get width => 16;

  @override
  int get height => 3;

  @override
  void tick() {
    _frame = (_frame + 1) % _frames.length;
  }

  @override
  void draw(CanvasContext2D ctx) {
    ctx.drawText(
      0,
      0,
      _frames[_frame],
      color: color,
      z: zIndex.toDouble(),
      transparentSpaces: true,
    );
  }
}
