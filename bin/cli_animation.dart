import 'package:cli_animation/lib.dart';

void main() async {
  final cradle = NewtonsCradleAnimation(
    balls: 5,
    stringLength: 4,
    color: AnsiColor.cyan,
  );
  final fountain = ParticleFountainAnimation(
    rows: 8,
    cols: 35,
    color: AnsiColor.yellow,
  );

  final group = AnimationGroup([
    cradle,
    fountain,
  ]);

  group.start();
  await Future.delayed(const Duration(seconds: 8));
  group.stop();
}
