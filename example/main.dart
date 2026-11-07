import 'dart:async';
import 'package:cli_animation/cli_animation.dart';

Future<void> main() async {
  print('Welcome to CLI 2D Canvas\n');

  late final ParticleFountainAnimation fountain;

  final cv = Canvas(
    size: const Size(80, 22),
    border: true,
    onResize: (newSize) {
      // Respond dynamically to terminal or canvas resize events
      fountain.x = (newSize.width - fountain.width - 2).toDouble();
    },
  );

  // 1. Add 2D shape & text nodes at (x, y) coordinates
  final Node square = Square(
    x: 2,
    y: 2,
    size: 4,
    color: AnsiColor.green,
    onTick: (node, dt) {
      node.x = 2 + ((DateTime.now().millisecondsSinceEpoch / 300) % 4);
    },
  );

  final Node circle = Circle(
    x: 18,
    y: 4,
    radius: 2,
    color: AnsiColor.magenta,
  );

  final Node title = TextNode(
    'CLI 2D Canvas Engine',
    x: 2,
    y: 1,
    color: AnsiColor.white,
  );

  // 2. Add built-in animations as scene-graph Nodes positioned at (x, y)
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

  fountain = ParticleFountainAnimation(
    x: 44,
    y: 10,
    rows: 10,
    cols: 32,
    color: AnsiColor.yellow,
  );

  cv.addAll([
    title,
    square,
    circle,
    spinner,
    blink,
    typewriter,
    train,
    cradle,
    fountain,
  ]);

  cv.start();

  await Future.delayed(const Duration(seconds: 6));

  cv.stop();
  print('\nAll tasks finished!');
}
