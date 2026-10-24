import 'package:cli_animation/lib.dart';

void main() async {
  final blackHole = BlackHoleAnimation(
    rows: 10,
    cols: 45,
    color: AnsiColor.cyan,
  );
  final fountain = ParticleFountainAnimation(
    rows: 8,
    cols: 35,
    color: AnsiColor.yellow,
  );
  final dna = DnaHelixAnimation(
    rows: 6,
    color: AnsiColor.magenta,
  );

  final group = AnimationGroup([
    blackHole,
    dna,
    fountain,
  ]);

  group.start();
  await Future.delayed(const Duration(seconds: 8));
  group.stop();
}
