import 'package:cli_animation/cli_animation.dart';

void main() async {
  late final Node square;
  late final NewtonsCradleAnimation cradle;
  late final ParticleFountainAnimation fountain;

  final cv = Canvas(
    size: const Size(76, 16),
    border: true,
    onResize: (newSize) {
      // Dynamically reposition nodes when canvas/terminal resizes
      fountain.x = (newSize.width - fountain.width - 2).toDouble();
    },
  );

  // 1. Add 2D primitive nodes with (x, y) coordinates
  square = Square(
    x: 3,
    y: 2,
    size: 4,
    color: AnsiColor.green,
    asciiBorder: true,
    onTick: (node, dt) {
      // Gentle horizontal oscillation
      node.x = 3 + ((DateTime.now().millisecondsSinceEpoch / 300) % 4);
    },
  );

  final title = TextNode(
    'CLI 2D Canvas Engine',
    x: 3,
    y: 1,
    color: AnsiColor.white,
  );

  // 2. Add built-in animations as scene-graph Nodes at (x, y)
  cradle = NewtonsCradleAnimation(
    x: 14,
    y: 2,
    balls: 5,
    stringLength: 4,
    color: AnsiColor.cyan,
  );

  fountain = ParticleFountainAnimation(
    x: 42,
    y: 4,
    rows: 10,
    cols: 30,
    color: AnsiColor.yellow,
  );

  cv.add(title);
  cv.add(square);
  cv.add(cradle);
  cv.add(fountain);

  cv.start();
  await Future.delayed(const Duration(seconds: 8));
  cv.stop();
}
