import 'dart:math' as math;

import 'ansi_color.dart';
import 'size.dart';

class _TransformState {
  _TransformState(this.translateX, this.translateY, this.defaultColor);

  final double translateX;
  final double translateY;
  final AnsiColor defaultColor;
}

/// A 2D rendering context inspired by HTML5 Canvas 2D, designed for terminal grids.
///
/// Supports coordinate transformations ([save], [translate], [restore]),
/// Z-buffering for depth sorting, per-cell ANSI coloring, and 2D drawing
/// primitives ([setPixel], [drawText], [drawLine], [drawRect], [drawCircle]).
class CanvasContext2D {
  CanvasContext2D(int width, int height)
    : _width = math.max(1, width),
      _height = math.max(1, height) {
    _allocateBuffers();
  }

  int _width;
  int _height;

  int get width => _width;
  int get height => _height;
  Size get size => Size(_width, _height);

  late List<List<String>> _charGrid;
  late List<List<AnsiColor>> _colorGrid;
  late List<List<double>> _zGrid;

  double _tx = 0.0;
  double _ty = 0.0;
  AnsiColor defaultColor = AnsiColor.reset;

  final List<_TransformState> _stateStack = [];

  void _allocateBuffers() {
    _charGrid = List.generate(_height, (_) => List.filled(_width, ' '));
    _colorGrid = List.generate(
      _height,
      (_) => List.filled(_width, AnsiColor.reset),
    );
    _zGrid = List.generate(
      _height,
      (_) => List.filled(_width, double.negativeInfinity),
    );
  }

  /// Resizes the underlying 2D frame buffer.
  void resize(Size newSize) {
    final w = math.max(1, newSize.width);
    final h = math.max(1, newSize.height);
    if (w == _width && h == _height) return;
    _width = w;
    _height = h;
    _allocateBuffers();
  }

  /// Clears the entire canvas buffer.
  void clear([String fillChar = ' ', AnsiColor color = AnsiColor.reset]) {
    for (var r = 0; r < _height; r++) {
      for (var c = 0; c < _width; c++) {
        _charGrid[r][c] = fillChar;
        _colorGrid[r][c] = color;
        _zGrid[r][c] = double.negativeInfinity;
      }
    }
    _tx = 0.0;
    _ty = 0.0;
    defaultColor = AnsiColor.reset;
    _stateStack.clear();
  }

  /// Pushes the current transform and style state onto the stack.
  void save() {
    _stateStack.add(_TransformState(_tx, _ty, defaultColor));
  }

  /// Restores the most recently saved transform and style state.
  void restore() {
    if (_stateStack.isEmpty) return;
    final state = _stateStack.removeLast();
    _tx = state.translateX;
    _ty = state.translateY;
    defaultColor = state.defaultColor;
  }

  /// Translates the origin of the context by `(dx, dy)`.
  void translate(num dx, num dy) {
    _tx += dx.toDouble();
    _ty += dy.toDouble();
  }

  /// Sets a single character cell at `(x, y)` in local coordinates.
  ///
  /// Respects Z-depth buffering: only overwrites a cell if `z >= currentZ`.
  void setPixel(
    num x,
    num y,
    String char, {
    AnsiColor? color,
    double z = 0.0,
  }) {
    if (char.isEmpty) return;
    final gx = (_tx + x).round();
    final gy = (_ty + y).round();

    if (gx < 0 || gx >= _width || gy < 0 || gy >= _height) return;

    if (z >= _zGrid[gy][gx]) {
      _zGrid[gy][gx] = z;
      _charGrid[gy][gx] = char[0];
      _colorGrid[gy][gx] = color ?? defaultColor;
    }
  }

  /// Reads the character currently drawn at local coordinate `(x, y)`.
  String getPixel(num x, num y) {
    final gx = (_tx + x).round();
    final gy = (_ty + y).round();
    if (gx < 0 || gx >= _width || gy < 0 || gy >= _height) return ' ';
    return _charGrid[gy][gx];
  }

  /// Reads the current Z-depth value at local coordinate `(x, y)`.
  double getZ(num x, num y) {
    final gx = (_tx + x).round();
    final gy = (_ty + y).round();
    if (gx < 0 || gx >= _width || gy < 0 || gy >= _height) {
      return double.negativeInfinity;
    }
    return _zGrid[gy][gx];
  }

  /// Draws single-line or multi-line text starting at `(x, y)`.
  void drawText(
    num x,
    num y,
    String text, {
    AnsiColor? color,
    double z = 0.0,
    bool transparentSpaces = false,
  }) {
    final lines = text.split('\n');
    final resolvedColor = color ?? defaultColor;

    for (var rowOffset = 0; rowOffset < lines.length; rowOffset++) {
      final line = lines[rowOffset];
      for (var colOffset = 0; colOffset < line.length; colOffset++) {
        final ch = line[colOffset];
        if (transparentSpaces && ch == ' ') continue;
        setPixel(
          x + colOffset,
          y + rowOffset,
          ch,
          color: resolvedColor,
          z: z,
        );
      }
    }
  }

  /// Draws a line between `(x0, y0)` and `(x1, y1)` using Bresenham's algorithm.
  void drawLine(
    num x0,
    num y0,
    num x1,
    num y1, {
    String char = '█',
    AnsiColor? color,
    double z = 0.0,
  }) {
    var ix0 = x0.round();
    var iy0 = y0.round();
    final ix1 = x1.round();
    final iy1 = y1.round();

    final dx = (ix1 - ix0).abs();
    final dy = -(iy1 - iy0).abs();
    final sx = ix0 < ix1 ? 1 : -1;
    final sy = iy0 < iy1 ? 1 : -1;
    var err = dx + dy;

    while (true) {
      setPixel(ix0, iy0, char, color: color, z: z);
      if (ix0 == ix1 && iy0 == iy1) break;
      final e2 = 2 * err;
      if (e2 >= dy) {
        err += dy;
        ix0 += sx;
      }
      if (e2 <= dx) {
        err += dx;
        iy0 += sy;
      }
    }
  }

  /// Draws a rectangle at `(x, y)` with [rectWidth] and [rectHeight].
  ///
  /// When [asciiBorder] is true, uses box-drawing characters (`┌─┐│└┘`).
  void drawRect(
    num x,
    num y,
    int rectWidth,
    int rectHeight, {
    String borderChar = '█',
    String? fillChar,
    AnsiColor? color,
    AnsiColor? fillColor,
    bool asciiBorder = false,
    double z = 0.0,
  }) {
    if (rectWidth <= 0 || rectHeight <= 0) return;

    final resolvedBorderColor = color ?? defaultColor;
    final resolvedFillColor = fillColor ?? resolvedBorderColor;

    for (var r = 0; r < rectHeight; r++) {
      for (var c = 0; c < rectWidth; c++) {
        final isTop = r == 0;
        final isBottom = r == rectHeight - 1;
        final isLeft = c == 0;
        final isRight = c == rectWidth - 1;
        final isBorder = isTop || isBottom || isLeft || isRight;

        if (isBorder) {
          String ch = borderChar;
          if (asciiBorder && rectWidth >= 2 && rectHeight >= 2) {
            if (isTop && isLeft) {
              ch = '┌';
            } else if (isTop && isRight) {
              ch = '┐';
            } else if (isBottom && isLeft) {
              ch = '└';
            } else if (isBottom && isRight) {
              ch = '┘';
            } else if (isTop || isBottom) {
              ch = '─';
            } else {
              ch = '│';
            }
          }
          setPixel(x + c, y + r, ch, color: resolvedBorderColor, z: z);
        } else if (fillChar != null && fillChar.isNotEmpty) {
          setPixel(x + c, y + r, fillChar, color: resolvedFillColor, z: z);
        }
      }
    }
  }

  /// Fills a solid rectangle at `(x, y)` with [rectWidth] and [rectHeight].
  void fillRect(
    num x,
    num y,
    int rectWidth,
    int rectHeight, {
    String char = '█',
    AnsiColor? color,
    double z = 0.0,
  }) {
    drawRect(
      x,
      y,
      rectWidth,
      rectHeight,
      borderChar: char,
      fillChar: char,
      color: color,
      fillColor: color,
      z: z,
    );
  }

  /// Draws a rectangle outline at `(x, y)` with [rectWidth] and [rectHeight].
  void strokeRect(
    num x,
    num y,
    int rectWidth,
    int rectHeight, {
    String borderChar = '█',
    AnsiColor? color,
    bool asciiBorder = true,
    double z = 0.0,
  }) {
    drawRect(
      x,
      y,
      rectWidth,
      rectHeight,
      borderChar: borderChar,
      fillChar: null,
      color: color,
      asciiBorder: asciiBorder,
      z: z,
    );
  }

  /// Draws a circle centered at `(cx, cy)` with [radius].
  ///
  /// [aspect] compensates for terminal character height-to-width ratio (default ~2.0).
  void drawCircle(
    num cx,
    num cy,
    num radius, {
    String borderChar = '●',
    String? fillChar,
    AnsiColor? color,
    AnsiColor? fillColor,
    double aspect = 2.0,
    double z = 0.0,
  }) {
    if (radius <= 0) return;

    final resolvedBorderColor = color ?? defaultColor;
    final resolvedFillColor = fillColor ?? resolvedBorderColor;
    final rx = (radius * aspect).ceil();
    final ry = radius.ceil();

    for (var dy = -ry; dy <= ry; dy++) {
      for (var dx = -rx; dx <= rx; dx++) {
        final normalizedX = dx / aspect;
        final dist = math.sqrt(normalizedX * normalizedX + dy * dy);
        if (dist <= radius + 0.45) {
          if (dist >= radius - 0.55) {
            setPixel(
              cx + dx,
              cy + dy,
              borderChar,
              color: resolvedBorderColor,
              z: z,
            );
          } else if (fillChar != null && fillChar.isNotEmpty) {
            setPixel(
              cx + dx,
              cy + dy,
              fillChar,
              color: resolvedFillColor,
              z: z,
            );
          }
        }
      }
    }
  }

  /// Renders the 2D grid into a list of ANSI-formatted strings (one per row).
  List<String> toLines() {
    final lines = <String>[];

    for (var r = 0; r < _height; r++) {
      final rowBuffer = StringBuffer();
      AnsiColor currentColor = AnsiColor.reset;

      for (var c = 0; c < _width; c++) {
        final cellColor = _colorGrid[r][c];
        final cellChar = _charGrid[r][c];

        if (cellColor != currentColor) {
          if (cellColor == AnsiColor.reset) {
            rowBuffer.write(AnsiColor.reset.code);
          } else {
            rowBuffer.write(cellColor.code);
          }
          currentColor = cellColor;
        }
        rowBuffer.write(cellChar);
      }

      if (currentColor != AnsiColor.reset) {
        rowBuffer.write(AnsiColor.reset.code);
      }

      lines.add(rowBuffer.toString());
    }

    return lines;
  }

  /// Renders the entire 2D buffer as a newline-separated ANSI string.
  String toAnsiString() => toLines().join('\n');
}

