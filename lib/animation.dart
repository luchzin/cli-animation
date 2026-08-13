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

  Timer? _timer;
  Timer? _durationTimer;
  bool _running = false;
  
  // Tracked by the manager
  int rowIndex = 0;
  int totalRows = 1;

  bool get isRunning => _running;

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
    // 1. Move up to target row
    // 2. Clear line (\x1B[2K\r)
    // 3. Write colored content
    // 4. Return cursor back down to the anchor line at the bottom
    stderr.write(
      '\x1B[${linesUp}A'
      '\x1B[2K\r'
      '$color$text${AnsiColor.reset}'
      '\x1B[${linesUp}B\r'
    );
  }
}
class AnimationGroup {
  AnimationGroup(this.animations);
  final List<Animation> animations;
  void start() {
    // 1. Allocate vertical space in terminal by printing newlines
    for (var i = 0; i < animations.length; i++) {
      stderr.writeln();
    }
    // 2. Assign positions and start animations
    for (var i = 0; i < animations.length; i++) {
      animations[i].rowIndex = i;
      animations[i].totalRows = animations.length;
      animations[i].start();
    }
  }

  void stop() {
    for (final animation in animations) {
      animation.stop();
    }
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
