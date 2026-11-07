# cli_animation

A modular 2D terminal Canvas & Scene Graph engine for Dart CLI applications, inspired by HTML5 Canvas 2D. Draw shapes, text, sprites, and rich physics-based animations at any `(x, y)` coordinate in the terminal.

## Features

- **2D `Canvas` & `CanvasContext2D`**: Draw pixels, lines, rectangles, circles, and text at `(x, y)` with Z-index depth sorting, transform stacks (`save`, `translate`, `restore`), and `onResize` terminal hooks.
- **Hierarchical `Node` Scene Graph**: Compose scenes with `Node`, `GroupNode`, `Square`, `RectNode`, `Circle`, `Line`, `TextNode`, `SpriteNode`, and `CustomNode`.
- **17 Built-in Animation Nodes**: Every built-in animation extends `Node`, so you can position multiple animations side-by-side at any `(x, y)` on a `Canvas` or run them standalone.

## Project Structure

```text
lib/
├── lib.dart                  # Main library export
├── animation.dart            # Core Canvas & Animation exports
└── src/
    ├── core/
    │   ├── ansi_color.dart   # ANSI 16, 256-palette, and 24-bit RGB colors
    │   ├── size.dart         # Size & Vector2
    │   ├── context_2d.dart   # CanvasContext2D (2D buffer, transforms, primitives)
    │   ├── node.dart         # Scene graph Node & GroupNode
    │   ├── canvas.dart       # Canvas loop, scene manager, and resize handler
    │   └── animation.dart    # Base Animation node & AnimationGroup
    ├── nodes/
    │   ├── square.dart       # Square & RectNode
    │   ├── circle.dart       # CircleNode
    │   ├── line.dart         # LineNode
    │   ├── text.dart         # TextNode
    │   ├── sprite.dart       # SpriteNode
    │   └── custom_node.dart  # CustomNode for ad-hoc 2D drawing
    └── *.dart                # 17 built-in animation nodes
```

## Quick Start (2D Canvas & Nodes)

```dart
import 'package:cli_animation/cli_animation.dart';

Future<void> main() async {
  late final ParticleFountainAnimation fountain;

  final cv = Canvas(
    size: const Size(76, 16),
    border: true,
    onResize: (newSize) {
      fountain.x = (newSize.width - fountain.width - 2).toDouble();
    },
  );

  final Node square = Square(
    x: 3,
    y: 2,
    size: 4,
    color: AnsiColor.green,
  );

  final Node cradle = NewtonsCradleAnimation(
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

  cv.add(square);
  cv.add(cradle);
  cv.add(fountain);

  cv.start();
  await Future.delayed(const Duration(seconds: 8));
  cv.stop();
}
```
