import 'package:cli_animation/cli_animation.dart';

void main() {
  late final Canvas cv;
  final player = Square(x: 10, y: 12, size: 3, color: AnsiColor.cyan,fillColor:AnsiColor.cyan);

  cv = Canvas(
    size: const Size(60, 18),
    border: true,
    onKey: (event) {
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
      } else if (event.char == 'q' || event.isEscape) {
        cv.stop();
      }
    },
  );

  cv.add(player);
  cv.start();
}