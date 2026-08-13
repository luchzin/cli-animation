import 'dart:async';

import 'package:cli_animation/animation.dart';
import 'package:cli_animation/src/blink.dart';
import 'package:cli_animation/src/spinner.dart';
import 'package:cli_animation/src/typewriter.dart';

Future<void> main() async {
  print('Welcome to Fun CLI');

  final spinner = SpinnerAnimation(
    message: 'Installing dependencies',
    color: AnsiColor.red,
    speed: const Duration(milliseconds: 80),
    duration: const Duration(seconds: 5),
  );

  final blink = BlinkAnimation(text: 'WARNING', color: AnsiColor.red);

  final typewriter = TypewriterAnimation(
    text: 'Hello from Fun CLI',
    color: AnsiColor.green,
  );

  spinner.start();
  blink.start();
  typewriter.start();

  await Future.delayed(const Duration(seconds: 6));

  spinner.stop();
  blink.stop();
  typewriter.stop();
}
