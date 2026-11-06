import 'package:cli_animation/animation.dart';

/// A falling Matrix digital rain node rendered onto a 2D [CanvasContext2D].
class MatrixRainAnimation extends Animation {
  MatrixRainAnimation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.id,
    super.speed = const Duration(milliseconds: 100),
    super.duration,
    super.loop = true,
    super.color = AnsiColor.green,
    this.rows = 4,
    this.cols = 30,
  }) : _drops = List.generate(cols, (_) => -1);

  final int rows;
  final int cols;
  final List<int> _drops;
  static const String _chars = '0123456789ABCDEF@#\$%&*';

  @override
  int get width => cols;

  @override
  int get height => rows;

  @override
  void tick() {
    for (var c = 0; c < cols; c++) {
      if (_drops[c] >= 0) {
        _drops[c]++;
        if (_drops[c] >= rows) _drops[c] = -1;
      }
      if (_drops[c] == -1 &&
          (c + DateTime.now().millisecondsSinceEpoch) % 5 == 0) {
        _drops[c] = 0;
      }
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    for (var c = 0; c < cols; c++) {
      final dropRow = _drops[c];
      if (dropRow >= 0 && dropRow < rows) {
        final char = _chars[(dropRow + c) % _chars.length];
        ctx.setPixel(c, dropRow, char, color: color, z: zIndex.toDouble());
      }
    }
  }
}
