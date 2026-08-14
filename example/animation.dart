import 'dart:async';
import 'package:cli_animation/lib.dart';

Future<void> main() async {
  print('Welcome to Fun CLI\n');

  final spinner = SpinnerAnimation(
    message: 'Installing dependencies...',
    color: AnsiColor.red,
    speed: const Duration(milliseconds: 80),
  );
  final train = TrainAnimation(
    color: AnsiColor.magenta,
    speed: const Duration(milliseconds: 80),
  );

  final blink = BlinkAnimation(
    text: 'WARNING: High CPU usage',
    color: AnsiColor.yellow,
  );

  final typewriter = TypewriterAnimation(
    text: 'Downloading assets into memory...',
    color: AnsiColor.green,
  );
  final donut = DonutAnimation(
    width: 30,
    height: 15,
    speed: const Duration(milliseconds: 15),
  );
  final bicycle = BicycleAnimation();
  final group = AnimationGroup([
    spinner,
    blink,
    typewriter,
    train,
    donut,
    bicycle,
  ]);

  group.start();

  await Future.delayed(const Duration(seconds: 5));

  group.stop();
  print('\nAll tasks finished!');
}
