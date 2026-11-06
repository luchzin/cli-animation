import 'dart:async';
import 'dart:io';

import 'ansi_color.dart';
import 'context_2d.dart';
import 'node.dart';

/// Base class for all CLI animations.
///
/// [Animation] extends [Node], meaning any built-in or custom animation can be:
/// 1. Added directly onto a 2D `Canvas` at any `(x, y)` coordinate:
///    ```dart
///    final cv = Canvas(size: Size(80, 24));
///    cv.add(NewtonsCradleAnimation(x: 10, y: 2));
///    cv.start();
///    ```
/// 2. Run standalone with `anim.start()` / `anim.stop()` or grouped with [AnimationGroup].
abstract class Animation extends Node {
  Animation({
    super.x = 0,
    super.y = 0,
    super.zIndex = 0,
    super.visible = true,
    super.color = AnsiColor.reset,
    super.id,
    this.speed = const Duration(milliseconds: 100),
    this.duration,
    this.loop = true,
  });

  final Duration speed;
  final Duration? duration;
  final bool loop;

  /// Width of this animation's bounding box in columns.
  int get width => 50;

  /// Height of this animation's bounding box in rows.
  int get height => 1;

  Timer? _timer;
  Timer? _durationTimer;
  bool _running = false;
  double _accumulatedSeconds = 0.0;
  bool _hasTicked = false;

  /// Latest rendered frame text (when using `write` in custom subclasses).
  String _lastFrame = '';

  // Tracked by AnimationGroup for standalone/group terminal rendering
  int rowIndex = 0;
  int totalRows = 1;

  bool get isRunning => _running;

  @override
  void onMount() {
    onStart();
  }

  @override
  void onUnmount() {
    onStop();
  }

  /// Lifecycle hook called when the animation starts.
  void onStart() {}

  /// Lifecycle hook called when the animation stops.
  void onStop() {}

  /// Advances the animation state by one discrete step.
  void tick();

  @override
  void update(double dt) {
    final stepSeconds = speed.inMicroseconds / 1000000.0;
    if (!_hasTicked || stepSeconds <= 0) {
      _hasTicked = true;
      tick();
      return;
    }

    _accumulatedSeconds += dt;
    if (_accumulatedSeconds + 1e-6 >= stepSeconds) {
      _accumulatedSeconds %= stepSeconds;
      tick();
    }
  }

  @override
  void draw(CanvasContext2D ctx) {
    if (!_hasTicked && _lastFrame.isEmpty) {
      _hasTicked = true;
      tick();
    }
    if (_lastFrame.isNotEmpty) {
      _drawAnsiFormattedText(ctx, _lastFrame);
    }
  }

  /// Parses inline ANSI color codes in [text] and draws characters at `(0, 0)` on [ctx].
  void _drawAnsiFormattedText(CanvasContext2D ctx, String text) {
    final lines = text.split('\n');
    final ansiRegex = RegExp(r'\x1B\[[0-9;]*m');

    for (var r = 0; r < lines.length; r++) {
      final line = lines[r];
      var col = 0;
      var activeColor = color == AnsiColor.reset ? ctx.defaultColor : color;
      var i = 0;

      while (i < line.length) {
        if (line.codeUnitAt(i) == 0x1B) {
          final match = ansiRegex.matchAsPrefix(line, i);
          if (match != null) {
            final seq = match.group(0)!;
            if (seq == AnsiColor.reset.code) {
              activeColor = color == AnsiColor.reset ? ctx.defaultColor : color;
            } else {
              activeColor = AnsiColor(seq);
            }
            i = match.end;
            continue;
          }
        }

        final ch = line[i];
        if (ch != ' ') {
          ctx.setPixel(col, r, ch, color: activeColor, z: zIndex.toDouble());
        }
        col++;
        i++;
      }
    }
  }

  /// Stops standalone execution without clearing terminal lines.
  void stopWithoutClearing() {
    if (!_running) return;

    _running = false;
    _timer?.cancel();
    _durationTimer?.cancel();
    _timer = null;
    _durationTimer = null;

    onStop();
  }

  /// Starts standalone execution of this animation in the terminal.
  void start() {
    if (_running) return;
    _running = true;

    stderr.write('\x1B[?25l'); // Hide cursor

    onStart();
    _standaloneStep();

    _timer = Timer.periodic(speed, (_) {
      if (!_running) return;
      _standaloneStep();
    });

    if (duration != null) {
      _durationTimer = Timer(duration!, stop);
    }
  }

  void _standaloneStep() {
    _lastFrame = '';
    _hasTicked = true;
    tick();
    // If the subclass draws directly via `draw(ctx)` rather than calling `write()`,
    // render its 2D context and flush to terminal.
    if (_lastFrame.isEmpty && _running) {
      final ctx = CanvasContext2D(width, height);
      ctx.defaultColor = color;
      draw(ctx);
      _flushTextToTerminal(ctx.toAnsiString());
    }
  }

  /// Stops standalone execution and clears the animation's terminal lines.
  void stop() {
    if (!_running) return;

    _running = false;
    _timer?.cancel();
    _durationTimer?.cancel();
    _timer = null;
    _durationTimer = null;

    clearLine();
    stderr.write('\x1B[?25h'); // Show cursor
    onStop();
  }

  void clearLine() {
    write('');
  }

  /// Stores the rendered frame for `Canvas` mode, and writes to `stderr` if running standalone.
  void write(String text) {
    _lastFrame = text;
    if (!_running) return;
    _flushTextToTerminal(text);
  }

  void _flushTextToTerminal(String text) {
    final linesUp = totalRows - rowIndex;
    final lines = text.split('\n');
    final lineCount = lines.length;
    final buffer = StringBuffer();

    buffer.write('\x1B[${linesUp}A');
    for (var i = 0; i < lineCount; i++) {
      buffer.write('\x1B[2K\r');
      buffer.write('$color${lines[i]}${AnsiColor.reset}');
      if (i < lineCount - 1) {
        buffer.write('\n');
      }
    }

    final moveDown = linesUp - (lineCount - 1);
    if (moveDown > 0) {
      buffer.write('\x1B[${moveDown}B\r');
    } else {
      buffer.write('\r');
    }

    stderr.write(buffer.toString());
  }
}

/// Manages a vertical stack of standalone [Animation] instances.
class AnimationGroup {
  AnimationGroup(this.animations);
  final List<Animation> animations;

  void start() {
    int currentOffset = 0;

    for (var i = 0; i < animations.length; i++) {
      final anim = animations[i];
      anim.rowIndex = currentOffset;
      currentOffset += anim.height;
    }

    for (final anim in animations) {
      anim.totalRows = currentOffset;
    }

    for (var i = 0; i < currentOffset; i++) {
      stderr.writeln();
    }

    for (final anim in animations) {
      anim.start();
    }
  }

  void stop() {
    if (animations.isEmpty) return;
    final totalLines = animations.first.totalRows;

    for (final animation in animations) {
      animation.stopWithoutClearing();
    }

    stderr.write(
      '\x1B[${totalLines}A'
      '\x1B[J'
      '\x1B[?25h',
    );
  }
}
