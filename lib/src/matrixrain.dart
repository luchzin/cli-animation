import 'package:cli_animation/animation.dart';

class MatrixRainAnimation extends Animation {
  MatrixRainAnimation({
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
  final String _chars = '0123456789ABCDEF@#\$%&*';

  @override
  int get height => rows;

  @override
  void tick() {
    final buffer = StringBuffer();

    // Randomize drop starting points
    for (var c = 0; c < cols; c++) {
      if (_drops[c] == -1 &&
          (c + DateTime.now().millisecondsSinceEpoch) % 5 == 0) {
        _drops[c] = 0;
      }
    }

    // Build line by line
    for (var r = 0; r < rows; r++) {
      final lineBuffer = StringBuffer();
      for (var c = 0; c < cols; c++) {
        if (_drops[c] == r) {
          final char = _chars[(r + c) % _chars.length];
          lineBuffer.write(char);
        } else {
          lineBuffer.write(' ');
        }
      }
      buffer.write(lineBuffer.toString());
      if (r < rows - 1) buffer.write('\n');
    }

    // Advance drops down
    for (var c = 0; c < cols; c++) {
      if (_drops[c] >= 0) {
        _drops[c]++;
        if (_drops[c] >= rows) _drops[c] = -1;
      }
    }

    write(buffer.toString());
  }
}
