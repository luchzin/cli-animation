A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

## Usage

```dart
import 'dart:async';
import 'package:cli_animation/lib.dart';

Future<void> main() async {
  print('Welcome to Fun CLI\n');
//create spinner animation
  final spinner = SpinnerAnimation(
    message: 'Installing dependencies...',
    color: AnsiColor.red,
    speed: const Duration(milliseconds: 80),
  );
//create train animation
  final train = TrainAnimation(
    color: AnsiColor.magenta,
    speed: const Duration(milliseconds: 80),
  );
//create blink animation
  final blink = BlinkAnimation(
    text: 'WARNING: High CPU usage',
    color: AnsiColor.yellow,
  );
//create typewriter animation
  final typewriter = TypewriterAnimation(
    text: 'Downloading assets into memory...',
    color: AnsiColor.green,
  );
//create donut animation
  final donut = DonutAnimation(
    width: 30,
    height: 15,
    speed: const Duration(milliseconds: 15),
  );
//create bicycle animation
  final bicycle = BicycleAnimation();
//create group animation
  final group = AnimationGroup([
    spinner,
    blink,
    typewriter,
    train,
    donut,
    bicycle,
  ]);
//start animation
  group.start();
  await Future.delayed(const Duration(seconds: 5));
  group.stop();
//stop animation after 5s
  print('\nAll tasks finished!');
}
```
