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

  bool get isRunning => _running;

  void start() {
    if (_running) return;

    _running = true;

    stdout.write('\x1B[?25l');

    onStart();

    tick();

    _timer = Timer.periodic(speed, (timer) {
      if (!_running) {
        timer.cancel();
        return;
      }

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

    stdout.write('\x1B[?25h');

    onStop();
  }

  void clearLine() {
    stdout.write('\x1B[2K\r');
  }

  void write(String text) {
    stdout.write('$color$text${AnsiColor.reset}');
    stdout.flush();
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
