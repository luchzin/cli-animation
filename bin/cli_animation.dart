import 'package:cli_animation/animation.dart';
import 'package:cli_animation/src/dnahellex.dart';
import 'package:cli_animation/src/particle.dart';

void main() async {
  final fountain = ParticleFountainAnimation(
    rows: 8,
    cols: 35,
    color: AnsiColor.yellow,
  );
  final group = AnimationGroup([
    DnaHelixAnimation(rows: 6, color: AnsiColor.cyan),
    fountain,
  ]);

  group.start();
  await Future.delayed(const Duration(seconds: 8));
  group.stop();
}
