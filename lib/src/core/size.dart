import 'dart:io';

/// Represents a 2D dimension in terminal cells (columns x rows).
class Size {
  const Size(this.width, this.height)
    : assert(width >= 0, 'Width must be non-negative'),
      assert(height >= 0, 'Height must be non-negative');

  /// Detects current terminal dimensions, falling back to [fallback] if unavailable.
  factory Size.fromTerminal({Size fallback = const Size(80, 24)}) {
    try {
      if (stdout.hasTerminal) {
        return Size(stdout.terminalColumns, stdout.terminalLines);
      }
    } catch (_) {
      // Fallback when stdout is not attached to a interactive TTY.
    }
    return fallback;
  }

  final int width;
  final int height;

  int get cols => width;
  int get rows => height;

  Size copyWith({int? width, int? height}) =>
      Size(width ?? this.width, height ?? this.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Size && other.width == width && other.height == height);

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'Size($width, $height)';
}

/// Represents a 2D coordinate or vector `(x, y)`.
class Vector2 {
  const Vector2(this.x, this.y);

  static const zero = Vector2(0, 0);

  final double x;
  final double y;

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  Vector2 operator *(double scalar) => Vector2(x * scalar, y * scalar);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vector2 && other.x == x && other.y == y);

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Vector2($x, $y)';
}

