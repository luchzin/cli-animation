import 'dart:async';
import 'dart:io';

abstract class Animation {
  Animation({
    this.speed = const Duration(milliseconds: 100),
    this.duration,
    this.loop = true,
    this.color = AnsiColor.reset,
  });

  final Duration speed;
  final Duration? duration;
  final bool loop;
  final AnsiColor color;
  int get height => 1;
  Timer? _timer;
  Timer? _durationTimer;
  bool _running = false;

  // Tracked by the manager
  int rowIndex = 0;
  int totalRows = 1;

  bool get isRunning => _running;
  void stopWithoutClearing() {
    if (!_running) return;

    _running = false;
    _timer?.cancel();
    _durationTimer?.cancel();
    _timer = null;
    _durationTimer = null;

    onStop();
  }

  void start() {
    if (_running) return;
    _running = true;

    stderr.write('\x1B[?25l'); // Hide cursor

    onStart();
    tick();

    _timer = Timer.periodic(speed, (_) {
      if (!_running) return;
      tick();
    });

    if (duration != null) {
      _durationTimer = Timer(duration!, stop);
    }
  }

  void tick();
  void onStart() {}
  void onStop() {}

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

  void write(String text) {
    final linesUp = totalRows - rowIndex;
    // Split text into lines to handle multi-line rendering properly
    final lines = text.split('\n');
    final height = lines.length;
    final buffer = StringBuffer();
    // 1. Move up to this animation's top target row
    buffer.write('\x1B[${linesUp}A');
    // 2. Clear and print each line, applying color explicitly to each line
    for (var i = 0; i < height; i++) {
      buffer.write('\x1B[2K\r'); // Clear current line & carriage return
      // Explicitly wrap each line with the animation's designated color
      buffer.write('$color${lines[i]}${AnsiColor.reset}');
      if (i < height - 1) {
        buffer.write('\n'); // Move down to next line for multi-line animations
      }
    }
    // 3. Move back down to the anchor position at the very bottom
    final moveDown = linesUp - (height - 1);
    if (moveDown > 0) {
      buffer.write('\x1B[${moveDown}B\r');
    } else {
      buffer.write('\r');
    }

    stderr.write(buffer.toString());
  }
}

class AnimationGroup {
  AnimationGroup(this.animations);
  final List<Animation> animations;

  void start() {
    int currentOffset = 0;

    for (var i = 0; i < animations.length; i++) {
      final anim = animations[i];
      anim.rowIndex = currentOffset;
      currentOffset += anim.height; // Clean & dynamic!
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
    final totalLines = animations.first.totalRows;

    for (final animation in animations) {
      animation.stopWithoutClearing();
    }

    // Clear the entire animation block top to bottom
    stderr.write(
      '\x1B[${totalLines}A' // Move up to top line
      '\x1B[J' // Clear to bottom of screen
      '\x1B[?25h', // Show cursor
    );
  }
}

class AnsiColor {
  const AnsiColor(this.code);

  final String code;

  static const reset = AnsiColor('\x1B[0m');
  static const red = AnsiColor('\x1B[31m');
  static const green = AnsiColor('\x1B[32m');
  static const yellow = AnsiColor('\x1B[33m');
  static const blue = AnsiColor('\x1B[34m');
  static const magenta = AnsiColor('\x1B[35m');
  static const cyan = AnsiColor('\x1B[36m');
  static const white = AnsiColor('\x1B[37m');

  @override
  String toString() => code;
}
