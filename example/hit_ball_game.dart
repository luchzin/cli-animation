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

  // Header & HUD nodes
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

  // Player & Ball nodes
  final player = Square(
    x: 28,
    y: 11,
    size: 2, // 4 cols wide x 2 rows tall in terminal aspect
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
    // Keep inside arena bounds: x in [2, width - 6], y in [3, height - 3]
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
    final bx2 = ball.x + 2; // '(●)' is 3 chars wide
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
        player.y -= 3; // Jump
      }

      // Clamp player inside playfield (below header divider)
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

