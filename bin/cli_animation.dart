// main.dart
import 'dart:async';
import 'package:cli_animation/animation.dart';
import 'package:cli_animation/src/blink.dart';
import 'package:cli_animation/src/spinner.dart';
import 'package:cli_animation/src/typewriter.dart';

Future<void> main() async {
  print('Welcome to Fun CLI\n');

  final spinner = SpinnerAnimation(
    message: 'Installing dependencies...',
    color: AnsiColor.red,
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

  final group = AnimationGroup([
    spinner,
    blink,
    typewriter,
  ]);

  group.start();

  await Future.delayed(const Duration(seconds: 5));

  group.stop();
  print('\nAll tasks finished!');
}