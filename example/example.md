# Examples

This package includes multiple runnable examples in the `example/` directory:

1. **[example/main.dart](main.dart)** — 2D Canvas showcase with shapes, text, and built-in animations.
2. **[example/hit_ball_game.dart](hit_ball_game.dart)** — Interactive terminal mini-game using `Canvas.onKey` keyboard controls, score HUD, and countdown timer.

---

## 1. Hit the Random Ball Game (`example/hit_ball_game.dart`)

Move the cyan `Square` with **Arrow keys** or **WASD**, press **Space** to jump, **R** to restart, and **Q** to quit.

Run it:
```bash
dart run example/hit_ball_game.dart
```

```dart
import 'dart:io';
import 'dart:math';

import 'package:cli_animation/cli_animation.dart';

void main() {
  const width = 60;
  const height = 20;
  const gameDurationSeconds = 30.0;

  final rng = Random();

  var score = 0;
  var remainingTime = gameDurationSeconds;
  var isGameOver = false;

  final scoreText = TextNode(
    'SCORE: 0',
    x: 2,
    y: 1,
    color: AnsiColor.green,
    zIndex: 10,
  );
  final timeText = TextNode(
    'TIME: 30s',
    x: 24,
    y: 1,
    color: AnsiColor.yellow,
    zIndex: 10,
  );
  final hintText = TextNode(
    'WASD/Arrows | Q:Quit',
    x: 38,
    y: 1,
    color: AnsiColor.gray,
    zIndex: 10,
  );
  final headerDivider = Line(
    x: 1,
    y: 2,
    x2: width - 2,
    y2: 2,
    char: '─',
    color: AnsiColor.gray,
    zIndex: 10,
  );

  final player = Square(
    x: 28,
    y: 11,
    size: 2,
    color: AnsiColor.cyan,
    asciiBorder: true,
    zIndex: 5,
  );

  final ball = TextNode(
    '(●)',
    x: 12,
    y: 7,
    color: AnsiColor.yellow,
    zIndex: 4,
  );

  final gameOverBanner = TextNode(
    '',
    x: 12,
    y: 10,
    color: AnsiColor.red,
    visible: false,
    zIndex: 20,
  );

  void spawnBall() {
    ball.x = (2 + rng.nextInt(width - 8)).toDouble();
    ball.y = (3 + rng.nextInt(height - 6)).toDouble();
    const palette = [
      AnsiColor.yellow,
      AnsiColor.magenta,
      AnsiColor.green,
      AnsiColor.red,
    ];
    ball.color = palette[rng.nextInt(palette.length)];
  }

  void resetGame() {
    score = 0;
    remainingTime = gameDurationSeconds;
    isGameOver = false;
    player.x = 28;
    player.y = 11;
    gameOverBanner.visible = false;
    ball.visible = true;
    spawnBall();
  }

  bool checkHit() {
    final px1 = player.x;
    final py1 = player.y;
    final px2 = player.x + player.width - 1;
    final py2 = player.y + player.height - 1;

    final bx1 = ball.x;
    final by1 = ball.y;
    final bx2 = ball.x + 2;
    final by2 = ball.y;

    return px1 <= bx2 && px2 >= bx1 && py1 <= by2 && py2 >= by1;
  }

  late final Canvas cv;
  cv = Canvas(
    size: const Size(width, height),
    frameRate: const Duration(milliseconds: 33),
    border: true,
    onUpdate: (dt, ctx) {
      if (!isGameOver) {
        remainingTime = (remainingTime - dt).clamp(0.0, gameDurationSeconds);

        if (checkHit()) {
          score++;
          spawnBall();
        }

        if (remainingTime <= 0) {
          isGameOver = true;
          ball.visible = false;
          gameOverBanner.text =
              'TIME UP! Score: $score  [R: Restart | Q: Quit]';
          gameOverBanner.visible = true;
        }
      }

      scoreText.text = 'SCORE: $score';
      timeText.text = 'TIME: ${remainingTime.ceil()}s';
      timeText.color = remainingTime <= 5 ? AnsiColor.red : AnsiColor.yellow;
    },
    onKey: (event) {
      if (event.char == 'q' || event.char == 'Q' || event.isEscape) {
        cv.stop();
        exit(0);
      }

      if (isGameOver) {
        if (event.char == 'r' || event.char == 'R') {
          resetGame();
        }
        return;
      }

      if (event.isUp || event.char == 'w') {
        player.y -= 1;
      } else if (event.isDown || event.char == 's') {
        player.y += 1;
      } else if (event.isLeft || event.char == 'a') {
        player.x -= 2;
      } else if (event.isRight || event.char == 'd') {
        player.x += 2;
      } else if (event.isSpace) {
        player.y -= 3;
      }

      player.x = player.x.clamp(1.0, (width - player.width - 1).toDouble());
      player.y = player.y.clamp(3.0, (height - player.height - 1).toDouble());
    },
  );

  spawnBall();

  cv.addAll([
    scoreText,
    timeText,
    hintText,
    headerDivider,
    ball,
    player,
    gameOverBanner,
  ]);

  cv.start();
}
```

---

## 2. 2D Canvas & Animations Showcase (`example/main.dart`)

Run it:
```bash
dart run example/main.dart
```

```dart
import 'dart:async';
import 'package:cli_animation/cli_animation.dart';

Future<void> main() async {
  late final ParticleFountainAnimation fountain;

  final cv = Canvas(
    size: const Size(80, 22),
    border: true,
    onResize: (newSize) {
      fountain.x = (newSize.width - fountain.width - 2).toDouble();
    },
  );

  final Node square = Square(
    x: 2,
    y: 2,
    size: 4,
    color: AnsiColor.green,
    onTick: (node, dt) {
      node.x = 2 + ((DateTime.now().millisecondsSinceEpoch / 300) % 4);
    },
  );

  final Node circle = Circle(
    x: 18,
    y: 4,
    radius: 2,
    color: AnsiColor.magenta,
  );

  final cradle = NewtonsCradleAnimation(
    x: 44,
    y: 2,
    balls: 5,
    stringLength: 4,
    color: AnsiColor.cyan,
  );

  fountain = ParticleFountainAnimation(
    x: 44,
    y: 10,
    rows: 10,
    cols: 32,
    color: AnsiColor.yellow,
  );

  cv.addAll([square, circle, cradle, fountain]);

  cv.start();
  await Future.delayed(const Duration(seconds: 6));
  cv.stop();
}
```
