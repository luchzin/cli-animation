import 'package:cli_animation/lib.dart';
import 'package:test/test.dart';

void main() {
  group('Canvas 2D & Scene Graph Node tests', () {
    test('Canvas initializes with Size and triggers onResize', () {
      Size? resizedTo;
      final cv = Canvas(
        size: const Size(60, 20),
        onResize: (newSize) => resizedTo = newSize,
      );

      expect(cv.size, equals(const Size(60, 20)));
      expect(cv.width, equals(60));
      expect(cv.height, equals(20));

      cv.resize(const Size(80, 30));
      expect(cv.size, equals(const Size(80, 30)));
      expect(resizedTo, equals(const Size(80, 30)));
    });

    test('Square, Circle, Line, and TextNode render at (x, y) on Canvas', () {
      final cv = Canvas(size: const Size(40, 15));

      final Node square = Square(
        x: 2,
        y: 1,
        size: 3,
        asciiBorder: true,
        color: AnsiColor.cyan,
      );
      final Node label = TextNode('HELLO', x: 12, y: 2, color: AnsiColor.yellow);
      final Node line = Line(x: 0, y: 10, x2: 5, y2: 10, char: '=');

      cv.add(square);
      cv.add(label);
      cv.add(line);

      cv.renderFrame();

      // Verify Square top-left corner at (2, 1)
      expect(cv.context.getPixel(2, 1), equals('┌'));
      // Verify TextNode characters at (12..16, 2)
      expect(cv.context.getPixel(12, 2), equals('H'));
      expect(cv.context.getPixel(16, 2), equals('O'));
      // Verify Line at (0..5, 10)
      expect(cv.context.getPixel(0, 10), equals('='));
      expect(cv.context.getPixel(5, 10), equals('='));
    });

    test('Parent-child Node hierarchy translates child (x, y) coordinates', () {
      final cv = Canvas(size: const Size(30, 10));
      final group = GroupNode(x: 10, y: 4);
      final childText = TextNode('X', x: 3, y: 2);
      group.add(childText);
      cv.add(group);

      expect(childText.worldX, equals(13));
      expect(childText.worldY, equals(6));

      cv.renderFrame();
      expect(cv.context.getPixel(13, 6), equals('X'));
    });

    test('Built-in animations work as Nodes positioned at (x, y) on Canvas', () {
      final cv = Canvas(size: const Size(80, 24));
      final cradle = NewtonsCradleAnimation(x: 5, y: 2);
      final fountain = ParticleFountainAnimation(x: 40, y: 2, rows: 8, cols: 25);
      final hole = BlackHoleAnimation(x: 5, y: 10, rows: 9, cols: 35);

      cv.addAll([cradle, fountain, hole]);

      expect(() => cv.renderFrame(0.05), returnsNormally);
      expect(() => cv.renderFrame(0.05), returnsNormally);

      // Cradle top bar starts at (x + 2, y + 0) = (7, 2)
      expect(cv.context.getPixel(7, 2), equals('═'));
    });
  });

  group('BlackHoleAnimation tests', () {
    test('initializes with default and custom parameters', () {
      final defaultHole = BlackHoleAnimation();
      expect(defaultHole.rows, equals(11));
      expect(defaultHole.cols, equals(45));
      expect(defaultHole.height, equals(11));
      expect(defaultHole.showJets, isTrue);

      final customHole = BlackHoleAnimation(
        x: 4,
        y: 3,
        rows: 8,
        cols: 30,
        showJets: false,
        color: AnsiColor.yellow,
      );
      expect(customHole.x, equals(4));
      expect(customHole.y, equals(3));
      expect(customHole.rows, equals(8));
      expect(customHole.cols, equals(30));
      expect(customHole.height, equals(8));
      expect(customHole.showJets, isFalse);
    });

    test('tick runs cleanly without errors', () {
      final hole = BlackHoleAnimation(rows: 7, cols: 25);
      expect(() => hole.tick(), returnsNormally);
      expect(() => hole.tick(), returnsNormally);
    });

    test('integrates with AnimationGroup correctly', () {
      final hole = BlackHoleAnimation(rows: 9, cols: 35);
      final helix = DnaHelixAnimation(rows: 6);
      final group = AnimationGroup([helix, hole]);

      expect(helix.height, equals(6));
      expect(hole.height, equals(9));
      expect(group.animations.length, equals(2));
    });
  });

  group('NewtonsCradleAnimation tests', () {
    test('initializes with default and custom parameters', () {
      final defaultCradle = NewtonsCradleAnimation();
      expect(defaultCradle.balls, equals(5));
      expect(defaultCradle.stringLength, equals(4));
      expect(defaultCradle.height, equals(6));

      final customCradle = NewtonsCradleAnimation(
        x: 10,
        y: 5,
        balls: 3,
        stringLength: 3,
        color: AnsiColor.green,
      );
      expect(customCradle.x, equals(10));
      expect(customCradle.y, equals(5));
      expect(customCradle.balls, equals(3));
      expect(customCradle.stringLength, equals(3));
      expect(customCradle.height, equals(5));
    });

    test('tick runs and renders swings', () {
      final cradle = NewtonsCradleAnimation();
      for (var i = 0; i < 20; i++) {
        expect(() => cradle.tick(), returnsNormally);
      }
    });

    test('integrates with AnimationGroup', () {
      final cradle = NewtonsCradleAnimation(stringLength: 4);
      final group = AnimationGroup([cradle]);
      expect(cradle.height, equals(6));
      expect(group.animations.first, equals(cradle));
    });
  });
}
