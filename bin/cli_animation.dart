import 'package:cli_animation/animation.dart';
import 'package:cli_animation/src/dnahellex.dart';

void main() async {
  final group = AnimationGroup([
    DnaHelixAnimation(rows: 6, color: AnsiColor.cyan),
  ]);

  group.start();
  await Future.delayed(const Duration(seconds: 8));
  group.stop();
}
