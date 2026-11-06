import 'dart:async';
import 'package:cli_animation/lib.dart';

Future<void> main() async {
  print('Welcome to CLI 2D Canvas\n');

  final cv = Canvas(
    size: const Size(80, 22),
    border: true,
    onResize: (newSize) {
      // Respond to terminal or canvas size updates
    },
  );

  final square = Square(
    x: 2,
    y: 2,
    size: 4,
    color: AnsiColor.green,
  );

  final circle = Circle(
    x: 18,
    y: 4,
    radius: 2,
    color: AnsiColor.magenta,
  );

  final spinner = SpinnerAnimation(
    x: 2,
    y: 7,
    message: 'Installing dependencies...',
    color: AnsiColor.red,
    speed: const Duration(milliseconds: 80),
  );

  final blink = BlinkAnimation(
    x: 2,
    y: 9,
    text: 'WARNING: High CPU usage',
    color: AnsiColor.yellow,
  );

  final typewriter = TypewriterAnimation(
    x: 2,
    y: 11,
    text: 'Downloading assets into memory...',
    color: AnsiColor.green,
    loop: true,
  );

  final train = TrainAnimation(
    x: 2,
    y: 13,
    trackWidth: 25,
    color: AnsiColor.magenta,
    speed: const Duration(milliseconds: 80),
  );

  final cradle = NewtonsCradleAnimation(
    x: 44,
    y: 2,
    balls: 5,
    stringLength: 4,
    color: AnsiColor.cyan,
  );

  final matrix = MatrixRainAnimation(
    x: 44,
    y: 10,
    rows: 8,
    cols: 32,
    color: AnsiColor.green,
  );

  cv.addAll([
    square,
    circle,
    spinner,
    blink,
    typewriter,
    train,
    cradle,
    matrix,
  ]);

  cv.start();

  await Future.delayed(const Duration(seconds: 5));

  cv.stop();
  print('\nAll tasks finished!');
}
