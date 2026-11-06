/// ANSI escape color codes for terminal rendering.
class AnsiColor {
  const AnsiColor(this.code);

  final String code;

  static const reset = AnsiColor('\x1B[0m');
  static const black = AnsiColor('\x1B[30m');
  static const red = AnsiColor('\x1B[31m');
  static const green = AnsiColor('\x1B[32m');
  static const yellow = AnsiColor('\x1B[33m');
  static const blue = AnsiColor('\x1B[34m');
  static const magenta = AnsiColor('\x1B[35m');
  static const cyan = AnsiColor('\x1B[36m');
  static const white = AnsiColor('\x1B[37m');
  static const gray = AnsiColor('\x1B[90m');

  /// Creates a 256-color foreground ANSI color.
  factory AnsiColor.palette(int colorIndex) =>
      AnsiColor('\x1B[38;5;${colorIndex.clamp(0, 255)}m');

  /// Creates a 24-bit RGB foreground ANSI color.
  factory AnsiColor.rgb(int r, int g, int b) => AnsiColor(
    '\x1B[38;2;${r.clamp(0, 255)};${g.clamp(0, 255)};${b.clamp(0, 255)}m',
  );

  bool get isEmpty => code.isEmpty;
  bool get isNotEmpty => code.isNotEmpty;

  @override
  String toString() => code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AnsiColor && other.code == code);

  @override
  int get hashCode => code.hashCode;
}

